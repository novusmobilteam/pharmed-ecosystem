import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';

class DoseChip extends StatelessWidget {
  const DoseChip({super.key, required this.item});

  final PrescriptionItem item;

  @override
  Widget build(BuildContext context) {
    final text = '${item.dosePiece?.formatFractional ?? '-'} ${item.medicine?.operationUnit ?? 'Adet'}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: MedColors.surface3,
        borderRadius: MedRadius.smAll,
        border: Border.all(color: MedColors.border),
      ),
      child: Text(text, style: MedTextStyles.monoSm()),
    );
  }
}
