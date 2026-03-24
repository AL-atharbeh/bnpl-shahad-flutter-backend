import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  static final LanguageService _instance = LanguageService._internal();
  factory LanguageService() => _instance;
  LanguageService._internal();

  Locale _currentLocale = const Locale('ar', ''); // Default to Arabic
  static const String _languageKey = 'selected_language';

  // Initialize and load saved language
  Future<void> initializeLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString(_languageKey) ?? 'ar'; // Default to Arabic
    _currentLocale = Locale(savedLanguage, '');
    notifyListeners();
  }

  Locale get currentLocale => _currentLocale;
  bool get isArabic => _currentLocale.languageCode == 'ar';
  bool get isEnglish => _currentLocale.languageCode == 'en';

  Future<void> toggleLanguage() async {
    final newLanguage = _currentLocale.languageCode == 'ar' ? 'en' : 'ar';
    _currentLocale = Locale(newLanguage, '');
    
    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, newLanguage);
    
    notifyListeners();
  }

  Future<void> setLanguage(String languageCode) async {
    _currentLocale = Locale(languageCode, '');
    
    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
    
    notifyListeners();
  }

  // Get text direction based on current language
  TextDirection get textDirection => isArabic ? TextDirection.rtl : TextDirection.ltr;
  
  // Get text alignment based on current language
  TextAlign get textAlign => isArabic ? TextAlign.right : TextAlign.left;
  
  // Get text alignment for center content
  TextAlign get centerTextAlign => TextAlign.center;
  
  // Get appropriate margin/padding for current language
  EdgeInsetsGeometry getDirectionalPadding({
    double start = 0,
    double top = 0,
    double end = 0,
    double bottom = 0,
  }) {
    return isArabic 
        ? EdgeInsetsDirectional.fromSTEB(start, top, end, bottom)
        : EdgeInsetsDirectional.fromSTEB(start, top, end, bottom);
  }
}
