import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CabinOperationWidget extends StatelessWidget {
  const CabinOperationWidget({
    super.key,
    required this.groups,
    required this.assignments,
    required this.selectedUnitIds,
    this.onCellTap,
    this.onDrawerTap,
  });

  final List<DrawerGroup> groups;
  final List<MedicineAssignment> assignments;

  /// Seçili unit id'lerinin kümesi. Tek seçim senaryosu için tek elemanlı
  /// (ya da boş) bir set geçilir — widget davranışı otomatik uyum sağlar.
  final Set<int> selectedUnitIds;

  final void Function(DrawerUnit)? onCellTap;

  /// Verilirse, çekmece başlığına tıklanabilir hale gelir (o çekmecedeki
  /// tüm atanmış gözleri toplu seç/kaldır). Verilmezse başlık statik kalır.
  final void Function(DrawerGroup)? onDrawerTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: MedSpacing.insetXl,
      decoration: BoxDecoration(border: Border.all(width: 2), color: Colors.grey.shade200),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(left: MedSpacing.md),
            width: context.width,
            height: 45,
            alignment: Alignment.centerLeft,
            decoration: const BoxDecoration(color: Colors.black),
            child: Text('İlaç Atama', style: MedTextStyles.monoMd(color: Colors.white)),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: groups.length,
              separatorBuilder: (BuildContext context, int index) {
                return Divider(height: 2, thickness: 2, color: Colors.black);
              },
              itemBuilder: (BuildContext context, int index) {
                final group = groups.elementAt(index);
                return _DrawerView(
                  key: ValueKey(group.slot.id ?? index),
                  group: group,
                  assignments: assignments,
                  selectedUnitIds: selectedUnitIds,
                  onCellTap: onCellTap,
                  onDrawerTap: onDrawerTap,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerView extends StatelessWidget {
  const _DrawerView({
    super.key,
    required this.group,
    required this.assignments,
    required this.selectedUnitIds,
    this.onCellTap,
    this.onDrawerTap,
  });

  final DrawerGroup group;
  final List<MedicineAssignment> assignments;
  final Set<int> selectedUnitIds;
  final void Function(DrawerUnit)? onCellTap;
  final void Function(DrawerGroup)? onDrawerTap;

  static const double _cellHeight = 100;
  static const double _spacing = 4;
  static const int _crossAxisCount = 4;

  Map<int, MedicineAssignment> get _assignmentByUnitId {
    final map = <int, MedicineAssignment>{};
    for (final a in assignments) {
      final unitId = a.cabinDrawerId;
      if (unitId != null) map[unitId] = a;
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    Widget container(int index, DrawerUnit unit) {
      final assignment = _assignmentByUnitId[unit.id];
      final medicine = assignment?.medicine;
      final label = medicine != null ? medicine.name.toString() : context.l10n.drawerStatus_empty;
      final bool isEmpty = medicine == null;
      final bool isSelected = unit.id != null && selectedUnitIds.contains(unit.id);
      final Color cellcolor = isSelected
          ? MedColors.blue
          : isEmpty
          ? MedColors.surface3
          : MedColors.blueLight;
      final Color? textColor = isSelected
          ? Colors.white
          : isEmpty
          ? null
          : MedColors.text;
      final Color borderColor = isSelected
          ? Colors.transparent
          : isEmpty
          ? MedColors.border
          : MedColors.blue;

      return GestureDetector(
        onTap: onCellTap != null ? () => onCellTap!(unit) : null,
        child: Container(
          height: _cellHeight,
          padding: MedSpacing.insetMd,
          decoration: BoxDecoration(
            color: cellcolor,
            border: Border.all(width: 3, color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('G-${index + 1}', style: MedTextStyles.monoSm(color: textColor)),
                  if (isSelected) Icon(PhosphorIcons.checkCircle(), size: 16, color: textColor),
                ],
              ),
              Text(
                label,
                style: MedTextStyles.monoSm(color: textColor).copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    }

    bool isKubik = group.isKubik;
    // Bu çekmecedeki atanmış (assignment'ı olan) unit id'leri.
    final assignedUnitIdsInGroup = group.units
        .map((u) => u.id)
        .whereType<int>()
        .where((unitId) => assignments.any((a) => (a.cabinDrawerId ?? a.drawerUnit?.id) == unitId))
        .toSet();

    final bool isDrawerFullySelected =
        assignedUnitIdsInGroup.isNotEmpty && assignedUnitIdsInGroup.every(selectedUnitIds.contains);

    // Kübikte, ham unit sırası fiziksel/görsel sırayla EŞLEŞMİYOR —
    // CabinOverviewPanel'in kullandığı aynı dönüşüm burada da uygulanmalı,
    // aksi halde grid sol-sağ/üst-alt ayna görünür (bkz. kubik grid
    // transpozisyon bug'ı, hardware-services skill).
    final visualUnits = isKubik ? kubikUnitsInVisualOrder(group.units, columnCount: _crossAxisCount) : group.units;

    return Container(
      padding: MedSpacing.insetLg,
      child: Column(
        spacing: 4.0,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onDrawerTap != null ? () => onDrawerTap!(group) : null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(group.name, style: MedTextStyles.titleSm()),
                if (onDrawerTap != null)
                  Icon(
                    isDrawerFullySelected ? PhosphorIconsFill.checkSquare : PhosphorIcons.square(),
                    size: 26,
                    color: isDrawerFullySelected ? MedColors.blue : MedColors.text3,
                  ),
              ],
            ),
          ),
          Builder(
            builder: (context) {
              if (isKubik) {
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _crossAxisCount,
                    crossAxisSpacing: _spacing,
                    mainAxisSpacing: _spacing,
                    mainAxisExtent: _cellHeight,
                  ),
                  itemCount: group.compartmentCount,
                  itemBuilder: (context, index) {
                    final unit = visualUnits.elementAt(index);
                    return container(index, unit);
                  },
                );
              } else {
                return Row(
                  spacing: _spacing,
                  children: List.generate(group.compartmentCount, (index) {
                    final unit = group.units.elementAt(index);
                    return Expanded(child: container(index, unit));
                  }),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
