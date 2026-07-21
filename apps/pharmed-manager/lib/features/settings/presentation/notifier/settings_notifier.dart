import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../../../../core/core.dart';
import '../../domain/entity/system_parameter.dart';
import '../../domain/repository/i_settings_repository.dart';

class SettingsNotifier extends ChangeNotifier with ApiRequestMixin {
  final ISettingsRepository _repository;
  final TokenHolder _tokenHolder;

  SettingsNotifier({required ISettingsRepository repository, required TokenHolder tokenHolder})
    : _repository = repository,
      _tokenHolder = tokenHolder {
    _language = _repository.getLanguage();
    _tokenHolder.setLocale(_language.code);
  }

  OperationKey fetchOp = OperationKey.fetch();
  OperationKey submitOp = OperationKey.submit();

  bool get isSubmitting => isLoading(submitOp);

  bool get isFirstRun => _repository.isFirstRun;
  AppMode? get currentMode => _repository.currentMode;
  bool get isAdminModeActive => _repository.isAdminModeActive;

  // ── Dil ──────────────────────────────────────────────────────────────────
  late AppLanguage _language;
  AppLanguage get language => _language;

  Future<void> setLanguage(AppLanguage lang) async {
    if (_language == lang) return;
    _language = lang;
    await _repository.setLanguage(lang);
    _tokenHolder.setLocale(lang.code);
    notifyListeners();
  }
  // ─────────────────────────────────────────────────────────────────────────

  List<SystemParameter> _systemParameters = [];
  List<SystemParameter> get systemParameters => _systemParameters;

  final Map<String, String> _draftSettings = {};

  SystemParameter? getParam(String key) => _systemParameters.firstWhereOrNull((p) => p.key == key);

  bool get isPerCellMiadEnabled => getValue('MiadDate') == '1';

  void togglePerCellMiad() {
    _updateDraft('MiadDate', isPerCellMiadEnabled ? '0' : '1');
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

    for (final entry in _draftSettings.entries) {
      final originalParam = _systemParameters.firstWhereOrNull((p) => p.key == entry.key);
      if (originalParam == null) continue;

      await executeVoid(
        submitOp,
        operation: () => _repository.updateSystemParameter(originalParam.copyWith(value: entry.value)),
        onSuccess: () => onSuccess?.call(null),
        onFailed: (error) => onFailed?.call(error.message),
      );
    }

    for (final entry in _draftSettings.entries) {
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
    if (_draftSettings.containsKey(key)) return _draftSettings[key]!;
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
