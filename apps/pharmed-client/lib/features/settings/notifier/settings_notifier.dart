import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../core/cache/app_settings_cache.dart';
import '../../../../core/providers/providers.dart';
import '../../auth/auth.dart';
import 'settings_state.dart';

/// Birim doz çekmecelerde hücre bazlı SKT girişi açık mı (MiadDate system
/// parameter). Refill/sayım ekranları bu provider'ı `ref.watch` ederek
/// SystemParameterKeys'i bilmeden, sadece ilgili değer değiştiğinde
/// rebuild olur (SettingsState'in tamamını watch etmenin aksine).
final isPerCellMiadEnabledProvider = Provider<bool>((ref) {
  final value = ref.watch(
    settingsNotifierProvider.select(
      (s) => s.systemParameters.firstWhereOrNull((p) => p.key == SystemParameterKeys.miadDate)?.value,
    ),
  );
  return value == '1';
});

final settingsNotifierProvider = NotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);

class SettingsNotifier extends Notifier<SettingsState> {
  AppSettingsCache get _cache => ref.read(appSettingsCacheProvider);

  @override
  SettingsState build() {
    _restoreLanguage();
    Future.microtask(_loadSystemParameters);
    return const SettingsState();
  }

  /// Cache'den dili okuyup state'e uygular.
  Future<void> _restoreLanguage() async {
    final code = await _cache.getLanguage();
    if (code == null) return; // kayıt yok → default AppLanguage.turkish
    final language = AppLanguage.fromCode(code);
    if (language == state.language) return;
    state = state.copyWith(language: language);
    ref.read(tokenHolderProvider).setLocale(language.code);
    setCurrentLocale(Locale(language.code));
  }

  /// [SWREQ-UI-SETTINGS-002] Dili değiştirir ve cache'e yazar.
  Future<void> setLanguage(AppLanguage language) async {
    await _cache.saveLanguage(language.code);
    state = state.copyWith(language: language);
    ref.read(tokenHolderProvider).setLocale(language.code);
    setCurrentLocale(Locale(language.code)); // YENİ — contextlessL10n() de senkron olsun
  }

  void setSection(SettingsSection section) {
    state = state.copyWith(activeSection: section);
  }

  // ── Sistem parametreleri (salt okunur) ──────────────────────────────────
  // Client bu parametreleri DÜZENLEMEZ — sadece uygulama açılışında bir kere
  // çekip, dolum/sayım gibi akışlarda okumak için tutar (ör. MiadDate: hücre
  // bazlı SKT girişi açık mı). Yazma/kaydetme sorumluluğu manager'da.
  Future<void> _loadSystemParameters() async {
    if (state.isLoadingSystemParameters) return;

    state = state.copyWith(isLoadingSystemParameters: true, clearSystemParametersError: true);

    final result = await ref.read(getSystemParametersUseCaseProvider).call();

    result.when(
      ok: (value) => state = state.copyWith(systemParameters: value, isLoadingSystemParameters: false),
      error: (error) => state = state.copyWith(isLoadingSystemParameters: false, systemParametersError: error.message),
    );
  }

  /// Ağ hatası, cihaz uyanınca vb. durumlarda manuel yeniden çekmek için.
  Future<void> refreshSystemParameters() => _loadSystemParameters();

  String? getParamValue(String key) => state.systemParameters.firstWhereOrNull((p) => p.key == key)?.value;

  bool getBool(String key) => getParamValue(key) == '1';

  /// [SWREQ-UI-SETTINGS-002] Birim doz çekmecelerde hücre bazlı SKT girişi açık mı.
  /// Dolum akışında (master-refill-flow / cabin-inventory) bu flag'e göre
  /// her bölme için ayrı SKT istenip istenmeyeceği belirlenir.
  bool get isPerCellMiadEnabled => getBool(SystemParameterKeys.miadDate);
  // ─────────────────────────────────────────────────────────────────────────

  /// [DEBUG ONLY] Kabin override'ını set eder.
  /// null → cache'deki (gerçek) kabine dön.
  ///
  /// Bazı servisler istasyon MAC adresine göre veri döndürdüğü ve login
  /// akışı cache'deki stationId'yi parametre olarak gönderdiği için, debug
  /// kabini değiştirmek tek başına yetmez: yeni kabinin stationId'sini de
  /// cache'e yazıp kullanıcıyı logout edip yeniden login'e zorlamamız
  /// gerekiyor — böylece yeni istasyon id'siyle giriş yapılır.
  Future<void> setDebugCabin(Cabin? cabin) async {
    assert(kDebugMode, 'setDebugCabin sadece debug modda çağrılabilir');

    if (cabin == null) {
      state = state.copyWith(clearDebugCabin: true);
      return;
    }

    // 1) Yeni kabin + istasyon id'sini cache'e yaz (sadece debug modda
    //    tetiklendiği için prod akışını etkilemez).
    await _cache.saveCurrentCabinId(cabin.id ?? 0, stationId: cabin.stationId);

    state = state.copyWith(debugCabin: cabin);

    // 2) Kullanıcıyı çıkışa zorla — yeniden login olurken cache'deki
    //    stationId parametre olarak gönderilecek.
    await ref.read(authNotifierProvider.notifier).logout();
  }

  /// [DEBUG ONLY] Kabin listesini API'den çeker.
  /// Settings ekranı açıldığında çağrılır.
  Future<void> loadCabins() async {
    assert(kDebugMode, 'loadCabins sadece debug modda çağrılabilir');
    if (state.isLoadingCabins) return;

    state = state.copyWith(isLoadingCabins: true, clearCabinsError: true);

    final result = await ref.read(getCabinsUseCaseProvider).call();

    result.when(
      ok: (value) => state = state.copyWith(cabins: value, isLoadingCabins: false),
      error: (error) => state = state.copyWith(isLoadingCabins: false, cabinsError: error.message),
    );
  }
}
