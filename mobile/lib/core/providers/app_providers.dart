import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────────────────────
// KEYS
// ─────────────────────────────────────────────────────────────────────────────
const _kTheme = 'app_theme_mode';   // 'light' | 'dark' | 'system'
const _kLang  = 'app_language';     // 'sw' | 'en'

// ─────────────────────────────────────────────────────────────────────────────
// THEME PROVIDER
// ─────────────────────────────────────────────────────────────────────────────
class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system);

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    final saved = p.getString(_kTheme) ?? 'system';
    state = _parse(saved);
  }

  Future<void> set(ThemeMode mode) async {
    state = mode;
    final p = await SharedPreferences.getInstance();
    await p.setString(_kTheme, _key(mode));
  }

  Future<void> toggle() async {
    // light → dark → system → light ...
    final next = state == ThemeMode.light
        ? ThemeMode.dark
        : state == ThemeMode.dark
            ? ThemeMode.system
            : ThemeMode.light;
    await set(next);
  }

  static ThemeMode _parse(String s) {
    switch (s) {
      case 'dark':   return ThemeMode.dark;
      case 'light':  return ThemeMode.light;
      default:       return ThemeMode.system;
    }
  }

  static String _key(ThemeMode m) {
    switch (m) {
      case ThemeMode.dark:   return 'dark';
      case ThemeMode.light:  return 'light';
      default:               return 'system';
    }
  }
}

final themeProvider =
    StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) => ThemeNotifier());

// ─────────────────────────────────────────────────────────────────────────────
// LANGUAGE PROVIDER
// ─────────────────────────────────────────────────────────────────────────────
class LanguageNotifier extends StateNotifier<Locale> {
  LanguageNotifier() : super(const Locale('sw'));

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    final lang = p.getString(_kLang) ?? 'sw';
    state = Locale(lang);
  }

  Future<void> set(String langCode) async {
    state = Locale(langCode);
    final p = await SharedPreferences.getInstance();
    await p.setString(_kLang, langCode);
  }

  Future<void> toggle() async {
    await set(state.languageCode == 'sw' ? 'en' : 'sw');
  }

  bool get isSw => state.languageCode == 'sw';
  bool get isEn => state.languageCode == 'en';
}

final languageProvider =
    StateNotifierProvider<LanguageNotifier, Locale>(
        (ref) => LanguageNotifier());

// Convenience: current language code string
final langCodeProvider = Provider<String>(
  (ref) => ref.watch(languageProvider).languageCode,
);
