import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'strings.dart';

/// Holds the chosen language. Arabic is the default, as on the portal.
class LanguageService extends ChangeNotifier {
  static const _prefsKey = 'merchant_language';

  String _code = 'ar';
  String get code => _code;
  bool get isArabic => _code == 'ar';
  Locale get locale => Locale(_code);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _code = prefs.getString(_prefsKey) ?? 'ar';
  }

  Future<void> toggle() => setLanguage(isArabic ? 'en' : 'ar');

  Future<void> setLanguage(String code) async {
    if (code == _code) return;
    _code = code;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, code);
  }

  String tr(String key) => kStrings[_code]?[key] ?? kStrings['en']?[key] ?? key;
}

extension TrContext on BuildContext {
  /// Looks up a string and rebuilds the caller when the language changes.
  String tr(String key) => watch<LanguageService>().tr(key);

  /// Same lookup without subscribing, for callbacks and async code.
  String trNow(String key) => read<LanguageService>().tr(key);

  bool get isArabic => watch<LanguageService>().isArabic;
}
