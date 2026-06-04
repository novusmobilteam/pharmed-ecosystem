import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class SectionError extends StatelessWidget {
  const SectionError({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(PhosphorIcons.warningCircle(), size: 28, color: MedColors.text3),
          const SizedBox(height: 8),
          Text(
            message,
            style: MedTextStyles.bodySm(color: MedColors.text3),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: 140,
            child: MedButton(
              label: 'Tekrar Dene',
              size: MedButtonSize.sm,
              variant: MedButtonVariant.secondary,
              prefixIcon: Icon(PhosphorIcons.arrowClockwise()),
              onPressed: onRetry,
            ),
          ),
        ],
      ),
    );
  }
}

class OtherCabinPlaceholder extends StatelessWidget {
  const OtherCabinPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: MedSpacing.insetLg,
      decoration: BoxDecoration(
        color: MedColors.surface,
        borderRadius: MedRadius.lgAll,
        border: Border.all(color: MedColors.border),
        boxShadow: MedShadows.sm,
      ),
      child: const Center(child: Text('SKT geçmiş malzemeler & kritik stoklar (sonraki tur)')),
    );
  }
}
