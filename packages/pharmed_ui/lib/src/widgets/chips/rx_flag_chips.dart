// [SWREQ-UI-CAB-005] [IEC 62304 §5.5]
// Reçete / kabin işlem kartlarında kullanılan generic pill etiketi ve
// PrescriptionItem bayrak chip grubu.
//
// RxFlagChips : bir PrescriptionItem'ın firstDoseEmergency / askDoctor /
//   inCaseOfNecessity bayraklarını MedRxMetaChip'lerle çizen Wrap. Hiçbir bayrak
//   yoksa SizedBox.shrink döner.
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

/// Bir [PrescriptionItem]'ın reçete bayraklarını gösteren chip grubu.
///
/// - firstDoseEmergency → 🔴 İlk Doz Acil
/// - askDoctor          → 🔵 Doktora Sor
/// - inCaseOfNecessity  → 🟡 Gerektiğinde
///
/// Hiçbiri aktif değilse hiçbir şey çizmez ([SizedBox.shrink]). Reçete kalemi
/// içeren tüm kabin işlemlerinde (alım/iade/imha/aktivite) ortak kullanılır.
class RxFlagChips extends StatelessWidget {
  const RxFlagChips({super.key, required this.item, this.spacing = 4, this.runSpacing = 4});

  final PrescriptionItem item;
  final double spacing;
  final double runSpacing;

  bool get _hasFlags =>
      (item.firstDoseEmergency ?? false) || (item.askDoctor ?? false) || (item.inCaseOfNecessity ?? false);

  @override
  Widget build(BuildContext context) {
    if (!_hasFlags) return const SizedBox.shrink();

    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: [
        if (item.firstDoseEmergency ?? false)
          MedInfoChip(
            info: context.l10n.common_flagFirstDoseEmergency,
            backgroundColor: MedColors.red,
            foregroundColor: MedColors.redLight,
          ),
        if (item.askDoctor ?? false)
          MedInfoChip(
            info: context.l10n.common_flagAskDoctor,
            backgroundColor: MedColors.purple,
            foregroundColor: MedColors.blueLight,
          ),
        if (item.inCaseOfNecessity ?? false)
          MedInfoChip(
            info: context.l10n.common_flagInCaseOfNecessity,
            backgroundColor: MedColors.amber,
            foregroundColor: MedColors.amberLight,
          ),
      ],
    );
  }
}
