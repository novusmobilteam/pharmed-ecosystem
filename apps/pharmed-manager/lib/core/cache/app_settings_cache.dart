import 'package:shared_preferences/shared_preferences.dart';

import '../core.dart';

class AppSettingsCache {
  final SharedPreferences _prefs;

  // Constructor'da SharedPreferences instance'ını alıyoruz
  AppSettingsCache(this._prefs);

  // Key'leri sabit (static const) olarak tanımlamak hata payını düşürür
  static const _keyIsFirstRun = 'is_first_run';
  static const _keyAppMode = 'app_mode';
  static const _keyIsAdminMode = 'is_admin_mode';
  static const _keyLanguage = 'app_language';

  bool get isFirstRun => _prefs.getBool(_keyIsFirstRun) ?? true;

  Future<void> setFirstRunDone() async {
    await _prefs.setBool(_keyIsFirstRun, false);
  }

  AppMode? get currentMode {
    final modeName = _prefs.getString(_keyAppMode);
    if (modeName == null) return AppMode.client;

    return AppMode.values.firstWhere((e) => e.name == modeName, orElse: () => AppMode.client);
  }

  Future<void> setCurrentMode(AppMode mode) async {
    await _prefs.setString(_keyAppMode, mode.name);
  }

  bool get isAdminModeActive => _prefs.getBool(_keyIsAdminMode) ?? true;

  Future<void> setAdminMode(bool isActive) async {
    await _prefs.setBool(_keyIsAdminMode, isActive);
  }

  Future<void> clearSettings() async {
    await _prefs.clear();
  }

  AppLanguage getLanguage() {
    final code = _prefs.getString(_keyLanguage);
    return AppLanguage.fromCode(code);
  }

  Future<void> setLanguage(AppLanguage language) async {
    await _prefs.setString(_keyLanguage, language.code);
  }
}
