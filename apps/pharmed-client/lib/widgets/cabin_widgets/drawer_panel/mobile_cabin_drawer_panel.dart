// lib/shared/widgets/cabin_widgets/drawer_panel/mobile_cabin_drawer_panel.dart
//
// [SWREQ-UI-CAB-007]
// Mobil kabin işlemleri ekranının orta paneli.
// Seçili MobileSlotVisual'ın rowColumns grid'ini gösterir.
//
// Her hücre tıklanabilir — tıklamada (slotId, rowIndex, colIndex) üretilir.
// Atama modunda hücre rengi assignmentByCoord listesinden gelir.
// Arıza modunda slot.workingStatus'e göre tüm gözler renklendirilir.
//
// Sınıf: Class B

part of 'drawer_panel.dart';

// Hücre koordinatı — (slotId, rowIndex, colIndex)
typedef MobileCellCoord = (int slotId, int rowIndex, int colIndex);

class MobileCabinDrawerPanel extends StatelessWidget {
  const MobileCabinDrawerPanel({
    super.key,
    required this.mode,
    this.slot,
    this.assignmentByCoord = const {},
    this.selectedCell,
    this.onCellTap,
  });

  final CabinOperationMode mode;
  final MobileSlotVisual? slot;
  final Map<MobileCellCoord, PatientAssignment> assignmentByCoord;
  final MobileCellCoord? selectedCell;
  final void Function(MobileCellCoord coord)? onCellTap;

