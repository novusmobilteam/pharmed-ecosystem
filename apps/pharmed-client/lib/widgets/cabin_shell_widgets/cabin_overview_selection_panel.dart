import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CabinOverviewSelectionPanel extends StatelessWidget {
  const CabinOverviewSelectionPanel({
    super.key,
    required this.groups,
    this.assignments = const [],
    required this.selectedUnitIds,
    this.onCellTap,
    this.onDrawerTap,
    this.onChangeCabin,
    this.cabin,
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

  final VoidCallback? onChangeCabin;
  final Cabin? cabin;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 2, color: MedColors.border),
        color: MedColors.surface,
        borderRadius: MedRadius.mdAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (cabin != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(cabin!.name.toString(), style: MedTextStyles.titleMd()),
                  TextButton.icon(
                    onPressed: onChangeCabin,
                    label: Text(context.l10n.cabinOperation_changeCabinButton),
                    icon: Icon(PhosphorIcons.arrowLeft()),
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView.separated(
              itemCount: groups.length,
              separatorBuilder: (BuildContext context, int index) {
                return Divider(height: 2, thickness: 1, color: MedColors.border);
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
            borderRadius: MedRadius.smAll,
            border: Border.all(width: 2, color: borderColor),
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

    // Kübikte, ham unit sırası fiziksel/görsel sırayla EŞLEŞMİYOR —
    // CabinOverviewPanel'in kullandığı aynı dönüşüm burada da uygulanmalı,
    // aksi halde grid sol-sağ/üst-alt ayna görünür (bkz. kubik grid
    // transpozisyon bug'ı, hardware-services skill).
    final visualUnits = isKubik ? kubikUnitsInVisualOrder(group.units, columnCount: _crossAxisCount) : group.units;

    // İade çekmecesi: son sütun fiziksel olarak TEK bir kutuya birleşiyor
    // (bkz. MasterCabinDeviceVisual._KubikPreviewGrid ile aynı fiziksel
    // model — GetCabinVisualizerDataUseCase/CabinSummaryView/
    // MasterCabinDrawerPanel/location guide'da da uygulanan return-drawer
    // hibrit modeli). Bu yüzden o hücrelerde seçim/tıklama YAPILAMAZ —
    // sadece görsel bir "İade" bloğu olarak gösterilir.
    final bool isReturnDrawer = isKubik && group.isReturnDrawer;
    final int normalColumnCount = isReturnDrawer ? (_crossAxisCount - 1).clamp(1, _crossAxisCount) : _crossAxisCount;

    List<DrawerUnit> normalUnits = visualUnits;
    Set<int> returnUnitIds = const {};

    if (isReturnDrawer) {
      final normal = <DrawerUnit>[];
      final returned = <DrawerUnit>[];
      for (var i = 0; i < visualUnits.length; i++) {
        final unit = visualUnits.elementAt(i);
        final isLastColumn = (i % _crossAxisCount) == _crossAxisCount - 1;
        if (isLastColumn) {
          returned.add(unit);
        } else {
          normal.add(unit);
        }
      }
      normalUnits = normal;
      returnUnitIds = returned.map((u) => u.id).whereType<int>().toSet();
    }

    // Bu çekmecedeki atanmış (assignment'ı olan) unit id'leri — iade
    // kutusuna birleşen unit'ler toplu-seç (onDrawerTap) hesabına dahil
    // EDİLMEZ, çünkü tek tek seçilemezler.
    final assignedUnitIdsInGroup = group.units
        .map((u) => u.id)
        .whereType<int>()
        .where((unitId) => !returnUnitIds.contains(unitId))
        .where((unitId) => assignments.any((a) => (a.cabinDrawerId ?? a.drawerUnit?.id) == unitId))
        .toSet();

    final bool isDrawerFullySelected =
        assignedUnitIdsInGroup.isNotEmpty && assignedUnitIdsInGroup.every(selectedUnitIds.contains);

    return Container(
      padding: MedSpacing.insetLg,
      child: Column(
        spacing: 4.0,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onDrawerTap != null ? () => onDrawerTap!(group) : null,
            child: SizedBox(
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(group.name, style: MedTextStyles.titleSm()),
                  if (onDrawerTap != null)
                    Icon(
                      isDrawerFullySelected ? PhosphorIconsFill.checkCircle : PhosphorIcons.circle(),
                      size: 26,
                      color: isDrawerFullySelected ? MedColors.blue : MedColors.text3,
                    ),
                ],
              ),
            ),
          ),
          Builder(
            builder: (context) {
              if (!isKubik) {
                return Row(
                  spacing: _spacing,
                  children: List.generate(group.compartmentCount, (index) {
                    final unit = group.units.elementAt(index);
                    return Expanded(child: container(index, unit));
                  }),
                );
              }

              final normalGrid = GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: normalColumnCount,
                  crossAxisSpacing: _spacing,
                  mainAxisSpacing: _spacing,
                  mainAxisExtent: _cellHeight,
                ),
                itemCount: normalUnits.length,
                itemBuilder: (context, index) => container(index, normalUnits.elementAt(index)),
              );

              if (!isReturnDrawer) return normalGrid;

              final rowCount = (group.compartmentCount / _crossAxisCount).ceil();
              final gridHeight = rowCount * _cellHeight + (rowCount - 1) * _spacing;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: normalColumnCount, child: normalGrid),
                  SizedBox(width: _spacing),
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: gridHeight,
                      // Bilinçli olarak GestureDetector/onTap YOK — bu bölge
                      // fiziksel olarak tek parça ve HMI'da tek tek
                      // seçilemez, sadece bilgi amaçlı gösterilir.
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: MedColors.amberLight,
                          border: Border.all(color: MedColors.amber, width: 1.5),
                          borderRadius: MedRadius.smAll,
                        ),
                        child: Text(
                          context.l10n.cabinDesign_returnBadge,
                          style: MedTextStyles.monoSm(color: MedColors.amber),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
