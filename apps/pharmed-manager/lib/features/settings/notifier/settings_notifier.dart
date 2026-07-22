import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../../../core/core.dart';
import 'section_ids.dart';

class SettingsNotifier extends ChangeNotifier with ApiRequestMixin {
  final GetSystemParametersUseCase _getSystemParametersUseCase;
  final UpdateSystemParametersUseCase _updateSystemParametersUseCase;
  final AppSettingsCache _cache;
  final TokenHolder _tokenHolder;

  SettingsNotifier({
    required GetSystemParametersUseCase getSystemParametersUseCase,
    required UpdateSystemParametersUseCase updateSystemParametersUseCase,
    required AppSettingsCache cache,
    required TokenHolder tokenHolder,
  }) : _getSystemParametersUseCase = getSystemParametersUseCase,
       _updateSystemParametersUseCase = updateSystemParametersUseCase,
       _cache = cache,
       _tokenHolder = tokenHolder {
    _language = _cache.getLanguage();
    _tokenHolder.setLocale(_language.code);
  }

  OperationKey fetchOp = OperationKey.fetch();
  OperationKey submitOp = OperationKey.submit();

  bool get isSubmitting => isLoading(submitOp);

  // ── Modal section state ──────────────────────────────────────────────────
  // Section geçişi burada tutuluyor çünkü zaten modal açıkken tek bir
  // notifier üzerinden hem draft değerler hem dirty flag hem de section
  // yönetiliyor — ayrı bir "SettingsModalController" açmak bu aşamada
  // gereksiz bölünme olurdu.
  String _activeSectionId = SettingsSectionIds.general;
  String get activeSectionId => _activeSectionId;

  void goToSection(String id) {
    if (_activeSectionId == id) return;
    _activeSectionId = id;
    notifyListeners();
  }

  bool get isDirty => _draftSettings.isNotEmpty;

  /// "İptal" — kaydedilmemiş taslak değişiklikleri atar, sunucudaki/son
  /// çekilen değerlere geri döner.
  void discardChanges() {
    _draftSettings.clear();
    notifyListeners();
  }
  // ─────────────────────────────────────────────────────────────────────────

  // ── Dil ──────────────────────────────────────────────────────────────────
  late AppLanguage _language;
  AppLanguage get language => _language;

  Future<void> setLanguage(AppLanguage lang) async {
    if (_language == lang) return;
    _language = lang;
    await _cache.setLanguage(lang);
    _tokenHolder.setLocale(lang.code);
    notifyListeners();
  }
  // ─────────────────────────────────────────────────────────────────────────

  List<SystemParameter> _systemParameters = [];
  List<SystemParameter> get systemParameters => _systemParameters;

  final Map<String, String> _draftSettings = {};

  SystemParameter? getParam(String key) => _systemParameters.firstWhereOrNull((p) => p.key == key);

  // ── Genel amaçlı tip erişimi ────────────────────────────────────────────
  // Her yeni system parameter için notifier'a özel getter+setter yazmak
  // yerine, view'lar doğrudan bu yardımcıları + SystemParameterKeys sabitlerini
  // kullanır. Domain-anlamlı bir flag (örn. isPerCellMiadEnabled gibi başka
  // ekranlarda da okunacaksa) bunun üstüne ince bir sarmalayıcı olarak kalır.
  bool getBool(String key) => getValue(key) == '1';
  void setBool(String key, bool value) => _updateDraft(key, value ? '1' : '0');

  int? getInt(String key) => int.tryParse(getValue(key));
  void setInt(String key, int value) => _updateDraft(key, value.toString());
  // ─────────────────────────────────────────────────────────────────────────

  bool get isPerCellMiadEnabled => getBool(SystemParameterKeys.miadDate);

  void togglePerCellMiad() {
    setBool(SystemParameterKeys.miadDate, !isPerCellMiadEnabled);
  }

  void getSettings() async {
    await execute(
      fetchOp,
      operation: () => _getSystemParametersUseCase.call(),
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
        operation: () => _updateSystemParametersUseCase.call(originalParam.copyWith(value: entry.value)),
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
}
