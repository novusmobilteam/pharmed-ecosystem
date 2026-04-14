import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

// CabinVisualizer
// [SWREQ-UI-001] [HAZ-003]
// Kabinin fiziksel görselini LED + çekmece grid + legend ile gösterir.
// Kritik/düşük stok DrawerCell renk sistemiyle ayrıştırılır.
// Sınıf: Class B — Yanlış stok rengi yanlış müdahale tetikler.

final class _StatusColors {
  const _StatusColors({required this.bg, required this.border});
  final Color bg;
  final Color border;

  static _StatusColors of(DrawerStatus status) => switch (status) {
    DrawerStatus.full => const _StatusColors(bg: Color(0xFFEDF6FF), border: Color(0xFF90C4F5)),
    DrawerStatus.low => const _StatusColors(bg: Color(0xFFFFFBEB), border: Color(0xFFFCD34D)),
    DrawerStatus.critical => const _StatusColors(bg: Color(0xFFFFF5F5), border: Color(0xFFFCA5A5)),
    DrawerStatus.empty => _StatusColors(bg: MedColors.surface3, border: MedColors.border2),
  };
}

class CabinVisualizer extends StatelessWidget {
  const CabinVisualizer({
    super.key,
    required this.cabinId,
    required this.powerStatus,
    required this.alertStatus,
    required this.slots,
  });

  final String cabinId;
  final LedStatus powerStatus;
  final LedStatus alertStatus;
  final List<DrawerSlotVisual> slots;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MedColors.surface2,
        border: Border.all(color: MedColors.border, width: 1.5),
        borderRadius: MedRadius.mdAll,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          //_CabinHeader(cabinId: cabinId, powerStatus: powerStatus, alertStatus: alertStatus),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < slots.length; i++) ...[
                  _SlotView(slot: slots[i]),
                  if (i < slots.length - 1) const SizedBox(height: 4),
                ],
              ],
            ),
          ),
          const _CabinLegend(),
        ],
      ),
    );
  }
}

// Slot dispatcher

class _SlotView extends StatelessWidget {
  const _SlotView({required this.slot});

  final DrawerSlotVisual slot;

  @override
  Widget build(BuildContext context) {
    final s = slot;
    return switch (s) {
      KubicSlotVisual() => _KubicSlotView(slot: s),
      UnitDoseSlotVisual() => _UnitDoseSlotView(slot: s),
      SerumSlotVisual() => _SerumSlotView(slot: s),
      MobileSlotVisual() => _MobileSlotView(slot: s),
    };
  }
}

class _KubicSlotView extends StatelessWidget {
  const _KubicSlotView({required this.slot});
  final KubicSlotVisual slot;

  @override
  Widget build(BuildContext context) {
    // Düz listeyi satırlara böl
    final rows = <List<DrawerStatus>>[];
    for (int i = 0; i < slot.cells.length; i += slot.columnCount) {
      rows.add(slot.cells.sublist(i, (i + slot.columnCount).clamp(0, slot.cells.length)));
    }

    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFFDCE8F5),
        border: Border.all(color: const Color(0xFFA8BEDB), width: 1.5),
        borderRadius: MedRadius.smAll,
        boxShadow: const [BoxShadow(color: Color(0x1F1E3C64), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int r = 0; r < rows.length; r++) ...[
            Row(
              children: [
                for (int c = 0; c < rows[r].length; c++) ...[
                  Expanded(child: _KubicCell(status: rows[r][c])),
                  if (c < rows[r].length - 1) const SizedBox(width: 3),
                ],
              ],
            ),
            if (r < rows.length - 1) const SizedBox(height: 3),
          ],
        ],
      ),
    );
  }
}

class _KubicCell extends StatelessWidget {
  const _KubicCell({required this.status});
  final DrawerStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = _StatusColors.of(status);
    return Container(
      height: 14,
      decoration: BoxDecoration(
        color: colors.bg,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

class _UnitDoseSlotView extends StatelessWidget {
  const _UnitDoseSlotView({required this.slot});
  final UnitDoseSlotVisual slot;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFD8E4F0),
        border: Border.all(color: const Color(0xFFA0B8D0), width: 1.5),
        borderRadius: MedRadius.smAll,
        boxShadow: const [BoxShadow(color: Color(0x1F1E3C64), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          for (int i = 0; i < slot.cells.length; i++) ...[
            Expanded(child: _UnitDoseCell(status: slot.cells[i])),
            if (i < slot.cells.length - 1) const SizedBox(width: 2),
          ],
        ],
      ),
    );
  }
}

class _UnitDoseCell extends StatelessWidget {
  const _UnitDoseCell({required this.status});

  final DrawerStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = _StatusColors.of(status);
    return Container(
      height: 24,
      decoration: BoxDecoration(
        color: colors.bg,
        border: Border.all(color: colors.border, width: 1.5),
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}

class _SerumSlotView extends StatelessWidget {
  const _SerumSlotView({required this.slot});
  final SerumSlotVisual slot;

  static const _unitHeight = 24.0;
  static const _gap = 4.0;

  @override
  Widget build(BuildContext context) {
    final height = slot.heightFactor * _unitHeight + (slot.heightFactor - 1) * _gap + 8;
    final colors = _StatusColors.of(slot.status);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: colors.bg,
        border: Border.all(color: colors.border, width: 1.5),
        borderRadius: MedRadius.smAll,
      ),
      alignment: Alignment.center,
      child: Text(
        'SRM',
        style: TextStyle(fontFamily: MedFonts.mono, fontSize: 7, color: MedColors.text3, letterSpacing: 1),
      ),
    );
  }
}

class _MobileSlotView extends StatelessWidget {
  const _MobileSlotView({required this.slot});

  final MobileSlotVisual slot;

  @override
  Widget build(BuildContext context) {
    final colors = _StatusColors.of(DrawerStatus.empty);
    return Container(
      height: 24,
      decoration: BoxDecoration(
        color: colors.bg,
        border: Border.all(color: colors.border, width: 1.5),
        borderRadius: MedRadius.smAll,
      ),
    );
  }
}

class _CabinLegend extends StatelessWidget {
  const _CabinLegend();

  static const _items = [
    (DrawerStatus.full, 'Dolu'),
    (DrawerStatus.low, 'Düşük'),
    (DrawerStatus.critical, 'Kritik'),
    (DrawerStatus.empty, 'Boş'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: MedColors.border2)),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 4,
        children: _items.map((item) {
          final colors = _StatusColors.of(item.$1);
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: colors.bg,
                  border: Border.all(color: colors.border),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 4),
              Text(item.$2, style: MedTextStyles.bodySm(color: MedColors.text2)),
            ],
          );
        }).toList(),
      ),
    );
  }
}
