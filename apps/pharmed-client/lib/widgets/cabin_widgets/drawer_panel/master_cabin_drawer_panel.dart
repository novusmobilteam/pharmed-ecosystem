// lib/shared/widgets/cabin_widgets/drawer_panel/master_cabin_drawer_panel.dart
//
// [SWREQ-UI-CAB-003]
// Master kabin işlemleri ekranının orta paneli.
// Seçili çekmeceye ait gözleri tıklanabilir olarak gösterir.
//
// Çekmece tipine göre farklı layout üretir:
//   - Kübik      → NxM grid, her DrawerUnit bir göz
//   - Birim Doz  → kolon bazlı layout, unit seçim border'ı ile
//   - Serum      → placeholder (TODO)
//
// Sınıf: Class B

part of 'drawer_panel.dart';

class MasterCabinDrawerPanel extends StatelessWidget {
  const MasterCabinDrawerPanel({
    super.key,
    required this.mode,
    this.group,
    this.stocks = const [],
    this.assignments = const [],
    this.faults = const [],
    this.selectedUnitId,
    this.selectedStepNo,
    this.onCellTap,
  });

  final CabinOperationMode mode;
  final DrawerGroup? group;
  final List<CabinStock> stocks;
  final List<MedicineAssignment> assignments;
  final List<MasterFault> faults;
  final int? selectedUnitId;
  final int? selectedStepNo;
  final void Function(DrawerUnit unit, int? stepNo)? onCellTap;