  @override
  Widget build(BuildContext context) {
    final s = slot;
    if (s == null) {
      return CabinDrawerEmptyState(subtitle: context.l10n.cabin_mobileGridPlaceholder);
    }

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
          _MobileDrawerHeader(slot: s, mode: mode),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _MobileDrawerBody(
                slot: s,
                mode: mode,
                assignmentByCoord: assignmentByCoord,
                selectedCell: selectedCell,
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
// _MobileDrawerHeader
// ─────────────────────────────────────────────────────────────────

class _MobileDrawerHeader extends StatelessWidget {
  const _MobileDrawerHeader({required this.slot, required this.mode});

  final MobileSlotVisual slot;
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
          Text(context.l10n.cabin_mobileDrawerTitle, style: MedTextStyles.titleMd()),
          const SizedBox(height: 3),
          Text(
            '${slot.rowCount} satır · ${slot.totalCells} göz  ·  '
            '${slot.rowColumns.join(", ")} sütun',
            style: MedTextStyles.monoMd(color: MedColors.text3),
          ),
          const SizedBox(height: 8),
          CabinModeBanner(mode: mode, isPatientAssignment: true),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// _MobileDrawerBody
// ─────────────────────────────────────────────────────────────────

class _MobileDrawerBody extends StatelessWidget {
  const _MobileDrawerBody({
    required this.slot,
    required this.mode,
    required this.assignmentByCoord,
    this.selectedCell,
    this.onCellTap,
  });

  final MobileSlotVisual slot;
  final CabinOperationMode mode;
  final Map<MobileCellCoord, PatientAssignment> assignmentByCoord;
  final MobileCellCoord? selectedCell;
  final void Function(MobileCellCoord coord)? onCellTap;

  // slot.workingStatus'ten fault durumu türet
  CabinCellStatus? get _faultStatus => switch (slot.workingStatus) {
    CabinWorkingStatus.faulty => CabinCellStatus.fault,
    CabinWorkingStatus.maintenance => CabinCellStatus.maintenance,
    _ => null,
  };

  @override
  Widget build(BuildContext context) {
    final faultStatus = _faultStatus;

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
          child: Column(
            children: [
              for (int rowIdx = 0; rowIdx < slot.rowColumns.length; rowIdx++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: _MobileDrawerRow(
                    slotId: slot.slotId,
                    rowIndex: rowIdx,
                    colCount: slot.rowColumns[rowIdx],
                    mode: mode,
                    assignmentByCoord: assignmentByCoord,
                    faultStatus: faultStatus,
                    selectedCell: selectedCell,
                    onCellTap: faultStatus != null ? null : onCellTap,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _MobileCellLegend(mode: mode, faultStatus: faultStatus),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// _MobileDrawerRow
// ─────────────────────────────────────────────────────────────────

class _MobileDrawerRow extends StatelessWidget {
  const _MobileDrawerRow({
    required this.slotId,
    required this.rowIndex,
    required this.colCount,
    required this.mode,
    required this.assignmentByCoord,
    this.faultStatus,
    this.selectedCell,
    this.onCellTap,
  });

  final int slotId;
  final int rowIndex;
  final int colCount;
  final CabinOperationMode mode;
  final Map<MobileCellCoord, PatientAssignment> assignmentByCoord;
  final CabinCellStatus? faultStatus;
  final MobileCellCoord? selectedCell;
  final void Function(MobileCellCoord coord)? onCellTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 20,
          child: Text(
            '${rowIndex + 1}',
            style: TextStyle(fontFamily: MedFonts.mono, fontSize: 9, color: MedColors.text3),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Row(
            spacing: 4,
            children: List.generate(colCount, (colIdx) {
              final coord = (slotId, rowIndex, colIdx);
              final isSelected = selectedCell == coord;
              final assignment = assignmentByCoord[coord];

              return Expanded(
                child: _MobileCabinCell(
                  coord: coord,
                  isSelected: isSelected,
                  assignment: assignment,
                  faultStatus: faultStatus,
                  mode: mode,
                  onTap: onCellTap != null ? () => onCellTap!.call(coord) : null,
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// _MobileCabinCell
// ─────────────────────────────────────────────────────────────────

class _MobileCabinCell extends StatelessWidget {
  const _MobileCabinCell({
    required this.coord,
    required this.isSelected,
    required this.mode,
    this.assignment,
    this.faultStatus,
    this.onTap,
  });

  final MobileCellCoord coord;
  final bool isSelected;
  final PatientAssignment? assignment;
  final CabinCellStatus? faultStatus;
  final CabinOperationMode mode;
  final VoidCallback? onTap;

  bool get _isAssigned => assignment != null;

  CabinCellStatus get _status {
    if (faultStatus != null) return faultStatus!;
    if (_isAssigned) return CabinCellStatus.assigned;
    return CabinCellStatus.empty;
  }

  @override
  Widget build(BuildContext context) {
    final colors = CabinCellColors.of(_status);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 92,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colors.bgLight, colors.bgDark],
          ),
          border: Border.all(color: isSelected ? MedColors.blue : colors.border, width: isSelected ? 2 : 1.5),
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected
              ? [const BoxShadow(color: Color(0x4D1A6FD8), blurRadius: 8, offset: Offset(0, 2))]
              : null,
        ),
        child: Center(child: _cellContent()),
      ),
    );
  }

  Widget _cellContent() {
    if (faultStatus != null) {
      return Icon(
        faultStatus == CabinCellStatus.maintenance ? PhosphorIcons.warningCircle() : PhosphorIcons.wrench(),
        size: 16,
        color: faultStatus == CabinCellStatus.maintenance ? MedColors.amber : MedColors.red,
      );
    }

    if (_isAssigned) {
      final name = assignment!.hospitalization?.patient?.fullName ?? '—';
      //final parts = name.trim().split(' ');
      // final initials = parts.length == 1
      //     ? parts[0][0].toUpperCase()
      //     : '${parts.first[0]}${parts.last[0]}'.toUpperCase();
      return Text(
        name,
        style: const TextStyle(
          fontFamily: MedFonts.sans,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Color(0xCC1256AA),
        ),
      );
    }

    return Text(
      '${coord.$2 + 1}·${coord.$3 + 1}',
      style: TextStyle(fontFamily: MedFonts.mono, fontSize: 10, fontWeight: FontWeight.w500, color: MedColors.text4),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// _MobileCellLegend
// ─────────────────────────────────────────────────────────────────

class _MobileCellLegend extends StatelessWidget {
  const _MobileCellLegend({required this.mode, this.faultStatus});

  final CabinOperationMode mode;
  final CabinCellStatus? faultStatus;

  @override
  Widget build(BuildContext context) {
    if (faultStatus != null) {
      return Wrap(
        spacing: 10,
        runSpacing: 4,
        children: [
          _MobileLegendItem(
            color: CabinCellColors.of(faultStatus!),
            label: faultStatus == CabinCellStatus.maintenance
                ? context.l10n.cabin_legendAssignMaintenance
                : context.l10n.cabin_legendAssignFault,
          ),
        ],
      );
    }

    return Wrap(
      spacing: 10,
      runSpacing: 4,
      children: [
        _MobileLegendItem(color: CabinCellColors.of(CabinCellStatus.empty), label: context.l10n.cabin_legendFaultEmpty),
        _MobileLegendItem(
          color: CabinCellColors.of(CabinCellStatus.assigned),
          label: mode == CabinOperationMode.assign ? context.l10n.cabin_legendPatientAssigned : context.l10n.cabin_legendFilled,
        ),
        _MobileLegendItem(color: CabinCellColors.of(CabinCellStatus.fault), label: context.l10n.cabin_legendAssignFault),
        _MobileLegendItem(color: CabinCellColors.of(CabinCellStatus.maintenance), label: context.l10n.cabin_legendAssignMaintenance),
      ],
    );
  }
}

class _MobileLegendItem extends StatelessWidget {
  const _MobileLegendItem({required this.color, required this.label});

  final CabinCellColors color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color.bgLight,
            border: Border.all(color: color.border, width: 1.5),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 5),
        Text(label, style: MedTextStyles.bodySm(color: MedColors.text2)),
      ],
    );
  }
}
