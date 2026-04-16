// lib/shared/widgets/mobile_cabin_detail_panel.dart
//
// [SWREQ-UI-CAB-007]
// Mobil kabin işlemleri ekranının orta paneli.
// Seçili MobileSlotVisual'ın rowColumns grid'ini gösterir.
//
// Her hücre tıklanabilir — tıklamada (slotId, rowIndex, colIndex) üretilir.
// Atama modunda hücre rengi assignments listesinden gelir.
//
// KULLANIM:
//   MobileCabinDetailPanel(
//     slot: selectedSlot,
//     mode: CabinOperationMode.assign,
//     assignments: assignments,
//     selectedCell: (slotId, rowIndex, colIndex),
//     onCellTap: (slotId, rowIndex, colIndex) => notifier.onCellTap(...),
//   )
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:pharmed_client/core/enums/cabin_operation_mode.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

// Hücre koordinatı — (slotId, rowIndex, colIndex)
typedef MobileCellCoord = (int slotId, int rowIndex, int colIndex);

// ─────────────────────────────────────────────────────────────────
// MobileCabinDetailPanel
// ─────────────────────────────────────────────────────────────────

class MobileCabinDetailPanel extends StatelessWidget {
  const MobileCabinDetailPanel({
    super.key,
    required this.mode,
    this.slot,
    this.assignments = const [],
    this.selectedCell,
    this.onCellTap,
  });

  final CabinOperationMode mode;
  final MobileSlotVisual? slot;

  /// Atama listesi — hasta bazlı assign modunda hücre rengini belirler.
  /// Şimdilik koordinat → assignment eşleştirmesi için kullanılacak
  /// (PatientCabinAssignment modeli netleşince güncellenir).
  final List<MedicineAssignment> assignments;

  final MobileCellCoord? selectedCell;
  final void Function(MobileCellCoord coord)? onCellTap;

  @override
  Widget build(BuildContext context) {
    final s = slot;
    if (s == null) return const _EmptyState();

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
          _DetailHeader(slot: s, mode: mode),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _GridBody(
                slot: s,
                mode: mode,
                assignments: assignments,
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
// _DetailHeader
// ─────────────────────────────────────────────────────────────────

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({required this.slot, required this.mode});

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
          Text('Mobil Çekmece', style: MedTextStyles.titleMd()),
          const SizedBox(height: 3),
          Text(
            '${slot.rowCount} satır · ${slot.totalCells} göz  ·  '
            '${slot.rowColumns.join(", ")} sütun',
            style: MedTextStyles.monoMd(color: MedColors.text3),
          ),
          const SizedBox(height: 8),
          _ModeBanner(mode: mode),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// _ModeBanner — assign modunda hasta atama mesajı
// ─────────────────────────────────────────────────────────────────

class _ModeBanner extends StatelessWidget {
  const _ModeBanner({required this.mode});
  final CabinOperationMode mode;

  @override
  Widget build(BuildContext context) {
    final (bg, border, text, message) = _config(mode);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border, width: 1.5),
        borderRadius: MedRadius.smAll,
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 14, color: text),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontFamily: MedFonts.sans, fontSize: 11, fontWeight: FontWeight.w500, color: text),
            ),
          ),
        ],
      ),
    );
  }

  (Color, Color, Color, String) _config(CabinOperationMode mode) => switch (mode) {
    CabinOperationMode.assign => (
      const Color(0xFFE8F1FC),
      const Color(0xFFC4D9F5),
      const Color(0xFF1256AA),
      'Hasta Atama — gözlere hasta / yatış atayın.',
    ),
    CabinOperationMode.fill => (
      const Color(0xFFE6F7F2),
      const Color(0xFF9ED9C4),
      const Color(0xFF086E4A),
      'İlaç Dolum — dolum yapılacak göze dokunun.',
    ),
    CabinOperationMode.count => (
      const Color(0xFFFEF3E2),
      const Color(0xFFF5C97A),
      const Color(0xFF92520A),
      'Sayım — fiili miktarı girin.',
    ),
    CabinOperationMode.fault => (
      const Color(0xFFFEF2F2),
      const Color(0xFFF9A8A8),
      const Color(0xFF9B1C1C),
      'Arıza — arızalı gözü işaretleyin.',
    ),
  };
}

// ─────────────────────────────────────────────────────────────────
// _GridBody — rowColumns'tan grid üretir
// ─────────────────────────────────────────────────────────────────

class _GridBody extends StatelessWidget {
  const _GridBody({
    required this.slot,
    required this.mode,
    required this.assignments,
    this.selectedCell,
    this.onCellTap,
  });

