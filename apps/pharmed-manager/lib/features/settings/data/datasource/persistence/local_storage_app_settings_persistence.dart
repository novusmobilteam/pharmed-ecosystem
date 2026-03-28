import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/core.dart';
import 'app_settings_persistence.dart';

class LocalStorageAppSettingsPersistence implements AppSettingsPersistence {
  final SharedPreferences _prefs;

  // Constructor'da SharedPreferences instance'ını alıyoruz
  LocalStorageAppSettingsPersistence(this._prefs);

  // Key'leri sabit (static const) olarak tanımlamak hata payını düşürür
  static const _keyIsFirstRun = 'is_first_run';
  static const _keyAppMode = 'app_mode';
  static const _keyIsAdminMode = 'is_admin_mode';

  @override
  bool get isFirstRun => _prefs.getBool(_keyIsFirstRun) ?? true;

  @override
  Future<void> setFirstRunDone() async {
    await _prefs.setBool(_keyIsFirstRun, false);
  }

  @override
  AppMode? get currentMode {
    final modeName = _prefs.getString(_keyAppMode);
    if (modeName == null) return AppMode.client;

    return AppMode.values.firstWhere((e) => e.name == modeName, orElse: () => AppMode.client);
  }

  @override
  Future<void> setCurrentMode(AppMode mode) async {
    await _prefs.setString(_keyAppMode, mode.name);
  }

  @override
  bool get isAdminModeActive => _prefs.getBool(_keyIsAdminMode) ?? true;

  @override
  Future<void> setAdminMode(bool isActive) async {
    await _prefs.setBool(_keyIsAdminMode, isActive);
  }

  @override
  Future<void> clearSettings() async {
    await _prefs.clear();
  }
}
