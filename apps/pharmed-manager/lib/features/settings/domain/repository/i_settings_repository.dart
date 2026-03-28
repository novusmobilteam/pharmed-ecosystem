import '../../../../core/core.dart';
import '../entity/system_parameter.dart';

abstract class ISettingsRepository {
  // Remote
  Future<Result<List<SystemParameter>>> getSystemParameters();
  Future<Result<void>> updateSystemParameter(SystemParameter parameter);

  // Local Persistence
  bool get isFirstRun;
  Future<void> setFirstRunDone();

  AppMode? get currentMode;
  Future<void> setCurrentMode(AppMode mode);

  bool get isAdminModeActive;
  Future<void> setAdminMode(bool isActive);

  Future<void> clearSettings();
}
