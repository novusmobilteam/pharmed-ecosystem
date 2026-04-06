// [SWREQ-SETUP-UI-015] [IEC 62304 §5.5]
// Wizard Adım 5 — Özet & Tamamla.
// Kullanıcı tüm adımlarda girdiği bilgileri gözden geçirir ve onaylar.
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../domain/model/cabin_setup_config.dart';
import '../../../../domain/model/wizard_draft.dart';
import '../../../../domain/model/wizard_mobile_layout.dart';
import '../../widgets/step_shared_widgets.dart';

part 'summary_card.dart';
part 'summary_cards.dart';

class Step5Summary extends StatelessWidget {
  const Step5Summary({super.key, required this.draft, required this.onFinish, required this.onBack});

  final WizardDraft draft;
  final VoidCallback onFinish;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StepHeader(
          badge: 'ADIM 5 / 5',
          title: 'Özet & Tamamla',
          subtitle: 'Girdiğiniz bilgileri onaylayın. Onayladıktan sonra kurulum tamamlanacaktır.',
        ),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: CabinInfoCard(draft: draft)),
                    const SizedBox(width: 16),
                    Expanded(child: ServiceScopeCard(draft: draft)),
                  ],
                ),
                const SizedBox(height: 16),
                // Alt satır: Çekmece Yapısı + Kabin Önizlemesi
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: DrawerStructureCard(draft: draft)),
                    const SizedBox(width: 16),
                    Expanded(child: CabinPreviewCard(draft: draft)),
                  ],
                ),
              ],
            ),
          ),
        ),

        StepFooter(onBack: onBack, onNext: onFinish, nextLabel: 'Kurulumu Tamamla'),
      ],
    );
  }
}
