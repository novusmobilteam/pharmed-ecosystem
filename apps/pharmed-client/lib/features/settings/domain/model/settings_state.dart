// lib/features/settings/domain/model/settings_state.dart
//
// [SWREQ-UI-SETTINGS-001] [IEC 62304 §5.5]
// Settings modal state modeli.
// Sınıf: Class A

enum SettingsSection { general, appearance, debug }

enum DebugCabinMode { master, mobile }

class SettingsState {
  const SettingsState({this.activeSection = SettingsSection.debug, this.debugCabinMode = DebugCabinMode.master});

  final SettingsSection activeSection;
  final DebugCabinMode debugCabinMode;

  SettingsState copyWith({SettingsSection? activeSection, DebugCabinMode? debugCabinMode}) {
    return SettingsState(
      activeSection: activeSection ?? this.activeSection,
      debugCabinMode: debugCabinMode ?? this.debugCabinMode,
    );
  }
}
