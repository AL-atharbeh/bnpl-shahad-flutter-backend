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

      // 2. معالجة الوجه الأمامي (لاستخراج الاسم بالعربية أو ملء الحقول الناقصة)
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

        // ملء الرقم الوطني إذا لم يستخرج من الخلف
        if (nationalId == null) {
          nationalId = _extractNationalId(frontRecognizedText.text);
        }

        // ملء تاريخ الميلاد من الأمام (لأن تاريخ الميلاد موجود أيضاً في وجه الهوية الأردنية)
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

  /// تحليل الـ MRZ (Machine Readable Zone) من الوجه الخلفي للهوية
  IdOcrResult? _parseMrz(String text) {
    // تقسيم النص إلى أسطر وتنظيف المسافات الفارغة
    final lines = text.split('\n')
        .map((l) => l.trim().replaceAll(' ', ''))
        .where((l) => l.isNotEmpty)
        .toList();
    
    // البحث عن 3 أسطر متتالية تمثل الـ MRZ للهوية (صيغة TD1 تتكون من 3 أسطر طول كل منها 30 حرفاً)
    List<String> mrzLines = [];
    for (var line in lines) {
      // إزالة أي رموز غير مرغوبة والتأكد من الطول ووجود علامة '<'
      if (line.contains('<') && line.length >= 26 && line.length <= 34) {
        mrzLines.add(line);
      }
    }

    if (mrzLines.length < 3) {
      // محاولة البحث عن الأسطر بشكل منفصل إذا لم تكن مرتبة
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

        // 1. استخراج الرقم الوطني من السطر الأول (في الهوية الأردنية يكون الرقم الوطني في الجزء الأخير)
        String? nationalId;
        final idMatch = RegExp(r'\d{10}').firstMatch(line1);
        if (idMatch != null) {
          nationalId = idMatch.group(0);
        } else {
          // تنظيف الحروف والإبقاء على الأرقام فقط والبحث عن 10 أرقام متتالية
          final digits = line1.replaceAll(RegExp(r'[^\d]'), '');
          if (digits.length >= 10) {
            // الرقم الوطني غالباً في النهاية
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
    
    // البحث عن سطر يحتوي على كلمة "الاسم" أو "الإسم" واستخراج الاسم من نفس السطر
    for (var line in lines) {
      if (line.contains('الاسم') || line.contains('الإسم')) {
        // إزالة الكلمة الدلالية والنقطتين
        final content = line.replaceAll(RegExp(r'^.*?(?:الاسم|الإسم)\s*[:：]?\s*'), '');
        // أخذ الأحرف العربية والمسافات فقط
        final match = RegExp(r'^[\u0600-\u06FF\s]+').firstMatch(content);
        if (match != null) {
          final name = match.group(0)?.trim();
          if (name != null && name.split(' ').where((w) => w.isNotEmpty).length >= 3) {
            return name;
          }
        }
      }
    }

    // كخيار احتياطي، البحث عن سطر يحتوي على 3-4 كلمات عربية متتالية
    final arabicRegExp = RegExp(r'^[\u0600-\u06FF\s]+$');
    for (var line in lines) {
      if (line.contains('المملكة') || line.contains('الأردنية') || line.contains('الهاشمية') || line.contains('بطاقة') || line.contains('الأحوال')) {
        continue;
      }
      if (arabicRegExp.hasMatch(line)) {
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
    // البحث عن الرقم بعد كلمة "الرقم الوطني"
    final idRegex = RegExp(r'(?:الرقم\s+الوطني|الوطني)\s*[:：]?\s*(\d{10})');
    final idMatch = idRegex.firstMatch(text);
    if (idMatch != null) {
      return idMatch.group(1);
    }

    // البحث العام عن أي 10 أرقام متتالية
    final regExp = RegExp(r'\b\d{10}\b');
    final match = regExp.firstMatch(text);
    if (match != null) {
      return match.group(0);
    }
    
    // تنظيف كامل
    final cleanText = text.replaceAll(RegExp(r'[^0-9]'), '');
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

  /// استخراج تاريخ الميلاد من وجه الهوية (لأن الهوية الأردنية تحتوي على تاريخ الميلاد في الوجه الأمامي أيضاً)
  String? _extractDateOfBirthFromFront(String text) {
    final dobRegex = RegExp(r'(?:تاريخ\s+الولادة|الولادة)\s*[:：]?\s*(\d{2}/\d{2}/\d{4})');
    final match = dobRegex.firstMatch(text);
    if (match != null) {
      return match.group(1);
    }
    return _findBirthDateInText(text);
  }

  String? _findBirthDateInText(String text) {
    final dateRegExp = RegExp(
      r'\b(\d{2})[/\-.](\d{2})[/\-.](\d{4})\b|\b(\d{4})[/\-.](\d{2})[/\-.](\d{2})\b',
    );
    
    final matches = dateRegExp.allMatches(text);
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
