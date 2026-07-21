import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';

// ─────────────────────────────────────────────────────────────────
// MedDoseChip
// [SWREQ-UI-CHIP-DOSE-001]
// Reçete kartındaki doz bilgisi — "1 1/2 Tablet".
// Domain-veri türetme burada; görsel iskelet MedChip'te.
// ─────────────────────────────────────────────────────────────────

/// Doz bilgisi chip'i — PrescriptionItem'dan doz + birim gösterir.
class MedDoseChip extends StatelessWidget {
  const MedDoseChip({super.key, required this.item});

  final PrescriptionItem item;

  @override
  Widget build(BuildContext context) {
    final text =
        '${item.dosePiece?.formatFractional ?? '-'} '
        '${item.medicine?.operationUnitLocalized(context) ?? context.l10n.common_defaultUnitFallback}';
    return MedChip(label: text, style: MedChipStyle.neutral);
  }
}

/// Backward compat alias.
typedef DoseChip = MedDoseChip;
