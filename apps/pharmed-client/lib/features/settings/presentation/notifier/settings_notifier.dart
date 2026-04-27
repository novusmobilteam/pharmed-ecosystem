// lib/features/settings/presentation/notifier/settings_notifier.dart
//
// Sınıf: Class A

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../../../core/cache/app_settings_cache.dart';
import '../../../../core/enums/app_language.dart';
import '../../../cabin/cabin.dart';
import '../state/settings_state.dart';

final settingsNotifierProvider = NotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);

class SettingsNotifier extends Notifier<SettingsState> {
  AppSettingsCache get _cache => ref.read(appSettingsCacheProvider);

  @override
  SettingsState build() {
    _restoreLanguage();
    return const SettingsState();
  }

  /// Cache'den dili okuyup state'e uygular.
  Future<void> _restoreLanguage() async {
    final code = await _cache.getLanguage();
    if (code == null) return; // kayıt yok → default AppLanguage.turkish
    final language = AppLanguage.fromCode(code);
    if (language == state.language) return;
    state = state.copyWith(language: language);
  }

  /// [SWREQ-UI-SETTINGS-002] Dili değiştirir ve cache'e yazar.
  Future<void> setLanguage(AppLanguage language) async {
    await _cache.saveLanguage(language.code);
    state = state.copyWith(language: language);
  }

  void setSection(SettingsSection section) {
    state = state.copyWith(activeSection: section);
  }

  /// [DEBUG ONLY] Kabin override'ını set eder.
  /// null → cache'deki kabine dön.
  void setDebugCabin(Cabin? cabin) {
    state = cabin == null ? state.copyWith(clearDebugCabin: true) : state.copyWith(debugCabin: cabin);
  }

  /// [DEBUG ONLY] Kabin listesini API'den çeker.
  /// Settings ekranı açıldığında çağrılır.
  Future<void> loadCabins() async {
    assert(kDebugMode, 'loadCabins sadece debug modda çağrılabilir');
    if (state.isLoadingCabins) return;

    state = state.copyWith(isLoadingCabins: true, clearCabinsError: true);

    final result = await ref.read(getCabinsUseCaseProvider).call();

    result.when(
      success: (cabins) => state = state.copyWith(cabins: cabins, isLoadingCabins: false),
      stale: (cabins, _) => state = state.copyWith(cabins: cabins, isLoadingCabins: false),
      failure: (e) => state = state.copyWith(isLoadingCabins: false, cabinsError: e.message),
    );
  }
}
