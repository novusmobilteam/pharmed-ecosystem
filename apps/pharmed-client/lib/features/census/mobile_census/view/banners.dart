part of 'mobile_census_dialog.dart';

enum _BannerTone { error, warning, info }

class _CensusBanner extends StatelessWidget {
  const _CensusBanner({required this.tone, required this.icon, required this.message});

  final _BannerTone tone;
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (tone) {
      _BannerTone.error => (MedColors.redLight, MedColors.red),
      _BannerTone.warning => (MedColors.amberLight, MedColors.amber),
      _BannerTone.info => (MedColors.blueLight, MedColors.blue),
    };
    return Container(
      padding: MedSpacing.insetMd,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: MedRadius.mdAll,
        border: Border.all(color: fg.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: fg),
          const SizedBox(width: MedSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: MedTextStyles.bodySm(color: fg, weight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
