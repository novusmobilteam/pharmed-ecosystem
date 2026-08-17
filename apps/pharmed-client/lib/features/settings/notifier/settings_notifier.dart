// [SWREQ-UI-SETTINGS-001] [IEC 62304 §5.5]
// Uygulama ayarları ve salt-okunur sistem parametreleri.
// Sınıf: Class B

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

import '../../../../core/cache/app_settings_cache.dart';
import '../../auth/auth.dart';

enum SettingsSection { general, appearance, debug }

class SettingsNotifier extends ChangeNotifier {
  SettingsNotifier({
    required AppSettingsCache cache,
    required TokenHolder tokenHolder,
    required GetSystemParametersUseCase getSystemParameters,
    required GetCabinsUseCase getCabins,
    required AuthNotifier authNotifier,
  }) : _cache = cache,
       _tokenHolder = tokenHolder,
       _getSystemParameters = getSystemParameters,
       _getCabins = getCabins,
       _authNotifier = authNotifier {
    unawaited(_restoreLanguage());
    unawaited(_loadSystemParameters());
  }

  final AppSettingsCache _cache;
  final TokenHolder _tokenHolder;
  final GetSystemParametersUseCase _getSystemParameters;
  final GetCabinsUseCase _getCabins;
  final AuthNotifier _authNotifier;

  bool _isDisposed = false;

  void _notify() {
    if (_isDisposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  SettingsSection _activeSection = SettingsSection.general;
  SettingsSection get activeSection => _activeSection;

  /// [DEBUG ONLY] Runtime kabin override — cache'e dokunulmaz.
  Cabin? _debugCabin;
  Cabin? get debugCabin => _debugCabin;

  /// [DEBUG ONLY] API'den çekilen kabin listesi.
  List<Cabin> _cabins = const [];
  List<Cabin> get cabins => _cabins;

  bool _isLoadingCabins = false;
  bool get isLoadingCabins => _isLoadingCabins;

  String? _cabinsError;
  String? get cabinsError => _cabinsError;

  AppLanguage _language = AppLanguage.turkish;
  AppLanguage get language => _language;

  List<SystemParameter> _systemParameters = const [];
  List<SystemParameter> get systemParameters => _systemParameters;

  bool _isLoadingSystemParameters = false;
  bool get isLoadingSystemParameters => _isLoadingSystemParameters;

  String? _systemParametersError;
  String? get systemParametersError => _systemParametersError;

  /// Efektif cihaz modu — debug override varsa (debug modda) onu, yoksa
  /// cache'teki kayıtlı modu döner. null → kurulum henüz yapılmamış.
  ///
  /// Önceki deviceModeProvider/cachedDeviceModeProvider'ın (Riverpod) yerine
  /// geçer — debugCabin zaten bu notifier'ın kendi state'inde olduğu için
  /// ayrı bir "watch" mekanizmasına gerek kalmadı.
  Future<CabinType?> getDeviceMode() async {
    if (kDebugMode) {
      final debugCabin = _debugCabin;
      if (debugCabin != null) return debugCabin.type;
    }
    return _getCachedDeviceMode();
  }

  Future<CabinType?> _getCachedDeviceMode() async {
    final raw = await _cache.getDeviceMode();
    if (raw == null) return null;
    return CabinType.values.firstWhereOrNull((t) => t.name == raw || 'CabinType.${t.name}' == raw);
  }

  // ── Dil ──────────────────────────────────────────────────────────

  /// Cache'den dili okuyup state'e uygular.
  Future<void> _restoreLanguage() async {
    final code = await _cache.getLanguage();
    if (_isDisposed) return;
    if (code == null) return; // kayıt yok → default AppLanguage.turkish
    final language = AppLanguage.fromCode(code);
    if (language == _language) return;
    _language = language;
    _tokenHolder.setLocale(language.code);
    _notify();
  }

  /// [SWREQ-UI-SETTINGS-002] Dili değiştirir ve cache'e yazar.
  Future<void> setLanguage(AppLanguage language) async {
    await _cache.saveLanguage(language.code);
    if (_isDisposed) return;
    _language = language;
    _tokenHolder.setLocale(language.code);
    _notify();
  }

  void setSection(SettingsSection section) {
    _activeSection = section;
    _notify();
  }

  // ── Sistem parametreleri (salt okunur) ──────────────────────────
  // Client bu parametreleri DÜZENLEMEZ — sadece uygulama açılışında bir kere
  // çekip, dolum/sayım gibi akışlarda okumak için tutar (ör. MiadDate: hücre
  // bazlı SKT girişi açık mı). Yazma/kaydetme sorumluluğu manager'da.
  Future<void> _loadSystemParameters() async {
    if (_isLoadingSystemParameters) return;

    _isLoadingSystemParameters = true;
    _systemParametersError = null;
    _notify();

    final result = await _getSystemParameters.call();
    if (_isDisposed) return;

    result.when(
      ok: (value) {
        _systemParameters = value;
        _isLoadingSystemParameters = false;
      },
      error: (error) {
        _isLoadingSystemParameters = false;
        _systemParametersError = error.message;
      },
    );
    _notify();
  }

  /// Ağ hatası, cihaz uyanınca vb. durumlarda manuel yeniden çekmek için.
  Future<void> refreshSystemParameters() => _loadSystemParameters();

  String? getParamValue(String key) => _systemParameters.firstWhereOrNull((p) => p.key == key)?.value;

  bool getBool(String key) => getParamValue(key) == '1';

  /// [SWREQ-UI-SETTINGS-002] Birim doz çekmecelerde hücre bazlı SKT girişi açık mı.
  /// Dolum akışında (master-refill-flow / cabin-inventory) bu flag'e göre
  /// her bölme için ayrı SKT istenip istenmeyeceği belirlenir.
  bool get isPerCellMiadEnabled => getBool(SystemParameterKeys.miadDate);

  // ── Debug ────────────────────────────────────────────────────────

  /// [DEBUG ONLY] Kabin override'ını set eder.
  /// null → cache'deki (gerçek) kabine dön.
  Future<void> setDebugCabin(Cabin? cabin) async {
    assert(kDebugMode, 'setDebugCabin sadece debug modda çağrılabilir');

    if (cabin == null) {
      _debugCabin = null;
      _notify();
      return;
    }

    // 1) Yeni kabin + istasyon id'sini cache'e yaz (sadece debug modda
    //    tetiklendiği için prod akışını etkilemez).
    await _cache.saveCurrentCabinId(cabin.id ?? 0, stationId: cabin.stationId);
    if (_isDisposed) return;

    _debugCabin = cabin;
    _notify();

    // 2) Kullanıcıyı çıkışa zorla — yeniden login olurken cache'deki
    //    stationId parametre olarak gönderilecek.
    await _authNotifier.logout();
  }

  /// [DEBUG ONLY] Kabin listesini API'den çeker.
  /// Settings ekranı açıldığında çağrılır.
  Future<void> loadCabins() async {
    assert(kDebugMode, 'loadCabins sadece debug modda çağrılabilir');
    if (_isLoadingCabins) return;

    _isLoadingCabins = true;
    _cabinsError = null;
    _notify();

    final result = await _getCabins.call();
    if (_isDisposed) return;

    result.when(
      ok: (value) {
        _cabins = value;
        _isLoadingCabins = false;
      },
      error: (error) {
        _isLoadingCabins = false;
        _cabinsError = error.message;
      },
    );
    _notify();
  }
}
