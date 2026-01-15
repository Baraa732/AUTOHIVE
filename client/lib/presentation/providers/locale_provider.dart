import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleNotifier extends StateNotifier<Locale> {
  static const String _localeKey = 'locale';
  
  LocaleNotifier() : super(const Locale('en')) {
    _loadLocale();
  }
  
  void _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_localeKey) ?? 'en';
    state = Locale(languageCode);
  }
  
  void setLocale(Locale locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
  }
  
  void toggleLocale() {
    setLocale(state.languageCode == 'en' ? const Locale('ar') : const Locale('en'));
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});
