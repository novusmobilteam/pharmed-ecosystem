part of 'dashboard_screen.dart';

/// Tüm dashboard panellerinin ortak başlığı.
class _PanelHeader extends StatelessWidget {
  const _PanelHeader({required this.title, this.icon, this.leading, this.trailing});

  final String title;
  final IconData? icon;

  /// Icon yerine özel bir widget (ör. StatusDot) koymak için.
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: MedSpacing.xl, vertical: MedSpacing.lg),
      decoration: const BoxDecoration(
        color: MedColors.surface2,
        border: Border(bottom: BorderSide(color: MedColors.border2)),
        borderRadius: BorderRadius.only(topLeft: MedRadius.lg, topRight: MedRadius.lg),
      ),
      child: Row(
        children: [
          if (leading != null) leading! else if (icon != null) Icon(icon, size: 18, color: MedColors.text3),
          const SizedBox(width: MedSpacing.md),
          Expanded(child: Text(title, style: MedTextStyles.titleSm())),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.label, required this.color, required this.background});

  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: MedSpacing.md, vertical: MedSpacing.xs),
      decoration: BoxDecoration(color: background, borderRadius: MedRadius.smAll),
      child: Text(
        label,
        style: MedTextStyles.bodySm(color: color, weight: FontWeight.w500),
      ),
    );
  }
}

class _PanelEmpty extends StatelessWidget {
  const _PanelEmpty({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: MedSpacing.xl, vertical: MedSpacing.xl3),
      child: Column(
        children: [
          Icon(icon, size: 28, color: MedColors.text4),
          const SizedBox(height: MedSpacing.md),
          Text(
            label,
            style: MedTextStyles.bodySm(color: MedColors.text3),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
