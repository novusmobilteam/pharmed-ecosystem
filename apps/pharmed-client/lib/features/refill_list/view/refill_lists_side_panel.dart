// presentation/widgets/refill_lists_side_panel.dart
import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import 'refill_list_card.dart';

/// Seçim ekranının sol paneli — istasyondaki tüm dolum listelerini
/// kompakt kartlar halinde gösterir, seçili olanı vurgular.
class RefillListsSidePanel extends StatelessWidget {
  const RefillListsSidePanel({super.key, required this.lists, required this.selectedListId, required this.onSelect});

  final List<RefillList> lists;
  final int? selectedListId;
  final ValueChanged<RefillList> onSelect;

  @override
  Widget build(BuildContext context) {
    if (lists.isEmpty) {
      return Center(
        child: EmptyStateWidget(variant: EmptyStateVariant.noData, size: EmptyStateSize.compact),
      );
    }

    return Container(
      padding: MedSpacing.panelInsetPadding,
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: MedColors.border),
        color: MedColors.surface,
        borderRadius: MedRadius.mdAll,
      ),
      child: ListView.separated(
        padding: MedSpacing.insetMd,
        itemCount: lists.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final list = lists[index];
          return RefillListCard(
            refillList: list,
            isSelected: list.id != null && list.id == selectedListId,
            onTap: () => onSelect(list),
          );
        },
      ),
    );
  }
}
