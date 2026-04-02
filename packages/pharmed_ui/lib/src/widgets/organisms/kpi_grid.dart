import 'package:flutter/material.dart';
import '../molecules/molecules.dart';

// ─────────────────────────────────────────────────────────────────
// KpiGrid
// [SWREQ-UI-004] [HAZ-003]
// 4'lü KPI kart grid'i.
// isStale → KpiCard değerleri soluklaşır.
// Sınıf: Class B
// ─────────────────────────────────────────────────────────────────

class KpiItem {
  const KpiItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
    required this.progressValue,
    this.deltaLabel,
    this.deltaDirection,
    this.onTap,
  });

  final String label;
  final String value;
  final Widget icon;
  final Color accentColor;
  final double progressValue;
  final String? deltaLabel;
  final DeltaDirection? deltaDirection;
  final VoidCallback? onTap;
}

class KpiGrid extends StatelessWidget {
  const KpiGrid({super.key, required this.items, this.isStale = false})
    : assert(items.length == 4, 'KpiGrid her zaman 4 KpiItem alır');

  final List<KpiItem> items;

  /// [HAZ-007] true → tüm kart değerleri soluklaşır
  final bool isStale;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 170,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return KpiCard(
          label: item.label,
          value: item.value,
          icon: item.icon,
          accentColor: item.accentColor,
          progressValue: item.progressValue,
          deltaLabel: item.deltaLabel,
          deltaDirection: item.deltaDirection,
          isStale: isStale,
          onTap: item.onTap,
        );
      },
    );
  }
}
