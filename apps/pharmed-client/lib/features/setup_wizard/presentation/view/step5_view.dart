// [SWREQ-SETUP-UI-015] [IEC 62304 §5.5]
// Wizard Adım 5 — Özet & Tamamla.
// Kullanıcı tüm adımlarda girdiği bilgileri gözden geçirir ve onaylar.
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../l10n/l10n_ext.dart';
import '../../domain/entity/cabin_setup_config.dart';
import '../../domain/entity/wizard_mobile_layout.dart';
import '../notifier/setup_wizard_notifier.dart';
import '../notifier/step1_notifier.dart';
import '../notifier/step2_notifier.dart';
import '../notifier/step3_notifier.dart';
import '../notifier/step4_master_notifier.dart';
import '../notifier/step4_mobile_notifier.dart';
import '../widgets/step_shared_widgets.dart';

part '../widgets/summary_card.dart';
part '../widgets/summary_cards.dart';

class Step5View extends ConsumerWidget {
  const Step5View({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cabinType = ref.watch(step1NotifierProvider);
    final step2 = ref.watch(step2NotifierProvider);
    final step3 = ref.watch(step3NotifierProvider);
    final step4Master = ref.watch(step4MasterNotifierProvider);
    final step4Mobile = ref.watch(step4MobileNotifierProvider);
    final wizard = ref.read(setupWizardNotifierProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StepHeader(
          badge: 'Adım 5 / 5',
          title: context.l10n.wizard_step5Header,
          subtitle: context.l10n.wizard_step5Subtitle,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: CabinInfoCard(cabinType: cabinType, basicInfo: step2.basicInfo),
                    ),
                    const SizedBox(width: 16),
                    Expanded(child: ServiceScopeCard(serviceScope: step3.serviceScope)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: DrawerStructureCard(
                        cabinType: cabinType,
                        scannedLayout: step4Master.scannedLayout,
                        mobileLayout: step4Mobile.mobileLayout,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CabinPreviewCard(
                        cabinType: cabinType,
                        mobileLayout: step4Mobile.mobileLayout,
                        scannedLayout: step4Master.scannedLayout,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        StepFooter(onBack: wizard.previousStep, onNext: wizard.finish, nextLabel: 'Kurulumu Tamamla'),
      ],
    );
  }
}
