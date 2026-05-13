// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

/// Sağ panel — iade edilebilir ilaç kartları. Tek seçim.
class RefundDrugList extends StatelessWidget {
  const RefundDrugList({
    super.key,
    required this.items,
    required this.selectedItem,
    required this.isBusy,
    required this.onDrugTap,
  });

  final List<PrescriptionItem> items;
  final PrescriptionItem? selectedItem;
  final bool isBusy;
  final ValueChanged<PrescriptionItem> onDrugTap;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(MedSpacing.lg),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: MedSpacing.md),
      itemBuilder: (context, index) {
        final item = items[index];
        final isSelected = selectedItem?.id == item.id;
        return RxItemCard(item: item, isSelected: isSelected, isBusy: isBusy, onTap: () => onDrugTap(item));
      },
    );
  }
}
