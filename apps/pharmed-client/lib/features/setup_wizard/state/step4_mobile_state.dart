// [SWREQ-SETUP-UI-011] [IEC 62304 §5.5]
// Setup Wizard Adım 4 — mobil kabin çekmece yapılandırma state tanımları.
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class Step4MobileState {
  Step4MobileState({WizardMobileLayout? mobileLayout})
    : mobileLayout = mobileLayout ?? WizardMobileLayout.defaultLayout();

  final WizardMobileLayout mobileLayout;

  Step4MobileState copyWith({WizardMobileLayout? mobileLayout}) {
    return Step4MobileState(mobileLayout: mobileLayout ?? this.mobileLayout);
  }
}
