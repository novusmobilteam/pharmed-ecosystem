import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

class CabinAssignmentMiniPanel extends StatelessWidget {
  const CabinAssignmentMiniPanel({
    super.key,
    required this.groups,
    required this.assignments,
    required this.onCellTap,
    this.selectedUnitId,
  });

  final List<DrawerGroup> groups;
  final List<MedicineAssignment> assignments;
  final int? selectedUnitId;

  /// isEmpty=true → boş göze tıklandı (yeni atama), false → dolu göze
  /// tıklandı (mevcut atamayı düzenle/seç).
  final void Function(DrawerUnit unit, {required bool isEmpty}) onCellTap;

  static const double _cellSize = 58;
  static const double _spacing = 4;
  static const int _crossAxisCount = 3;

  Map<int, MedicineAssignment> get _assignmentByUnitId {
    final map = <int, MedicineAssignment>{};
    for (final a in assignments) {
      final id = a.cabinDrawerId;
      if (id != null) map[id] = a;
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final byUnit = _assignmentByUnitId;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: MedColors.border),
        color: MedColors.surface,
        borderRadius: MedRadius.mdAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: MedSpacing.insetLg,
            child: Text(context.l10n.cabinOverview_panelTitle, style: MedTextStyles.titleSm()),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              padding: MedSpacing.insetLg,
              itemCount: groups.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) => _MiniDrawerView(
                group: groups[index],
                assignmentByUnitId: byUnit,
                selectedUnitId: selectedUnitId,
                onCellTap: onCellTap,
              ),
            ),
          ),
          const Divider(height: 1),
          //const Padding(padding: MedSpacing.insetLg, child: _MiniLegend()),
        ],
      ),
    );
  }
}

class _MiniDrawerView extends StatelessWidget {
  const _MiniDrawerView({
    required this.group,
    required this.assignmentByUnitId,
    required this.selectedUnitId,
    required this.onCellTap,
  });

  final DrawerGroup group;
  final Map<int, MedicineAssignment> assignmentByUnitId;
  final int? selectedUnitId;
  final void Function(DrawerUnit unit, {required bool isEmpty}) onCellTap;

  // Donanımın fiziksel sütun sayısı — sabit 4 (bkz. GetCabinVisualizerDataUseCase).
  static const int _hardwareColumnCount = 4;
  static const double _cellSize = 54;
  static const double _spacing = 4;

  _MiniCell _cell(DrawerUnit unit, int slotIndex) => _MiniCell(
    size: _cellSize,
    slotLabel: 'S-$slotIndex',
    unit: unit,
    assignment: assignmentByUnitId[unit.id],
    isSelected: unit.id != null && unit.id == selectedUnitId,
    onTap: onCellTap,
  );

  @override
  Widget build(BuildContext context) {
    final header = (int filled, int total) => Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(group.name, style: MedTextStyles.bodyMd().copyWith(fontWeight: FontWeight.w600)),
        Text('', style: MedTextStyles.bodySm(color: MedColors.text3)),
      ],
    );

    // ── Kübik olmayan çekmece: tek satır ─────────────────────────────
    if (!group.isKubik) {
      final filled = group.units.where((u) => assignmentByUnitId.containsKey(u.id)).length;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header(filled, group.units.length),
          const SizedBox(height: 6),
          Row(
            spacing: _spacing,
            children: List.generate(
              group.compartmentCount,
              (index) => Expanded(child: _cell(group.units.elementAt(index), index + 1)),
            ),
          ),
        ],
      );
    }

    // ── Kübik çekmece: 4 sütunlu grid + (varsa) sağda birleşik iade sütunu ──
    final layout = resolveDrawerGroupLayout(group, hardwareColumnCount: _hardwareColumnCount);
    final totalCount = group.units.length - layout.returnUnitIds.length;
    final filledCount = group.units
        .where((u) => u.id != null && !layout.returnUnitIds.contains(u.id))
        .where((u) => assignmentByUnitId.containsKey(u.id))
        .length;

    final normalColumnCount = layout.isReturnDrawer
        ? (_hardwareColumnCount - 1).clamp(1, _hardwareColumnCount)
        : _hardwareColumnCount;
    final rowCount = (layout.normalUnits.length / normalColumnCount).ceil();
    final gridHeight = rowCount * _cellSize + (rowCount - 1) * _spacing;

    final grid = GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: normalColumnCount,
        crossAxisSpacing: _spacing,
        mainAxisSpacing: _spacing,
        mainAxisExtent: _cellSize,
      ),
      itemCount: layout.normalUnits.length,
      itemBuilder: (context, index) {
        final unit = layout.normalUnits[index];
        return _cell(unit, group.units.indexOf(unit) + 1);
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        header(filledCount, totalCount),
        const SizedBox(height: 6),
        if (!layout.isReturnDrawer)
          grid
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: normalColumnCount, child: grid),
              const SizedBox(width: _spacing),
              Expanded(
                flex: 1,
                child: SizedBox(
                  height: gridHeight,
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
          ),
      ],
    );
  }
}

class _MiniCell extends StatelessWidget {
  const _MiniCell({
    required this.size,
    required this.slotLabel,
    required this.unit,
    required this.assignment,
    required this.isSelected,
    required this.onTap,
  });

  final double size;
  final String slotLabel;
  final DrawerUnit unit;
  final MedicineAssignment? assignment;
  final bool isSelected;
  final void Function(DrawerUnit unit, {required bool isEmpty}) onTap;

  @override
  Widget build(BuildContext context) {
    final bool isEmpty = assignment == null;
    final status = unit.workingStatus;
    final bool isFaulty = status != CabinWorkingStatus.working;

    final Color bg = isFaulty
        ? status.color.withAlpha(30)
        : isSelected
        ? MedColors.blue
        : isEmpty
        ? MedColors.surface
        : MedColors.blueLight;
    final Color border = isFaulty
        ? status.color
        : isSelected || !isEmpty
        ? MedColors.blue
        : MedColors.border;
    final Color? textColor = isFaulty
        ? status.color
        : isSelected
        ? Colors.white
        : isEmpty
        ? MedColors.text3
        : MedColors.text;

    return GestureDetector(
      onTap: isFaulty ? null : () => onTap(unit, isEmpty: isEmpty),
      child: Container(
        width: size,
        height: size,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: border),
          borderRadius: MedRadius.smAll,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(slotLabel, style: MedTextStyles.monoSm(color: textColor).copyWith(fontSize: 9)),
            const SizedBox(height: 2),
            Text(
              isEmpty ? context.l10n.drawerStatus_empty : assignment!.medicine!.name.toString(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: MedTextStyles.monoSm(color: textColor).copyWith(fontSize: 9, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

// class _MiniLegend extends StatelessWidget {
//   const _MiniLegend();

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _LegendRow(
//           color: MedColors.blueLight,
//           borderColor: MedColors.blue,
//           label: context.l10n.cabinOperation_legendAssignedLabel,
//         ),
//         _LegendRow(
//           color: MedColors.surface,
//           borderColor: MedColors.border,
//           label: context.l10n.cabinOperation_legendEmptyLabel,
//         ),
//         _LegendRow(
//           color: MedColors.amberLight,
//           borderColor: MedColors.amber,
//           label: context.l10n.cabinDesign_returnBadge,
//         ),
//       ],
//     );
//   }
// }

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.color, required this.borderColor, required this.label});
  final Color color;
  final Color borderColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(label, style: MedTextStyles.bodySm(color: MedColors.text3)),
          ),
        ],
      ),
    );
  }
}
