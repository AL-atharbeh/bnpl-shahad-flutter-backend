import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class IdOcrResult {
  final String? fullName;
  final String? nationalId;
  final String? dateOfBirth;

  IdOcrResult({
    this.fullName,
    this.nationalId,
    this.dateOfBirth,
  });

  @override
  String toString() {
    return 'IdOcrResult(fullName: $fullName, nationalId: $nationalId, dateOfBirth: $dateOfBirth)';
  }
}

class IdOcrService {
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  /// مسح الهوية واستخراج البيانات من الوجهين الأمامي والخلفي
  Future<IdOcrResult> extractData({
    required String frontImagePath,
    required String backImagePath,
  }) async {
    String? fullName;
    String? nationalId;
    String? dateOfBirth;

    try {
      // 1. معالجة الوجه الخلفي أولاً (لأن الـ MRZ يحتوي على بيانات دقيقة ومكتملة باللغة الإنجليزية)
      if (backImagePath.isNotEmpty) {
        final backInputImage = InputImage.fromFilePath(backImagePath);
        final backRecognizedText = await _textRecognizer.processImage(backInputImage);
        
        debugPrint('--- OCR Back Text Raw ---');
        debugPrint(backRecognizedText.text);
        
        // محاولة استخراج البيانات من الـ MRZ
        final mrzResult = _parseMrz(backRecognizedText.text);
        if (mrzResult != null) {
          debugPrint('✅ Data extracted from MRZ successfully: $mrzResult');
          fullName = mrzResult.fullName;
          nationalId = mrzResult.nationalId;
          dateOfBirth = mrzResult.dateOfBirth;
        } else {
          // استخراج احتياطي من النصوص العادية في الخلف
          dateOfBirth = _extractDateOfBirth(backRecognizedText.text);
          nationalId = _extractNationalId(backRecognizedText.text);
        }
      }

      // 2. معالجة الوجه الأمامي لاستخراج البيانات
      if (frontImagePath.isNotEmpty) {
        final frontInputImage = InputImage.fromFilePath(frontImagePath);
        final frontRecognizedText = await _textRecognizer.processImage(frontInputImage);
        
        debugPrint('--- OCR Front Text Raw ---');
        debugPrint(frontRecognizedText.text);
        
        // استخراج الاسم العربي
        final arabicName = _extractArabicName(frontRecognizedText.text);
        if (arabicName != null) {
          fullName = arabicName; // نفضل الاسم العربي للمستخدمين المحليين
        } else if (fullName == null) {
          // إذا لم نجد الاسم العربي ولم نجد اسم الـ MRZ، نبحث عن الاسم الإنجليزي من الأمام
          fullName = _extractEnglishNameFromFront(frontRecognizedText.text);
        }

        // ملء الرقم الوطني إذا لم يستخرج من الخلف (وهو أمر مهم جداً في الأردن حيث الرقم الوطني على وجه البطاقة)
        if (nationalId == null) {
          nationalId = _extractNationalId(frontRecognizedText.text);
        }

        // ملء تاريخ الميلاد من الأمام (تاريخ الميلاد موجود في وجه الهوية الأردنية أيضاً)
        if (dateOfBirth == null) {
          dateOfBirth = _extractDateOfBirthFromFront(frontRecognizedText.text);
        }
      }
    } catch (e) {
      debugPrint('⚠️ Error during OCR processing: $e');
    }

    return IdOcrResult(
      fullName: fullName,
      nationalId: nationalId,
      dateOfBirth: dateOfBirth,
    );
  }

  /// تحويل الأرقام الهندية/العربية (٠-٩) إلى أرقام غربية (0-9) لضمان صحة التحليل البرمجي
  String _normalizeDigits(String text) {
    const arabicIndic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    
    String normalized = text;
    for (int i = 0; i < 10; i++) {
      normalized = normalized.replaceAll(arabicIndic[i], english[i]);
    }
    return normalized;
  }

