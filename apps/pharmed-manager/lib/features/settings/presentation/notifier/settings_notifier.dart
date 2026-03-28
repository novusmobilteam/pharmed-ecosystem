import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../../../../core/core.dart';

import '../../domain/entity/system_parameter.dart';
import '../../domain/repository/i_settings_repository.dart';

class SettingsNotifier extends ChangeNotifier with ApiRequestMixin {
  final ISettingsRepository _repository;

  SettingsNotifier({required ISettingsRepository repository}) : _repository = repository;

  OperationKey fetchOp = OperationKey.fetch();
  OperationKey submitOp = OperationKey.submit();

  bool get isSubmitting => isLoading(submitOp);

  bool get isFirstRun => _repository.isFirstRun;
  AppMode? get currentMode => _repository.currentMode;
  bool get isAdminModeActive => _repository.isAdminModeActive;

  List<SystemParameter> _systemParameters = [];
  List<SystemParameter> get systemParameters => _systemParameters;

  // Değişen ama henüz kaydedilmeyen ayarlar
  final Map<String, String> _draftSettings = {};

  SystemParameter? getParam(String key) => _systemParameters.firstWhereOrNull((p) => p.key == key);

  bool get isPerCellMiadEnabled {
    final value = getValue('MiadDate');
    return value == '1';
  }

  void togglePerCellMiad() {
    final newValue = isPerCellMiadEnabled ? '0' : '1';
    _updateDraft('MiadDate', newValue);
  }

  void getSettings() async {
    await execute(
      fetchOp,
      operation: () => _repository.getSystemParameters(),
      onData: (data) {
        _systemParameters = data;
        notifyListeners();
      },
    );
  }

  Future<void> saveAllChanges({Function(String? message)? onSuccess, Function(String? message)? onFailed}) async {
    if (_draftSettings.isEmpty) return;

    for (var entry in _draftSettings.entries) {
      final originalParam = _systemParameters.firstWhereOrNull((p) => p.key == entry.key);

      if (originalParam == null) continue;

      final updatedParam = originalParam.copyWith(value: entry.value);

      await executeVoid(
        submitOp,
        operation: () => _repository.updateSystemParameter(updatedParam),
        onSuccess: () => onSuccess?.call('Ayarlar başarıyla güncellendi.'),
        onFailed: (error) => onFailed?.call(error.message),
      );
    }

    for (var entry in _draftSettings.entries) {
      final index = _systemParameters.indexWhere((p) => p.key == entry.key);
      if (index != -1) {
        _systemParameters[index] = _systemParameters[index].copyWith(value: entry.value);
      }
    }

    _draftSettings.clear();
    notifyListeners();
  }

  void _updateDraft(String key, String value) {
    _draftSettings[key] = value;
    notifyListeners();
  }

  String getValue(String key) {
    if (_draftSettings.containsKey(key)) {
      return _draftSettings[key]!;
    }
    return _systemParameters.firstWhereOrNull((p) => p.key == key)?.value ?? '';
  }

  Future<void> setFirstRunDone() async {
    await _repository.setFirstRunDone();
    notifyListeners();
  }

  Future<void> setCurrentMode(AppMode mode) async {
    await _repository.setCurrentMode(mode);
    notifyListeners();
  }

  Future<void> setAdminMode(bool isActive) async {
    await _repository.setAdminMode(isActive);
    notifyListeners();
  }

  Future<void> clearSettings() async {
    await _repository.clearSettings();
    notifyListeners();
  }
}