  @override
  Widget build(BuildContext context) {
    final g = group;
    if (g == null) return CabinDrawerEmptyState(subtitle: context.l10n.cabin_masterGridPlaceholder);

    return Container(
      decoration: BoxDecoration(
        color: MedColors.surface,
        border: Border.all(color: MedColors.border, width: 2),
        borderRadius: MedRadius.lgAll,
        boxShadow: const [
          BoxShadow(color: Color(0x1A1E3264), blurRadius: 16, offset: Offset(0, 4)),
          BoxShadow(color: Color(0x0A1E3264), blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _MasterDrawerHeader(group: g, mode: mode),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _MasterDrawerBody(
                group: g,
                mode: mode,
                faults: faults,
                stocks: stocks,
                assignments: assignments,
                selectedUnitId: selectedUnitId,
                selectedStepNo: selectedStepNo,
                onCellTap: onCellTap,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// _MasterDrawerHeader
// ─────────────────────────────────────────────────────────────────

class _MasterDrawerHeader extends StatelessWidget {
  const _MasterDrawerHeader({required this.group, required this.mode});

  final DrawerGroup group;
  final CabinOperationMode mode;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
      decoration: BoxDecoration(
        color: MedColors.surface2,
        border: Border(bottom: BorderSide(color: MedColors.border2)),
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_typeLabel(context, group), style: MedTextStyles.titleMd()),
          const SizedBox(height: 3),
          Text(_subLabel(context, group), style: MedTextStyles.monoMd(color: MedColors.text3)),
          const SizedBox(height: 8),
          CabinModeBanner(mode: mode),
        ],
      ),
    );
  }

  String _typeLabel(BuildContext context, DrawerGroup g) {
    if (g.isSerum) return context.l10n.cabin_serumDrawerName;
    if (g.isKubik) return context.l10n.cabin_kubikDrawerName;
    return context.l10n.cabin_unitDoseDrawerName;
  }

  String _subLabel(BuildContext context, DrawerGroup g) {
    if (g.isKubik) {
      final count = g.units.length;
      const cols = 4;
      final rows = (count / cols).ceil();
      return '$cols×$rows (${context.l10n.cabin_cellCountLabel(count)})';
    }
    if (g.isSerum) return context.l10n.cabin_serumRackView;
    final config = g.slot.drawerConfig;
    final steps = config?.numberOfSteps ?? 0;
    final mult = config?.stepMultiplier ?? 1;
    return '${g.units.length} grup · $steps adım × $mult';
  }
}

// ─────────────────────────────────────────────────────────────────
// _MasterDrawerBody
// ─────────────────────────────────────────────────────────────────

class _MasterDrawerBody extends StatelessWidget {
  const _MasterDrawerBody({
    required this.group,
    required this.mode,
    required this.stocks,
    required this.faults,
    required this.assignments,
    this.selectedUnitId,
    this.selectedStepNo,
    this.onCellTap,
  });

  final DrawerGroup group;
  final CabinOperationMode mode;
  final List<CabinStock> stocks;
  final List<MedicineAssignment> assignments;
  final List<MasterFault> faults;
  final int? selectedUnitId;
  final int? selectedStepNo;
  final void Function(DrawerUnit unit, int? stepNo)? onCellTap;

  Map<(int, int), CabinStock> get _stockByUnitAndStep {
    final map = <(int, int), CabinStock>{};
    for (final s in stocks) {
      final unitId = s.cabinDrawerDetail?.drawerUnit?.id;
      final stepNo = s.cabinDrawerDetail?.stepNo;
      if (unitId != null && stepNo != null) map[(unitId, stepNo)] = s;
    }
    return map;
  }

  Map<int, CabinStock> get _stockByUnitId {
    final map = <int, CabinStock>{};
    for (final s in stocks) {
      final unitId = s.cabinDrawerDetail?.drawerUnit?.id;
      if (unitId != null) map[unitId] = s;
    }
    return map;
  }

  Map<int, MedicineAssignment> get _assignmentByUnitId {
    final map = <int, MedicineAssignment>{};
    for (final a in assignments) {
      final unitId = a.cabinDrawerId;
      if (unitId != null) map[unitId] = a;
    }
    return map;
  }

  Map<int, MasterFault> get _faultByUnitId {
    final map = <int, MasterFault>{};
    for (final f in faults) {
      final unitId = f.slotId;
      if (unitId != null && f.endDate == null) map[unitId] = f;
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    if (group.isSerum) return const _MasterSerumView();

    if (group.isKubik) {
      return _MasterKubicView(
        group: group,
        mode: mode,
        faultByUnitId: _faultByUnitId,
        stockByUnitId: _stockByUnitId,
        assignmentByUnitId: _assignmentByUnitId,
        selectedUnitId: selectedUnitId,
        onCellTap: (unit) => onCellTap?.call(unit, null),
      );
    }

    return _MasterUnitDoseView(
      group: group,
      mode: mode,
      stockByUnitAndStep: _stockByUnitAndStep,
      assignmentByUnitId: _assignmentByUnitId,
      faultByUnitId: _faultByUnitId,
      selectedUnitId: selectedUnitId,
      selectedStepNo: selectedStepNo,
      onCellTap: onCellTap,
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// _MasterKubicView
// ─────────────────────────────────────────────────────────────────

class _MasterKubicView extends StatelessWidget {
  const _MasterKubicView({
    required this.group,
    required this.mode,
    required this.stockByUnitId,
    required this.assignmentByUnitId,
    required this.faultByUnitId,
    this.selectedUnitId,
    this.onCellTap,
  });

  final DrawerGroup group;
  final CabinOperationMode mode;
  final Map<int, CabinStock> stockByUnitId;
  final Map<int, MedicineAssignment> assignmentByUnitId;
  final Map<int, MasterFault> faultByUnitId;
  final int? selectedUnitId;
  final void Function(DrawerUnit unit)? onCellTap;

  @override
  Widget build(BuildContext context) {
    final units = group.units;
    const crossAxisCount = 4;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFDCE8F5),
            border: Border.all(color: const Color(0xFFA8BEDB), width: 2),
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [BoxShadow(color: Color(0x1F1E3C64), blurRadius: 8, offset: Offset(0, 2))],
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 5,
              mainAxisSpacing: 5,
              mainAxisExtent: 120,
            ),
            itemCount: units.length,
            itemBuilder: (context, i) {
              final unit = units[i];
              return _MasterCabinCell(
                unit: unit,
                stock: stockByUnitId[unit.id],
                fault: faultByUnitId[unit.id],
                assignment: assignmentByUnitId[unit.id],
                mode: mode,
                code: '',
                isSelected: selectedUnitId == unit.id,
                isKubik: true,
                onTap: unit.workingStatus == CabinWorkingStatus.working || mode == CabinOperationMode.fault
                    ? () => onCellTap?.call(unit)
                    : null,
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        _MasterCellLegend(mode: mode),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// _MasterUnitDoseView
// ─────────────────────────────────────────────────────────────────

class _MasterUnitDoseView extends StatelessWidget {
  const _MasterUnitDoseView({
    required this.group,
    required this.mode,
    required this.stockByUnitAndStep,
    required this.assignmentByUnitId,
    required this.faultByUnitId,
    this.selectedUnitId,
    this.selectedStepNo,
    this.onCellTap,
  });

  final DrawerGroup group;
  final CabinOperationMode mode;
  final Map<(int, int), CabinStock> stockByUnitAndStep;
  final Map<int, MedicineAssignment> assignmentByUnitId;
  final Map<int, MasterFault> faultByUnitId;
  final int? selectedUnitId;
  final int? selectedStepNo;
  final void Function(DrawerUnit unit, int? stepNo)? onCellTap;

  @override
  Widget build(BuildContext context) {
    final config = group.slot.drawerConfig;
    final numberOfSteps = config?.numberOfSteps ?? 6;
    final stepMultiplier = config?.stepMultiplier ?? 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: const Color(0xFFD8E4F0),
            border: Border.all(color: const Color(0xFFA0B8D0), width: 2),
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [BoxShadow(color: Color(0x1F1E3C64), blurRadius: 8, offset: Offset(0, 2))],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int gi = 0; gi < group.units.length; gi++) ...[
                Expanded(
                  child: _MasterUnitDoseColumn(
                    unit: group.units[gi],
                    groupIndex: gi,
                    numberOfSteps: numberOfSteps,
                    stepMultiplier: stepMultiplier,
                    mode: mode,
                    stockByUnitAndStep: stockByUnitAndStep,
                    assignmentByUnitId: assignmentByUnitId,
                    faultByUnitId: faultByUnitId,
                    selectedUnitId: selectedUnitId,
                    selectedStepNo: selectedStepNo,
                    onCellTap: onCellTap,
                  ),
                ),
                if (gi < group.units.length - 1)
                  Container(
                    width: 3,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(color: const Color(0xFFA0B8D0), borderRadius: BorderRadius.circular(2)),
                  ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        _MasterCellLegend(mode: mode),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// _MasterUnitDoseColumn
// ─────────────────────────────────────────────────────────────────

class _MasterUnitDoseColumn extends StatelessWidget {
  const _MasterUnitDoseColumn({
    required this.unit,
    required this.groupIndex,
    required this.numberOfSteps,
    required this.stepMultiplier,
    required this.mode,
    required this.stockByUnitAndStep,
    required this.assignmentByUnitId,
    required this.faultByUnitId,
    this.selectedUnitId,
    this.selectedStepNo,
    this.onCellTap,
  });

  final DrawerUnit unit;
  final int groupIndex;
  final int numberOfSteps;
  final int stepMultiplier;
  final CabinOperationMode mode;
  final Map<(int, int), CabinStock> stockByUnitAndStep;
  final Map<int, MedicineAssignment> assignmentByUnitId;
  final Map<int, MasterFault> faultByUnitId;
  final int? selectedUnitId;
  final int? selectedStepNo;
  final void Function(DrawerUnit unit, int? stepNo)? onCellTap;

  bool get _isUnitSelected => selectedUnitId == unit.id;

  @override
  Widget build(BuildContext context) {
    final fault = faultByUnitId[unit.id];
    final assignment = assignmentByUnitId[unit.id];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        border: Border.all(color: _isUnitSelected ? MedColors.blue : Colors.transparent, width: 2),
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.all(2),
      child: Column(
        children: [
          for (int step = 0; step < numberOfSteps; step++)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Row(
                children: [
                  for (int w = 0; w < stepMultiplier; w++) ...[
                    Expanded(
                      child: _MasterCabinCell(
                        unit: unit,
                        stock: stockByUnitAndStep[(unit.id, step * stepMultiplier + w + 1)],
                        fault: fault,
                        assignment: assignment,
                        mode: mode,
                        code: 'G${groupIndex + 1}·${step * stepMultiplier + w + 1}',
                        isSelected: _isUnitSelected && selectedStepNo == step * stepMultiplier + w + 1,
                        isKubik: false,

                        onTap: unit.workingStatus == CabinWorkingStatus.working || mode == CabinOperationMode.fault
                            ? () => onCellTap?.call(unit, step * stepMultiplier + w + 1)
                            : null,
                      ),
                    ),
                    if (w < stepMultiplier - 1) const SizedBox(width: 2),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// _MasterCabinCell
// ─────────────────────────────────────────────────────────────────

class _MasterCabinCell extends StatelessWidget {
  const _MasterCabinCell({
    required this.unit,
    required this.mode,
    required this.code,
    required this.isSelected,
    required this.isKubik,
    this.fault,
    this.stock,
    this.assignment,
    this.onTap,
  });

  final DrawerUnit unit;
  final CabinStock? stock;
  final MasterFault? fault;
  final MedicineAssignment? assignment;
  final CabinOperationMode mode;
  final String code;
  final bool isSelected;
  final bool isKubik;
  final VoidCallback? onTap;

  bool get _isLocked => onTap == null;

  CabinCellStatus get _status {
    if (fault != null) {
      return fault!.workingStatus == CabinWorkingStatus.maintenance
          ? CabinCellStatus.maintenance
          : CabinCellStatus.fault;
    }
    if (unit.workingStatus == CabinWorkingStatus.faulty) return CabinCellStatus.fault;
    if (unit.workingStatus == CabinWorkingStatus.maintenance) return CabinCellStatus.maintenance;

    if (mode == CabinOperationMode.assign) {
      final a = assignment;
      if (a != null && a.id != null) return CabinCellStatus.assigned;
      return CabinCellStatus.empty;
    }

    final s = stock;
    if (s == null) return CabinCellStatus.empty;
    final qty = s.quantity?.toDouble() ?? 0;
    final crit = s.assignment?.criticalQuantity?.toDouble() ?? 0;
    final min = s.assignment?.minQuantity?.toDouble() ?? 0;
    if (qty == 0) return CabinCellStatus.empty;
    if (qty <= crit) return CabinCellStatus.critical;
    if (qty <= min) return CabinCellStatus.low;
    return CabinCellStatus.assigned;
  }

  bool get _hasActiveFault => _status == CabinCellStatus.fault || _status == CabinCellStatus.maintenance;

  @override
  Widget build(BuildContext context) {
    final colors = CabinCellColors.of(_status);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: isKubik ? null : 44,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _isLocked && !_hasActiveFault
                ? [const Color(0xFFF0F0F0), const Color(0xFFE0E0E0)]
                : [colors.bgLight, colors.bgDark],
          ),
          border: Border.all(
            color: isSelected ? MedColors.blue : (_isLocked ? const Color(0xFFCCCCCC) : colors.border),
            width: isSelected ? 2 : 1.5,
          ),
          borderRadius: BorderRadius.circular(isKubik ? 7 : 5),
        ),
        child: _isLocked ? _lockedContent() : _activeContent(),
      ),
    );
  }

  Widget _lockedContent() => Center(
    child: Icon(
      _status == CabinCellStatus.fault ? PhosphorIcons.warningCircle() : PhosphorIcons.wrench(),
      size: isKubik ? 24 : 16,
      color: unit.workingStatus == CabinWorkingStatus.faulty ? MedColors.red : MedColors.amber,
    ),
  );

  Widget _activeContent() {
    if (isKubik) {
      return Stack(
        children: [
          Positioned(
            top: 4,
            left: 0,
            right: 0,
            child: Text(
              code,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: MedFonts.mono,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: const Color(0x993250780),
              ),
            ),
          ),
          Positioned(bottom: 4, left: 4, right: 4, child: _cellContent()),
        ],
      );
    }

    if (mode == CabinOperationMode.assign) return Center(child: _cellContent());

    final s = stock;
    if (s == null) return const SizedBox.shrink();
    return Center(child: _stockContent(s));
  }

  Widget _cellContent() => switch (mode) {
    CabinOperationMode.assign => _assignContent(),
    CabinOperationMode.fill || CabinOperationMode.count => _stockFillContent(),
    CabinOperationMode.fault => const SizedBox.shrink(),
  };

  Widget _assignContent() {
    final a = assignment;
    if (a == null || a.id == null) return const SizedBox.shrink();
    return Text(
      a.medicine?.name ?? '—',
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontFamily: MedFonts.mono,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: const Color(0xCC1256AA),
      ),
    );
  }

  Widget _stockFillContent() {
    final s = stock;
    if (s == null) return const SizedBox.shrink();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (s.medicine?.name != null)
          Text(
            s.medicine!.name!.split(' ').take(2).join(' '),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontFamily: MedFonts.mono, fontSize: 7, color: const Color(0xCC1A6FD8)),
          ),
        Text(
          '${s.quantity?.toInt() ?? 0}/${s.assignment?.maxQuantity?.toInt() ?? 0}',
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: MedFonts.mono, fontSize: 8, fontWeight: FontWeight.w600, color: _qtyColor(s)),
        ),
      ],
    );
  }

  Widget _stockContent(CabinStock s) => Text(
    '${s.quantity?.toInt() ?? 0}',
    textAlign: TextAlign.center,
    style: TextStyle(fontFamily: MedFonts.mono, fontSize: 8, fontWeight: FontWeight.w600, color: _qtyColor(s)),
  );

  Color _qtyColor(CabinStock s) {
    final qty = s.quantity?.toDouble() ?? 0;
    final crit = s.assignment?.criticalQuantity?.toDouble() ?? 0;
    final min = s.assignment?.minQuantity?.toDouble() ?? 0;
    if (qty <= crit) return MedColors.red;
    if (qty <= min) return MedColors.amber;
    return MedColors.green;
  }
}

// ─────────────────────────────────────────────────────────────────
// _MasterCellLegend
// ─────────────────────────────────────────────────────────────────

class _MasterCellLegend extends StatelessWidget {
  const _MasterCellLegend({required this.mode});

  final CabinOperationMode mode;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 4,
      children: _items(context, mode).map((item) {
        final colors = CabinCellColors.of(item.$1);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: colors.bgLight,
                border: Border.all(color: colors.border, width: 1.5),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 5),
            Text(item.$2, style: MedTextStyles.bodySm(color: MedColors.text2)),
          ],
        );
      }).toList(),
    );
  }

  List<(CabinCellStatus, String)> _items(BuildContext context, CabinOperationMode mode) => switch (mode) {
    CabinOperationMode.assign => [
      (CabinCellStatus.empty, context.l10n.cabin_legendAssignEmpty),
      (CabinCellStatus.assigned, context.l10n.cabin_legendAssignAssigned),
      (CabinCellStatus.fault, context.l10n.cabin_legendAssignFault),
      (CabinCellStatus.maintenance, context.l10n.cabin_legendAssignMaintenance),
    ],
    CabinOperationMode.fill => [
      (CabinCellStatus.empty, context.l10n.cabin_legendFillEmpty),
      (CabinCellStatus.assigned, 'Normal stok'),
      (CabinCellStatus.low, 'Dolum gerekiyor'),
      (CabinCellStatus.critical, 'Acil dolum'),
    ],
    CabinOperationMode.count => [
      (CabinCellStatus.assigned, context.l10n.cabin_legendCountAssigned),
      (CabinCellStatus.low, context.l10n.cabin_legendCountLow),
      (CabinCellStatus.empty, context.l10n.cabin_legendCountEmpty),
    ],
    CabinOperationMode.fault => [
      (CabinCellStatus.assigned, context.l10n.cabin_legendFaultNormal),
      (CabinCellStatus.fault, context.l10n.cabin_legendFaultReported),
      (CabinCellStatus.empty, context.l10n.cabin_legendFaultEmpty),
    ],
  };
}

// ─────────────────────────────────────────────────────────────────
// _MasterSerumView
// ─────────────────────────────────────────────────────────────────

class _MasterSerumView extends StatelessWidget {
  const _MasterSerumView();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: MedColors.surface2,
        border: Border.all(color: MedColors.border),
        borderRadius: MedRadius.smAll,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.water_drop_outlined, size: 32, color: MedColors.text4),
            const SizedBox(height: 8),
            Text(context.l10n.cabin_serumViewTitle, style: MedTextStyles.bodySm(color: MedColors.text3)),
            const SizedBox(height: 4),
            Text(context.l10n.cabin_serumViewTodo, style: MedTextStyles.monoSm(color: MedColors.text4)),
          ],
        ),
      ),
    );
  }
}
