import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

// ─────────────────────────────────────────────────────────────────
// MedKpiCard
// [SWREQ-UI-MOL-001] [HAZ-003]
// Kullanım: Dashboard KPI grid içindeki tek kart
// Atomlar : _IconBox + değer + _DeltaBadge + MedLabel + MedProgressBar
// Sınıf  : Class B — yanlış değer yanlış karar tetikleyebilir
// ─────────────────────────────────────────────────────────────────

enum DeltaDirection { up, down, flat }

/// KPI metrik kartı — ikon, değer, delta badge ve progress bar.
///
/// ```dart
/// MedKpiCard(label: 'Aktif Hasta', value: '142', icon: ..., accentColor: MedColors.blue, progressValue: 0.71)
/// MedKpiCard(..., dense: true)  // kompakt mod
/// ```
class MedKpiCard extends StatelessWidget {
  const MedKpiCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
    required this.progressValue,
    this.deltaLabel,
    this.deltaDirection,
    this.isStale = false,
    this.dense = false,
    this.onTap,
  });

  final String label;
  final String value;
  final Widget icon;
  final Color accentColor;

  /// 0.0 – 1.0
  final double progressValue;

  /// Örn: "▲ 3", "▼ 1", "— 0"
  final String? deltaLabel;
  final DeltaDirection? deltaDirection;

  /// [HAZ-007] stale → değerler soluk gösterilir
  final bool isStale;

  /// Kompakt mod — padding ve font boyutları küçülür.
  final bool dense;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final innerPad = dense
        ? const EdgeInsets.fromLTRB(12, 12, 12, 10)
        : const EdgeInsets.fromLTRB(16, 16, 16, 14);
    final gap = dense ? 10.0 : 14.0;
    final valueStyle = dense
        ? MedTextStyles.titleLg(color: accentColor)
        : MedTextStyles.titleXl(color: accentColor);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isStale ? 0.5 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: MedColors.surface,
            border: Border.all(color: MedColors.border),
            borderRadius: MedRadius.lgAll,
            boxShadow: MedShadows.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: innerPad,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _IconBox(color: accentColor, child: icon, dense: dense),
                        const Spacer(),
                        if (deltaLabel != null && deltaDirection != null)
                          _DeltaBadge(label: deltaLabel!, direction: deltaDirection!),
                      ],
                    ),
                    SizedBox(height: gap),
                    Text(value, style: valueStyle),
                    const SizedBox(height: 3),
                    MedLabel(text: label, variant: MedLabelVariant.cardLabel),
                    SizedBox(height: gap),
                    MedProgressBar(value: progressValue.clamp(0.0, 1.0), color: accentColor),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Backward compat alias.
typedef KpiCard = MedKpiCard;

class _IconBox extends StatelessWidget {
  const _IconBox({required this.color, required this.child, this.dense = false});
  final Color color;
  final Widget child;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final boxSize = dense ? 28.0 : 34.0;
    return Container(
      width: boxSize,
      height: boxSize,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: const BorderRadius.all(Radius.circular(9)),
      ),
      alignment: Alignment.center,
      child: IconTheme(
        data: IconThemeData(color: color, size: dense ? 13.0 : 16.0),
        child: child,
      ),
    );
  }
}

class _DeltaBadge extends StatelessWidget {
  const _DeltaBadge({required this.label, required this.direction});
  final String label;
  final DeltaDirection direction;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (direction) {
      DeltaDirection.up => (MedColors.greenLight, MedColors.green),
      DeltaDirection.down => (MedColors.redLight, MedColors.red),
      DeltaDirection.flat => (MedColors.surface3, MedColors.text3),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: const BorderRadius.all(Radius.circular(5))),
      child: Text(label, style: MedTextStyles.monoSm(color: fg)),
    );
  }
}
