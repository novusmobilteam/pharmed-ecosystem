// [SWREQ-SETUP-UI-010]
// Adım 1 — Kabin tipi seçimi.
// Standart veya Mobil kabin seçim kartı.
// Sınıf: Class A

import 'package:flutter/material.dart';
import 'package:pharmed_client/shared/widgets/atoms/cabin_visuals/cabin_visuals.dart';
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
          title: 'Kabin Tipini Seçin',
          subtitle: 'Yönetmek istediğiniz kabin türünü belirleyin. Bu seçim sonraki adımları şekillendirecektir.',
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
                    visual: CabinVisual(type: CabinVisualType.standard),
                    specs: const ['Kübik / Birim Doz', 'Servis Bazlı'],
                    description:
                        'Sabit duvara monte veya bağımsız duran, kübik ve birim doz çekmece kombinasyonuna sahip kabin.',
                  ),
                ),
                // Mobil Kabin
                Expanded(
                  child: CabinTypeCard(
                    type: CabinType.mobile,
                    isSelected: selectedType == CabinType.mobile,
                    onTap: () => onTypeSelected(CabinType.mobile),
                    visual: CabinVisual(type: CabinVisualType.mobile),
                    specs: const ['Tekerlekli', 'Oda Bazlı'],
                    description: 'Tekerlekli, koğuş dolaşımı için tasarlanmış 4 sıralı taşınabilir ilaç ünitesi.',
                  ),
                ),
              ],
            ),
          ),
        ),

        // MARK: Footer
        StepFooter(note: 'Kabin tipi sonradan değiştirilemez.', onNext: () => selectedType != null ? onNext() : null),
      ],
    );
  }
}