  /// تحليل الـ MRZ (Machine Readable Zone) من الوجه الخلفي للهوية
  IdOcrResult? _parseMrz(String text) {
    final normalized = _normalizeDigits(text);
    // تقسيم النص إلى أسطر وتنظيف المسافات الفارغة
    final lines = normalized.split('\n')
        .map((l) => l.trim().replaceAll(' ', ''))
        .where((l) => l.isNotEmpty)
        .toList();
    
    // البحث عن 3 أسطر متتالية تمثل الـ MRZ للهوية (صيغة TD1 تتكون من 3 أسطر طول كل منها 30 حرفاً)
    List<String> mrzLines = [];
    for (var line in lines) {
      if (line.contains('<') && line.length >= 26 && line.length <= 34) {
        mrzLines.add(line);
      }
    }

    if (mrzLines.length < 3) {
      mrzLines.clear();
      for (var line in lines) {
        if (line.contains('<<') || (line.contains('<') && RegExp(r'\d').hasMatch(line))) {
          if (line.length >= 26 && line.length <= 34) {
            mrzLines.add(line);
          }
        }
      }
    }

    if (mrzLines.length >= 3) {
      try {
        final line1 = mrzLines[0];
        final line2 = mrzLines[1];
        final line3 = mrzLines[2];

        // 1. استخراج الرقم الوطني من السطر الأول
        String? nationalId;
        final idMatch = RegExp(r'\d{10}').firstMatch(line1);
        if (idMatch != null) {
          nationalId = idMatch.group(0);
        } else {
          final digits = line1.replaceAll(RegExp(r'[^\d]'), '');
          if (digits.length >= 10) {
            nationalId = digits.substring(digits.length - 10);
          }
        }

        // 2. استخراج تاريخ الميلاد من السطر الثاني (أول 6 أرقام تعبر عن YYMMDD)
        String? dateOfBirth;
        if (line2.length >= 6) {
          final yy = line2.substring(0, 2);
          final mm = line2.substring(2, 4);
          final dd = line2.substring(4, 6);
          
          final year = int.tryParse(yy);
          final month = int.tryParse(mm);
          final day = int.tryParse(dd);
          
          if (year != null && month != null && day != null) {
            final fullYear = year > 26 ? 1900 + year : 2000 + year;
            dateOfBirth = '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/$fullYear';
          }
        }

        // 3. استخراج الاسم الكامل بالإنجليزية من السطر الثالث
        String? fullName;
        if (line3.contains('<<')) {
          final parts = line3.split('<<');
          final surname = parts[0].replaceAll('<', ' ').trim();
          final givenNames = parts.length > 1 ? parts[1].replaceAll('<', ' ').trim() : '';
          
          fullName = '$givenNames $surname'.trim().replaceAll(RegExp(r'\s+'), ' ');
        }

        if (nationalId != null || dateOfBirth != null || fullName != null) {
          return IdOcrResult(
            fullName: fullName,
            nationalId: nationalId,
            dateOfBirth: dateOfBirth,
          );
        }
      } catch (e) {
        debugPrint('⚠️ Error parsing MRZ lines: $e');
      }
    }
    return null;
  }

