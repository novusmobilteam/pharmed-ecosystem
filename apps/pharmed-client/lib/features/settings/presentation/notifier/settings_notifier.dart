// lib/features/settings/presentation/notifier/settings_notifier.dart
//
// Sınıf: Class A

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/core/cache/app_settings_cache.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../../../core/providers/providers.dart';
import '../state/settings_state.dart';

final settingsNotifierProvider = NotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);

class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() => const SettingsState();

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
