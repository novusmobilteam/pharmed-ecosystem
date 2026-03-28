import 'package:flutter/material.dart';
import '../atoms/atoms.dart';
import '../molecules/molecules.dart';

// ─────────────────────────────────────────────────────────────────
// CabinVisualizer
// [SWREQ-UI-001] [HAZ-003]
// Kabinin fiziksel görselini LED + çekmece grid + legend ile gösterir.
// Kritik/düşük stok DrawerCell renk sistemiyle ayrıştırılır.
// Sınıf: Class B — Yanlış stok rengi yanlış müdahale tetikler.
// ─────────────────────────────────────────────────────────────────

class DrawerLegendItem {
  const DrawerLegendItem({required this.status, required this.label});
  final DrawerStatus status;
  final String label;
}

class CabinVisualizer extends StatelessWidget {
  const CabinVisualizer({
    super.key,
    required this.cabinId,
    required this.powerStatus,
    required this.alertStatus,
    required this.drawerGrid,
    this.legend = _defaultLegend,
  });

  /// Örnek: "CB-304"
  final String cabinId;

  final LedStatus powerStatus;
  final LedStatus alertStatus;

  /// Satır × Sütun. Her iç liste 3 eleman içermeli (DrawerRow assert ile kontrol eder).
  final List<List<DrawerStatus>> drawerGrid;

  final List<DrawerLegendItem> legend;

  static const List<DrawerLegendItem> _defaultLegend = [
    DrawerLegendItem(status: DrawerStatus.full, label: 'Dolu — Normal Stok'),
    DrawerLegendItem(status: DrawerStatus.low, label: 'Düşük Stok'),
    DrawerLegendItem(status: DrawerStatus.critical, label: 'Kritik / Boşalmak Üzere'),
    DrawerLegendItem(status: DrawerStatus.empty, label: 'Boş / Atanmamış'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MedColors.surface2,
        border: Border.all(color: MedColors.border, width: 1.5),
        borderRadius: MedRadius.mdAll,
      ),
      child: Column(
        children: [
          // ── Kabin header — LED + ID ──────────────────────
          _CabinHeader(cabinId: cabinId, powerStatus: powerStatus, alertStatus: alertStatus),

          // ── Çekmece grid ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                for (int i = 0; i < drawerGrid.length; i++) ...[
                  DrawerRow(cells: drawerGrid[i].map((s) => DrawerCell(status: s)).toList()),
                  if (i < drawerGrid.length - 1) const SizedBox(height: 5),
                ],
              ],
            ),
          ),

          // ── Legend ───────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: MedColors.border2)),
            ),
            child: Column(children: legend.map((item) => _LegendRow(item: item)).toList()),
          ),
        ],
      ),
    );
  }
}

// ── Yardımcı widget'lar ───────────────────────────────────────────

class _CabinHeader extends StatelessWidget {
  const _CabinHeader({required this.cabinId, required this.powerStatus, required this.alertStatus});

  final String cabinId;
  final LedStatus powerStatus;
  final LedStatus alertStatus;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE8EDF5), Color(0xFFDDE3EC)],
        ),
        border: Border(bottom: BorderSide(color: MedColors.border)),
        borderRadius: const BorderRadius.only(topLeft: MedRadius.md, topRight: MedRadius.md),
      ),
      child: Row(
        children: [
          LedIndicator(status: powerStatus),
          const SizedBox(width: 5),
          LedIndicator(status: alertStatus),
          const Spacer(),
          Text(
            cabinId,
            style: TextStyle(fontFamily: MedFonts.mono, fontSize: 9, color: MedColors.text3, letterSpacing: 1),
          ),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.item});

  final DrawerLegendItem item;

  @override
  Widget build(BuildContext context) {
    final colors = _resolveColors(item.status);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: colors.background,
              border: Border.all(color: colors.border),
              borderRadius: MedRadius.smAll,
            ),
          ),
          const SizedBox(width: 8),
          Text(item.label, style: MedTextStyles.bodySm(color: MedColors.text2)),
        ],
      ),
    );
  }

  _LegendColors _resolveColors(DrawerStatus status) {
    return switch (status) {
      DrawerStatus.full => const _LegendColors(Color(0xFFEDF6FF), Color(0xFF90C4F5)),
      DrawerStatus.low => const _LegendColors(Color(0xFFFFFBEB), Color(0xFFFCD34D)),
      DrawerStatus.critical => const _LegendColors(Color(0xFFFFF5F5), Color(0xFFFCA5A5)),
      DrawerStatus.empty => _LegendColors(MedColors.surface3, MedColors.border2),
    };
  }
}

final class _LegendColors {
  const _LegendColors(this.background, this.border);
  final Color background;
  final Color border;
}
