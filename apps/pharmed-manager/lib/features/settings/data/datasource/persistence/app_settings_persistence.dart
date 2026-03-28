import '../../../../../core/core.dart';

abstract class AppSettingsPersistence {
  bool get isFirstRun;
  Future<void> setFirstRunDone();

  AppMode? get currentMode;
  Future<void> setCurrentMode(AppMode mode);

  bool get isAdminModeActive;
  Future<void> setAdminMode(bool isActive);

  Future<void> clearSettings(); // Tüm ayarları sıfırlamak için
}
