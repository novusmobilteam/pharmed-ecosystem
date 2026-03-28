import '../../domain/entity/system_parameter.dart';

import '../../../../core/core.dart';
import '../../domain/repository/i_settings_repository.dart';
import '../datasource/persistence/app_settings_persistence.dart';
import '../datasource/remote/settings_data_source.dart';

class SettingsRepository implements ISettingsRepository {
  final SettingsDataSource _remoteDataSource;
  final AppSettingsPersistence _localPersistence;

  SettingsRepository({
    required SettingsDataSource remoteDataSource,
    required AppSettingsPersistence localPersistence,
  })  : _remoteDataSource = remoteDataSource,
        _localPersistence = localPersistence;

  @override
  Future<Result<List<SystemParameter>>> getSystemParameters() async {
    final res = await _remoteDataSource.getSystemParameters();

    return res.when(
      ok: (list) {
        final entities = list.map((d) => d.toEntity()).toList();
        return Result.ok(entities);
      },
      error: (e) {
        return Result.error(e);
      },
    );
  }

  @override
  Future<Result<void>> updateSystemParameter(SystemParameter parameter) async {
    return _remoteDataSource.updateSystemParameter(parameter.toDTO());
  }

  @override
  bool get isFirstRun => _localPersistence.isFirstRun;

  @override
  Future<void> setFirstRunDone() => _localPersistence.setFirstRunDone();

  @override
  AppMode? get currentMode => _localPersistence.currentMode;

  @override
  Future<void> setCurrentMode(AppMode mode) => _localPersistence.setCurrentMode(mode);

  @override
  bool get isAdminModeActive => _localPersistence.isAdminModeActive;

  @override
  Future<void> setAdminMode(bool isActive) => _localPersistence.setAdminMode(isActive);

  @override
  Future<void> clearSettings() => _localPersistence.clearSettings();
}
