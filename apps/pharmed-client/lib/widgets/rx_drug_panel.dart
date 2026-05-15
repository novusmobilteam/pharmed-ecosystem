// lib/features/prescription/widgets/rx_drug_panel.dart
//
// [SWREQ-UI-RX-DRUG-PANEL-001]
// Sınıf : Class A

import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import 'rx_item_card.dart';

class RxDrugPanel extends StatefulWidget {
  const RxDrugPanel({
    super.key,
    required this.title,
    required this.items,
    required this.selectedItem,
    required this.isBusy,
    required this.onDrugTap,
    this.hospitalization,
    this.showFilters = true,
    this.emptyMessage,
  });

  final String title;
  final List<PrescriptionItem> items;
  final PrescriptionItem? selectedItem;
  final bool isBusy;
  final ValueChanged<PrescriptionItem> onDrugTap;
  final Hospitalization? hospitalization;
  final bool showFilters;
  final String? emptyMessage;

  @override
  State<RxDrugPanel> createState() => _RxDrugPanelState();
}

class _RxDrugPanelState extends State<RxDrugPanel> {
  PrescriptionStatus? _activeFilter;

  @override
  void didUpdateWidget(RxDrugPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.items != oldWidget.items && _activeFilter != null) {
      final stillPresent = widget.items.any((i) => i.status == _activeFilter);
      if (!stillPresent) setState(() => _activeFilter = null);
    }
  }

  List<PrescriptionItem> get _filteredItems {
    if (_activeFilter == null) return widget.items;
    return widget.items.where((i) => i.status == _activeFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return _RxDrugList(
      items: _filteredItems,
      selectedItem: widget.selectedItem,
      isBusy: widget.isBusy,
      onDrugTap: widget.onDrugTap,
      emptyMessage: widget.emptyMessage,
    );
  }
}

// class _RxPanelHeader extends StatelessWidget {
//   const _RxPanelHeader({
//     required this.title,
//     required this.items,
//     required this.activeFilter,
//     required this.onFilterChanged,
//   });

//   final String title;

//   /// Boş liste → filtre bar gizlenir (showFilters: false durumu).
//   final List<PrescriptionItem> items;
//   final PrescriptionStatus? activeFilter;
//   final ValueChanged<PrescriptionStatus?> onFilterChanged;

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Expanded(
//           child: Text(
//             title.toUpperCase(),
//             style: MedTextStyles.titleSm(color: MedColors.text2),
//             overflow: TextOverflow.ellipsis,
//           ),
//         ),
//         if (items.isNotEmpty) _RxFilterBar(items: items, activeFilter: activeFilter, onFilterChanged: onFilterChanged),
//       ],
//     );
//   }
// }

// class _RxFilterBar extends StatelessWidget {
//   const _RxFilterBar({required this.items, required this.activeFilter, required this.onFilterChanged});

//   final List<PrescriptionItem> items;
//   final PrescriptionStatus? activeFilter;
//   final ValueChanged<PrescriptionStatus?> onFilterChanged;

//   Map<PrescriptionStatus, int> get _statusCounts {
//     final counts = <PrescriptionStatus, int>{};
//     for (final item in items) {
//       final status = item.status;
//       if (status == null) continue;
//       counts[status] = (counts[status] ?? 0) + 1;
//     }
//     return Map.fromEntries(counts.entries.toList()..sort((a, b) => a.key.index.compareTo(b.key.index)));
//   }

//   @override
//   Widget build(BuildContext context) {
//     final counts = _statusCounts;

//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       child: Row(
//         children: [
//           MedFilterChip(
//             label: 'Tümü',
//             count: items.length,
//             isActive: activeFilter == null,
//             onTap: () => onFilterChanged(null),
//           ),
//           ...counts.entries.map(
//             (entry) => Padding(
//               padding: const EdgeInsets.only(left: MedSpacing.sm),
//               child: MedFilterChip(
//                 label: entry.key.label,
//                 count: entry.value,
//                 isActive: activeFilter == entry.key,
//                 activeBackgroundColor: entry.key.backgroundColor,
//                 activeForegroundColor: entry.key.color,
//                 onTap: () => onFilterChanged(entry.key),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// ─────────────────────────────────────────────────────────────────────────────
// _RxDrugList
// ─────────────────────────────────────────────────────────────────────────────

class _RxDrugList extends StatelessWidget {
  const _RxDrugList({
    required this.items,
    required this.selectedItem,
    required this.isBusy,
    required this.onDrugTap,
    this.emptyMessage,
  });

  final List<PrescriptionItem> items;
  final PrescriptionItem? selectedItem;
  final bool isBusy;
  final ValueChanged<PrescriptionItem> onDrugTap;
  final String? emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          emptyMessage ?? 'Bu filtrede ilaç bulunamadı.',
          style: MedTextStyles.bodySm(color: MedColors.text4),
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: MedSpacing.md),
      itemBuilder: (context, index) {
        final item = items[index];
        return RxItemCard(
          item: item,
          isSelected: selectedItem?.id == item.id,
          isBusy: isBusy,
          onTap: () => onDrugTap(item),
        );
      },
    );
  }
}
