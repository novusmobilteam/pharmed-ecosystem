// lib/features/setup_wizard/presentation/steps/step4_view.dart
//
// [SWREQ-SETUP-UI-014] [IEC 62304 §5.5]
// Wizard Adım 4 — Çekmece Yapılandırması.
// Master kabin: seri port üzerinden cihaz taraması.
// Mobil kabin: çekmece sayısı + her çekmece için satır/sütun girişi + port keşfi.
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../l10n/l10n_ext.dart';
import '../notifier/setup_wizard_notifier.dart';
import '../notifier/step1_notifier.dart';
import '../notifier/step3_notifier.dart';
import '../notifier/step4_master_notifier.dart';
import '../notifier/step4_mobile_notifier.dart';
import '../state/step4_master_state.dart';
import '../widgets/step_shared_widgets.dart';

part '../widgets/master_drawer_scan_view.dart';
part '../widgets/mobile_drawer_config_view.dart';

class Step4View extends ConsumerWidget {
  const Step4View({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cabinType = ref.watch(step1NotifierProvider);
    final stationType = ref.watch(step3NotifierProvider.select((s) => s.serviceScope?.station.type));
    final wizard = ref.read(setupWizardNotifierProvider.notifier);

    final isMobile = cabinType == CabinType.mobile && stationType == StationType.patientBased;

    final subtitle = isMobile
        ? 'Mobil kabinin çekmece sayısını, iç bölümlerini ve port bağlantılarını tanımlayın.'
        : 'Cihazdan kabin iç yapısı otomatik okunacaktır.';

    final isComplete = isMobile ? true : ref.watch(step4MasterNotifierProvider.select((s) => s.isComplete));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StepHeader(badge: 'Adım 4 / 5', title: 'Çekmece Yapılandırması', subtitle: subtitle),
        Expanded(child: isMobile ? const MobileDrawerConfigView() : const MasterDrawerScanView()),
        StepFooter(onBack: wizard.previousStep, onNext: isComplete ? wizard.nextStep : null),
      ],
    );
  }
}
