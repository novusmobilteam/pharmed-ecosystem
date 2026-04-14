// lib/features/settings/presentation/notifier/settings_notifier.dart
//
// [SWREQ-UI-SETTINGS-001] [IEC 62304 §5.5]
// Sınıf: Class A

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/model/settings_state.dart';

class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() => const SettingsState();

  void setSection(SettingsSection section) {
    state = state.copyWith(activeSection: section);
  }

  void setDebugCabinMode(DebugCabinMode mode) {
    state = state.copyWith(debugCabinMode: mode);
  }
}
