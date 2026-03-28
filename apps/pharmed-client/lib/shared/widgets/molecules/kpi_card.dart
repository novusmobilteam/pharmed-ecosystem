import 'package:flutter/material.dart';
import '../atoms/atoms.dart';

// ─────────────────────────────────────────────────────────────────
// KpiCard
// [SWREQ-UI-MOL-001] [HAZ-003]
// Kullanım: Dashboard KPI grid içindeki tek kart
// Atomlar : AccentBar + _IconBox + değer + _DeltaBadge
//           + MedLabel + MedProgressBar
// Sınıf  : Class B — yanlış değer yanlış karar tetikleyebilir
// ─────────────────────────────────────────────────────────────────

enum DeltaDirection { up, down, flat }

class KpiCard extends StatelessWidget {
  const KpiCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
    required this.progressValue,
    this.deltaLabel,
    this.deltaDirection,
    this.isStale = false,
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
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
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
              //AccentBar(color: accentColor),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _IconBox(color: accentColor, child: icon),
                        const Spacer(),
                        if (deltaLabel != null && deltaDirection != null)
                          _DeltaBadge(label: deltaLabel!, direction: deltaDirection!),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(value, style: MedTextStyles.titleXl(color: accentColor)),
                    const SizedBox(height: 3),
                    MedLabel(text: label, variant: MedLabelVariant.cardLabel),
                    const SizedBox(height: 14),
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

class _IconBox extends StatelessWidget {
  const _IconBox({required this.color, required this.child});
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: const BorderRadius.all(Radius.circular(9)),
      ),
      alignment: Alignment.center,
      child: IconTheme(
        data: IconThemeData(color: color, size: 16),
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
