part of 'dashboard_screen.dart';

class _SectionError extends StatelessWidget {
  const _SectionError({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: MedColors.redLight,
        border: Border.all(color: MedColors.red.withAlpha(60)),
        borderRadius: MedRadius.mdAll,
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 16, color: MedColors.red),
          const SizedBox(width: 8),
          Text(label, style: MedTextStyles.bodySm(color: MedColors.red)),
        ],
      ),
    );
  }
}
