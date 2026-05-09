// [SWREQ-SETUP-UI-010] [IEC 62304 §5.5]
// Adım 1 — Kabin tipi seçimi.
// Sınıf: Class A

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/l10n/l10n_ext.dart';
import 'package:pharmed_client/widgets/cabin_widgets/wizard_cabin_preview.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../notifier/step1_notifier.dart';
import '../notifier/setup_wizard_notifier.dart';
import '../widgets/step_shared_widgets.dart';

part '../widgets/cabin_type_card.dart';
part '../widgets/spec_pill.dart';

class Step1View extends ConsumerWidget {
  const Step1View({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedType = ref.watch(step1NotifierProvider);
    final step1 = ref.read(step1NotifierProvider.notifier);
    final wizard = ref.read(setupWizardNotifierProvider.notifier);

    return Column(
      children: [
        StepHeader(
          badge: 'Adım 1 / 5',
          title: context.l10n.wizard_step1Header,
          subtitle: context.l10n.wizard_step1Subtitle,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(32, 28, 32, 24),
            child: Row(
              spacing: 20.0,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CabinTypeCard(
                    type: CabinType.master,
                    isSelected: selectedType == CabinType.master,
                    onTap: () => step1.select(CabinType.master),
                    visual: WizardCabinPreview(type: WizardCabinPreviewType.standard),
                    specs: [context.l10n.wizard_masterCabinSpec1, context.l10n.wizard_masterCabinSpec2],
                    description: context.l10n.wizard_masterCabinDescription,
                  ),
                ),
                Expanded(
                  child: CabinTypeCard(
                    type: CabinType.mobile,
                    isSelected: selectedType == CabinType.mobile,
                    onTap: () => step1.select(CabinType.mobile),
                    visual: WizardCabinPreview(type: WizardCabinPreviewType.mobile),
                    specs: [context.l10n.wizard_mobileCabinSpec1, context.l10n.wizard_mobileCabinSpec2],
                    description: context.l10n.wizard_mobileCabinDescription,
                  ),
                ),
              ],
            ),
          ),
        ),
        StepFooter(note: context.l10n.wizard_cabinTypeNote, onNext: selectedType != null ? wizard.nextStep : null),
      ],
    );
  }
}
