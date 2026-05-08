// [SWREQ-SETUP-UI-011] [IEC 62304 §5.5]
// Setup Wizard Adım 4 — mobil kabin çekmece yapılandırma state yöneticisi.
// Sınıf: Class B

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/step4_mobile_state.dart';

final step4MobileNotifierProvider = NotifierProvider<Step4MobileNotifier, Step4MobileState>(Step4MobileNotifier.new);

class Step4MobileNotifier extends Notifier<Step4MobileState> {
  @override
  Step4MobileState build() => Step4MobileState();

  /// [SWREQ-SETUP-UI-012]
  void updateDrawerCount(int count) {
    state = state.copyWith(mobileLayout: state.mobileLayout.withDrawerCount(count));
  }

  /// [SWREQ-SETUP-UI-013]
  void updateDrawerConfig(int drawerIndex, List<int> rowColumns) {
    state = state.copyWith(mobileLayout: state.mobileLayout.withDrawerConfig(drawerIndex, rowColumns));
  }

  /// [SWREQ-SETUP-UI-015]
  void toggleSameConfig({required bool value}) {
    state = state.copyWith(mobileLayout: state.mobileLayout.withSameConfig(value));
  }
}
