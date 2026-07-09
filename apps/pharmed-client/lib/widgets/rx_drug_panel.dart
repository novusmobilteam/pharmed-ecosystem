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
  PrescriptionMovementType? _activeFilter;

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
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: MedSpacing.md),
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
