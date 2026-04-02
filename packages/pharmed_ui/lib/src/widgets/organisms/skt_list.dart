import 'package:flutter/material.dart';
import 'package:pharmed_ui/src/widgets/atoms/med_badge.dart';
import 'package:pharmed_ui/src/widgets/atoms/ring_chart.dart';
import 'package:pharmed_ui/src/widgets/atoms/status_dot.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import '../molecules/molecules.dart';

// ─────────────────────────────────────────────────────────────────
// SktList
// [SWREQ-UI-005] [HAZ-008]
// Son kullanma tarihi yaklaşan/geçen ilaç listesi.
// Geçmiş SKT ayrı renk + "imha et" etiketiyle gösterilir.
// Alt kısımda RingChart özet gösterilir.
// Sınıf: Class B — Geçmiş SKT gözden kaçarsa [HAZ-008]
// ─────────────────────────────────────────────────────────────────

class SktItem {
  const SktItem({
    required this.medicineName,
    required this.detail,
    required this.status,
    this.daysRemaining,
    this.onTap,
  });

  final String medicineName;
  final String detail;
  final SktStatus status;
  final int? daysRemaining;
  final VoidCallback? onTap;
}

class SktList extends StatelessWidget {
  const SktList({super.key, required this.items, this.isStale = false});

  final List<SktItem> items;

  /// [HAZ-007] true → header badge soluklaşır
  final bool isStale;

  @override
  Widget build(BuildContext context) {
    // [HAZ-008] Otomatik sınıflandırma — sayım hesapları
    final expiredCount = items.where((i) => i.status == SktStatus.expired).length;
    final criticalCount = items.where((i) => i.status == SktStatus.critical).length;
    final warningCount = items.where((i) => i.status == SktStatus.warning).length;
    final total = items.length;

    return Container(
      decoration: BoxDecoration(
        color: MedColors.surface,
        border: Border.all(color: MedColors.border),
        borderRadius: MedRadius.lgAll,
        boxShadow: MedShadows.md,
      ),
      child: Column(
        children: [
          // ── Header ───────────────────────────────────────
          _SktHeader(itemCount: total, isStale: isStale),

          // ── Liste ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                for (int i = 0; i < items.length; i++) ...[
                  SktRow(
                    medicineName: items[i].medicineName,
                    detail: items[i].detail,
                    status: items[i].status,
                    daysRemaining: items[i].daysRemaining,
                    onTap: items[i].onTap,
                  ),
                  if (i < items.length - 1) const SizedBox(height: 4),
                ],
              ],
            ),
          ),

          // ── Ring chart özet ───────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: MedColors.border2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                RingChart(count: criticalCount, total: total, color: MedColors.red, label: 'Kritik\n(<7 gün)'),
                RingChart(count: warningCount, total: total, color: MedColors.amber, label: 'Uyarı\n(7-30 gün)'),
                RingChart(count: expiredCount, total: total, color: MedColors.redDark, label: 'Geçmiş\nSKT'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────

class _SktHeader extends StatelessWidget {
  const _SktHeader({required this.itemCount, required this.isStale});

  final int itemCount;
  final bool isStale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: MedColors.border2)),
      ),
      child: Row(
        children: [
          StatusDot(color: MedColors.amber),
          const SizedBox(width: 8),
          Text('SKT DURUMU', style: MedTextStyles.titleSm()),
          const Spacer(),
          AnimatedOpacity(
            opacity: isStale ? 0.45 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: MedBadge(label: '$itemCount Kalem', variant: MedBadgeVariant.amber),
          ),
        ],
      ),
    );
  }
}