  final MobileSlotVisual slot;
  final CabinOperationMode mode;
  final List<MedicineAssignment> assignments;
  final MobileCellCoord? selectedCell;
  final void Function(MobileCellCoord coord)? onCellTap;

  @override
  Widget build(BuildContext context) {
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
                  child: _GridRow(
                    slotId: slot.slotId,
                    rowIndex: rowIdx,
                    colCount: slot.rowColumns[rowIdx],
                    mode: mode,
                    assignments: assignments,
                    selectedCell: selectedCell,
                    onCellTap: onCellTap,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _Legend(mode: mode),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// _GridRow — tek satır
// ─────────────────────────────────────────────────────────────────

class _GridRow extends StatelessWidget {
  const _GridRow({
    required this.slotId,
    required this.rowIndex,
    required this.colCount,
    required this.mode,
    required this.assignments,
    this.selectedCell,
    this.onCellTap,
  });

  final int slotId;
  final int rowIndex;
  final int colCount;
  final CabinOperationMode mode;
  final List<MedicineAssignment> assignments;
  final MobileCellCoord? selectedCell;
  final void Function(MobileCellCoord coord)? onCellTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Satır etiketi
        SizedBox(
          width: 20,
          child: Text(
            '${rowIndex + 1}',
            style: TextStyle(fontFamily: MedFonts.mono, fontSize: 9, color: MedColors.text3),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(width: 4),
        // Hücreler
        Expanded(
          child: Row(
            spacing: 4,
            children: List.generate(colCount, (colIdx) {
              final coord = (slotId, rowIndex, colIdx);
              final isSelected = selectedCell == coord;

              // TODO: PatientCabinAssignment modeli gelince
              // koordinat → assignment lookup buraya eklenecek
              final isAssigned = false;

              return Expanded(
                child: _MobileCell(
                  coord: coord,
                  isSelected: isSelected,
                  isAssigned: isAssigned,
                  mode: mode,
                  onTap: () => onCellTap?.call(coord),
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
// _MobileCell — tek göz
// ─────────────────────────────────────────────────────────────────

class _MobileCell extends StatelessWidget {
  const _MobileCell({
    required this.coord,
    required this.isSelected,
    required this.isAssigned,
    required this.mode,
    required this.onTap,
  });

  final MobileCellCoord coord;
  final bool isSelected;
  final bool isAssigned;
  final CabinOperationMode mode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final status = isAssigned ? _CellStatus.assigned : _CellStatus.empty;
    final colors = _cellColors(status);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 52,
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
        child: Center(
          child: Text(
            // Satır:Sütun etiketi
            '${coord.$2 + 1}·${coord.$3 + 1}',
            style: TextStyle(
              fontFamily: MedFonts.mono,
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isAssigned ? const Color(0xCC1256AA) : MedColors.text4,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Renk sistemi
// ─────────────────────────────────────────────────────────────────

enum _CellStatus { empty, assigned }

final class _ColorSet {
  const _ColorSet({required this.bgLight, required this.bgDark, required this.border});

  final Color bgLight;
  final Color bgDark;
  final Color border;
}

_ColorSet _cellColors(_CellStatus status) => switch (status) {
  _CellStatus.empty => const _ColorSet(
    bgLight: Color(0xFFE8EDF5),
    bgDark: Color(0xFFD8E2EE),
    border: Color(0xFFA8B8CC),
  ),
  _CellStatus.assigned => const _ColorSet(
    bgLight: Color(0xFFDDEEFF),
    bgDark: Color(0xFFC8D8EE),
    border: Color(0xFF7AB0D8),
  ),
};

// ─────────────────────────────────────────────────────────────────
// _Legend
// ─────────────────────────────────────────────────────────────────

class _Legend extends StatelessWidget {
  const _Legend({required this.mode});
  final CabinOperationMode mode;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 4,
      children: [
        _LegendItem(color: _cellColors(_CellStatus.empty), label: 'Boş göz'),
        _LegendItem(
          color: _cellColors(_CellStatus.assigned),
          label: mode == CabinOperationMode.assign ? 'Hasta atanmış' : 'Dolu',
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final _ColorSet color;
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

// ─────────────────────────────────────────────────────────────────
// _EmptyState
// ─────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MedColors.surface,
        border: Border.all(color: MedColors.border, width: 1.5),
        borderRadius: MedRadius.lgAll,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.touch_app_outlined, size: 48, color: MedColors.text4),
            const SizedBox(height: 16),
            Text('Bir çekmeceye dokunun', style: MedTextStyles.bodyMd(color: MedColors.text3)),
            const SizedBox(height: 6),
            Text('Mobil kabin göz grid\'i görüntülenecek', style: MedTextStyles.monoMd(color: MedColors.text4)),
          ],
        ),
      ),
    );
  }
}
