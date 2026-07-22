// lib/features/settings/presentation/state/settings_state.dart
//
// Sınıf: Class A

import 'package:pharmed_core/pharmed_core.dart';

enum SettingsSection { general, appearance, debug }

class SettingsState {
  const SettingsState({
    this.activeSection = SettingsSection.general,
    this.debugCabin,
    this.cabins = const [],
    this.isLoadingCabins = false,
    this.cabinsError,
    this.language = AppLanguage.turkish,
    this.systemParameters = const [],
    this.isLoadingSystemParameters = false,
    this.systemParametersError,
  });

  final SettingsSection activeSection;

  /// [DEBUG ONLY] Runtime kabin override — cache'e dokunulmaz.
  final Cabin? debugCabin;

  /// [DEBUG ONLY] API'den çekilen kabin listesi.
  final List<Cabin> cabins;
  final bool isLoadingCabins;
  final String? cabinsError;
  final AppLanguage language;
  final List<SystemParameter> systemParameters;
  final bool isLoadingSystemParameters;
  final String? systemParametersError;

  SettingsState copyWith({
    SettingsSection? activeSection,
    AppLanguage? language,
    Cabin? debugCabin,
    bool clearDebugCabin = false,
    List<Cabin>? cabins,
    bool? isLoadingCabins,
    String? cabinsError,
    bool clearCabinsError = false,
    List<SystemParameter>? systemParameters,
    bool? isLoadingSystemParameters,
    String? systemParametersError,
    bool clearSystemParametersError = false,
  }) {
    return SettingsState(
      activeSection: activeSection ?? this.activeSection,
      language: language ?? this.language,
      debugCabin: clearDebugCabin ? null : (debugCabin ?? this.debugCabin),
      cabins: cabins ?? this.cabins,
      isLoadingCabins: isLoadingCabins ?? this.isLoadingCabins,
      cabinsError: clearCabinsError ? null : (cabinsError ?? this.cabinsError),
      systemParameters: systemParameters ?? this.systemParameters,
      isLoadingSystemParameters: isLoadingSystemParameters ?? this.isLoadingSystemParameters,
      systemParametersError: clearSystemParametersError ? null : (systemParametersError ?? this.systemParametersError),
    );
  }
}