  /// استخراج الاسم العربي من وجه الهوية
  String? _extractArabicName(String text) {
    final lines = text.split('\n').map((l) => l.trim()).toList();
    final nameRegex = RegExp(r'^[\u0600-\u06FF\s]+$');
    
    // البحث عن سطر يحتوي على كلمة "الاسم" أو "الإسم" واستخراج الاسم من نفس السطر أو الأسطر التي تليه
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.contains('الاسم') || line.contains('الإسم') || line.contains('الاسم الكامل') || line.contains('الاسم الأول')) {
        // إزالة الكلمة الدلالية والنقطتين
        final content = line.replaceAll(RegExp(r'^.*?(?:الاسم|الإسم|الكامل|الأول)\s*[:：]?\s*'), '').trim();
        if (content.isNotEmpty) {
          final match = RegExp(r'^[\u0600-\u06FF\s]+').firstMatch(content);
          if (match != null) {
            final name = match.group(0)?.trim();
            if (name != null && name.split(' ').where((w) => w.isNotEmpty).length >= 3) {
              return name;
            }
          }
        }
        
        // إذا كان فارغاً أو قصيراً، نفحص السطرين التاليين للبحث عن الاسم
        for (int j = 1; j <= 2; j++) {
          if (i + j < lines.length) {
            final nextLine = lines[i + j];
            if (nameRegex.hasMatch(nextLine)) {
              final words = nextLine.split(' ').where((w) => w.isNotEmpty).toList();
              if (words.length >= 3 && words.length <= 5) {
                return nextLine;
              }
            }
          }
        }
      }
    }

    // كخيار احتياطي، البحث عن سطر يحتوي على 3-5 كلمات عربية متتالية
    for (var line in lines) {
      if (line.contains('المملكة') || line.contains('الأردنية') || line.contains('الهاشمية') || line.contains('بطاقة') || line.contains('الأحوال') || line.contains('المدنية') || line.contains('شخصية') || line.contains('الرقم')) {
        continue;
      }
      if (nameRegex.hasMatch(line)) {
        final words = line.split(' ').where((w) => w.isNotEmpty).toList();
        if (words.length >= 3 && words.length <= 5) {
          return line;
        }
      }
    }
    return null;
  }

  /// استخراج الاسم الإنجليزي من وجه الهوية
  String? _extractEnglishNameFromFront(String text) {
    final lines = text.split('\n').map((l) => l.trim()).toList();
    for (var line in lines) {
      if (line.toLowerCase().contains('name')) {
        final content = line.replaceAll(RegExp(r'^.*?[nN][aA][mM][eE]\s*[:：]?\s*'), '');
        final match = RegExp(r'^[a-zA-Z\s]+').firstMatch(content);
        if (match != null) {
          final name = match.group(0)?.trim();
          if (name != null && name.split(' ').length >= 3) {
            return name;
          }
        }
      }
    }
    return null;
  }

  /// استخراج الرقم الوطني (10 أرقام)
  String? _extractNationalId(String text) {
    final normalizedText = _normalizeDigits(text);
    
    // البحث عن الرقم بعد كلمة "الرقم الوطني" أو "الوطني" أو "الهوية" أو "المدني"
    final idRegex = RegExp(r'(?:الرقم\s+الوطني|الوطني|المدني|الهوية)\s*[:：]?\s*(\d{10})');
    final idMatch = idRegex.firstMatch(normalizedText);
    if (idMatch != null) {
      return idMatch.group(1);
    }

    // البحث العام عن أي 10 أرقام متتالية
    final regExp = RegExp(r'\b\d{10}\b');
    final match = regExp.firstMatch(normalizedText);
    if (match != null) {
      return match.group(0);
    }
    
    // تنظيف كامل والبحث عن 10 أرقام متتالية
    final cleanText = normalizedText.replaceAll(RegExp(r'[^0-9]'), '');
    final cleanRegExp = RegExp(r'\d{10}');
    final cleanMatch = cleanRegExp.firstMatch(cleanText);
    if (cleanMatch != null) {
      return cleanMatch.group(0);
    }

    return null;
  }

  /// استخراج تاريخ الميلاد من ظهر الهوية
  String? _extractDateOfBirth(String text) {
    return _findBirthDateInText(text);
  }

  /// استخراج تاريخ الميلاد من وجه الهوية
  String? _extractDateOfBirthFromFront(String text) {
    final normalizedText = _normalizeDigits(text);
    final dobRegex = RegExp(r'(?:تاريخ\s+الولادة|الولادة)\s*[:：]?\s*(\d{2}/\d{2}/\d{4})');
    final match = dobRegex.firstMatch(normalizedText);
    if (match != null) {
      return match.group(1);
    }
    return _findBirthDateInText(normalizedText);
  }

  String? _findBirthDateInText(String text) {
    final normalizedText = _normalizeDigits(text);
    final dateRegExp = RegExp(
      r'\b(\d{2})[/\-.](\d{2})[/\-.](\d{4})\b|\b(\d{4})[/\-.](\d{2})[/\-.](\d{2})\b',
    );
    
    final matches = dateRegExp.allMatches(normalizedText);
    List<DateTime> foundDates = [];

    for (var match in matches) {
      final dateStr = match.group(0);
      if (dateStr != null) {
        try {
          DateTime? parsedDate = _parseDateString(dateStr);
          if (parsedDate != null) {
            foundDates.add(parsedDate);
          }
        } catch (_) {}
      }
    }

    if (foundDates.isEmpty) return null;

    foundDates.sort((a, b) => a.compareTo(b));
    
    // الأردنيون البالغون سن التسجيل
    final adultLimit = DateTime.now().subtract(const Duration(days: 365 * 12));
    for (var date in foundDates) {
      if (date.isBefore(adultLimit)) {
        return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      }
    }

    final firstDate = foundDates.first;
    return '${firstDate.day.toString().padLeft(2, '0')}/${firstDate.month.toString().padLeft(2, '0')}/${firstDate.year}';
  }

  DateTime? _parseDateString(String dateStr) {
    final clean = dateStr.replaceAll(RegExp(r'[^\d]'), ' ');
    final parts = clean.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length != 3) return null;

    if (parts[0].length == 4) {
      final year = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final day = int.tryParse(parts[2]);
      if (year != null && month != null && day != null) {
        return DateTime(year, month, day);
      }
    } else if (parts[2].length == 4) {
      final day = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final year = int.tryParse(parts[2]);
      if (day != null && month != null && year != null) {
        return DateTime(year, month, day);
      }
    }
    return null;
  }

  void dispose() {
    _textRecognizer.close();
  }
}
