import 'package:flutter/material.dart';
import '../atoms/atoms.dart';
import '../molecules/molecules.dart';

// ─────────────────────────────────────────────────────────────────
// CabinStatsGrid
// [SWREQ-UI-002] [HAZ-007]
// Kabin widget'ındaki 4'lü istatistik grid'i.
// isStale → StatBox değerleri soluklaşır, veri güvenilir değil sinyali.
// Sınıf: Class B
// ─────────────────────────────────────────────────────────────────

class CabinStatsGrid extends StatelessWidget {
  const CabinStatsGrid({
    super.key,
    required this.totalDrawers,
    required this.fullDrawers,
    required this.emptyDrawers,
    required this.criticalCount,
    required this.todayOperations,
    required this.lastOpenedAt,
    required this.lastOpenedBy,
    this.isStale = false,
  });

  final int totalDrawers;
  final int fullDrawers;
  final int emptyDrawers;
  final int criticalCount;
  final int todayOperations;

  /// Format: "08:31"
  final String lastOpenedAt;

  /// Format: "Ayşe Kara"
  final String lastOpenedBy;

  /// [HAZ-007] true → tüm StatBox değerleri soluklaşır
  final bool isStale;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 1.2,
      children: [
        StatBox(
          label: 'Çekmece',
          value: '$totalDrawers',
          valueColor: MedColors.blue,
          subLabel: '$fullDrawers dolu · $emptyDrawers boş',
          isStale: isStale,
        ),
        StatBox(
          label: 'Kritik Stok',
          value: '$criticalCount',
          valueColor: MedColors.red,
          subLabel: 'yenileme gerekli',
          isStale: isStale,
        ),
        StatBox(
          label: 'Bugün İşlem',
          value: '$todayOperations',
          valueColor: MedColors.green,
          subLabel: 'son 8 saat',
          isStale: isStale,
        ),
        StatBox(
          label: 'Son Açılış',
          value: lastOpenedAt,
          valueColor: MedColors.amber,
          subLabel: lastOpenedBy,
          isStale: isStale,
        ),
      ],
    );
  }
}
