import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';

// ─────────────────────────────────────────────────────────────────
// MedDoseChip
// [SWREQ-UI-CHIP-DOSE-001]
// Kullanım: Reçete kartındaki doz bilgisi — "1 1/2 Tablet"
// Sınıf  : Class A
// ─────────────────────────────────────────────────────────────────

/// Doz bilgisi chip'i — PrescriptionItem'dan doz + birim gösterir.
///
/// ```dart
/// MedDoseChip(item: prescriptionItem)
/// ```
class MedDoseChip extends StatelessWidget {
  const MedDoseChip({super.key, required this.item});

  final PrescriptionItem item;

  @override
  Widget build(BuildContext context) {
    final text = '${item.dosePiece?.formatFractional ?? '-'} ${item.medicine?.operationUnit ?? context.l10n.common_defaultUnitFallback}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: MedColors.surface3,
        borderRadius: MedRadius.smAll,
        border: Border.all(color: MedColors.border),
      ),
      child: Text(text, style: MedTextStyles.monoSm()),
    );
  }
}

/// Backward compat alias.
typedef DoseChip = MedDoseChip;
