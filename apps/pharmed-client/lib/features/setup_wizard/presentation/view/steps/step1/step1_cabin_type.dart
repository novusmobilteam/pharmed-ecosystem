// [SWREQ-SETUP-UI-010]
// Adım 1 — Kabin tipi seçimi.
// Standart veya Mobil kabin seçim kartı.
// Sınıf: Class A

import 'package:flutter/material.dart';
import 'package:pharmed_client/l10n/l10n_ext.dart';
import 'package:pharmed_client/widgets/cabin_widgets/wizard_cabin_preview.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../widgets/step_shared_widgets.dart';

part 'cabin_type_card.dart';
part 'spec_pill.dart';

class Step1CabinetType extends StatelessWidget {
  const Step1CabinetType({super.key, required this.selectedType, required this.onTypeSelected, required this.onNext});

  final VoidCallback onNext;
  final CabinType? selectedType;
  final ValueChanged<CabinType> onTypeSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // MARK: Header
        StepHeader(
          badge: 'Adım 1 / 5',
          title: context.l10n.wizard_step1Header,
          subtitle: context.l10n.wizard_step1Subtitle,
        ),

        // MARK: Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(32, 28, 32, 24),
            child: Row(
              spacing: 20.0,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Standart Kabin
                Expanded(
                  child: CabinTypeCard(
                    type: CabinType.master,
                    isSelected: selectedType == CabinType.master,
                    onTap: () => onTypeSelected(CabinType.master),
                    visual: WizardCabinPreview(type: WizardCabinPreviewType.standard),
                    specs: [context.l10n.wizard_masterCabinSpec1, context.l10n.wizard_masterCabinSpec2],
                    description: context.l10n.wizard_masterCabinDescription,
                  ),
                ),
                // Mobil Kabin
                Expanded(
                  child: CabinTypeCard(
                    type: CabinType.mobile,
                    isSelected: selectedType == CabinType.mobile,
                    onTap: () => onTypeSelected(CabinType.mobile),
                    visual: WizardCabinPreview(type: WizardCabinPreviewType.mobile),
                    specs: [context.l10n.wizard_mobileCabinSpec1, context.l10n.wizard_mobileCabinSpec2],
                    description: context.l10n.wizard_mobileCabinDescription,
                  ),
                ),
              ],
            ),
          ),
        ),

        // MARK: Footer
        StepFooter(note: context.l10n.wizard_cabinTypeNote, onNext: () => selectedType != null ? onNext() : null),
      ],
    );
  }
}
