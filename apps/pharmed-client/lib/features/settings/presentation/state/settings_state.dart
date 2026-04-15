// lib/features/settings/presentation/state/settings_state.dart
//
// Sınıf: Class A

import 'package:pharmed_core/pharmed_core.dart';

enum SettingsSection { general, appearance, debug }

class SettingsState {
  const SettingsState({
    this.activeSection = SettingsSection.debug,
    this.debugCabin,
    this.cabins = const [],
    this.isLoadingCabins = false,
    this.cabinsError,
  });

  final SettingsSection activeSection;

  /// [DEBUG ONLY] Runtime kabin override — cache'e dokunulmaz.
  final Cabin? debugCabin;

  /// [DEBUG ONLY] API'den çekilen kabin listesi.
  final List<Cabin> cabins;
  final bool isLoadingCabins;
  final String? cabinsError;

  SettingsState copyWith({
    SettingsSection? activeSection,
    Cabin? debugCabin,
    bool clearDebugCabin = false,
    List<Cabin>? cabins,
    bool? isLoadingCabins,
    String? cabinsError,
    bool clearCabinsError = false,
  }) {
    return SettingsState(
      activeSection: activeSection ?? this.activeSection,
      debugCabin: clearDebugCabin ? null : (debugCabin ?? this.debugCabin),
      cabins: cabins ?? this.cabins,
      isLoadingCabins: isLoadingCabins ?? this.isLoadingCabins,
      cabinsError: clearCabinsError ? null : (cabinsError ?? this.cabinsError),
    );
  }
}
