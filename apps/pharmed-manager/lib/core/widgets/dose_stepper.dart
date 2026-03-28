import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../core.dart';

enum DoseStepperType { large, compact }

class DoseStepper extends StatelessWidget {
  final double value;
  final double step;
  final String unit;
  final String? title; // Numpad başlığı için
  final ValueChanged<double> onChanged;
  final double min;
  final double? max;
  final DoseStepperType type;

  const DoseStepper({
    super.key,
    required this.value,
    required this.onChanged,
    required this.unit,
    this.title,
    this.step = 1.0,
    this.min = 0.0,
    this.max,
    this.type = DoseStepperType.large,
  });

  factory DoseStepper.compact({
    required double value,
    required ValueChanged<double> onChanged,
    required String unit,
    String? title,
    double step = 1.0,
    double min = 0.0,
    double? max,
  }) {
    return DoseStepper(
      value: value,
      onChanged: onChanged,
      unit: unit,
      title: title,
      step: step,
      min: min,
      max: max,
      type: DoseStepperType.compact,
    );
  }

  @override
  Widget build(BuildContext context) {
    return type == DoseStepperType.compact ? _buildCompact(context) : _buildLarge(context);
  }

  // --- Numpad Tetikleyici ---
  Future<void> _handleManualEntry(BuildContext context) async {
    final String? result = await showNumpadView(
      context,
      title: title ?? '$unit Miktarı Giriniz',
      hintText: '0.0',
      initialValue: value == 0 ? '' : value.formatFractional,
    );

    if (result != null) {
      final double? parsedVal = double.tryParse(result);
      if (parsedVal != null) {
        // Adım miktarına göre yuvarlama ve sınır kontrolü
        double finalVal = (parsedVal / step).round() * step;

        if (finalVal < min) finalVal = min;
        if (max != null && finalVal > max!) finalVal = max!;

        onChanged(finalVal);
      }
    }
  }

  // --- COMPACT TASARIM ---
  Widget _buildCompact(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colorScheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCompactBtn(context, PhosphorIcons.minus(), value > min ? () => onChanged(value - step) : null),
          GestureDetector(
            onTap: () => _handleManualEntry(context), // Numpad burada tetikleniyor
            behavior: HitTestBehavior.opaque,
            child: Container(
              constraints: const BoxConstraints(minWidth: 48),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value.formatFractional,
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.colorScheme.primary,
                      height: 1.1,
                    ),
                  ),
                  Text(unit, style: context.textTheme.labelSmall?.copyWith(fontSize: 9)),
                ],
              ),
            ),
          ),
          _buildCompactBtn(
              context, PhosphorIcons.plus(), (max == null || value < max!) ? () => onChanged(value + step) : null),
        ],
      ),
    );
  }

  // --- LARGE TASARIM ---
  Widget _buildLarge(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colorScheme.onSurfaceVariant.withAlpha(77)),
      ),
      child: Row(
        children: [
          _buildLargeBtn(context, PhosphorIcons.minus(PhosphorIconsStyle.bold),
              value > min ? () => onChanged(value - step) : null),
          Expanded(
            child: GestureDetector(
              onTap: () => _handleManualEntry(context), // Numpad burada tetikleniyor
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(value.formatFractional,
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.colorScheme.primary,
                      )),
                  Text(unit, style: context.textTheme.labelSmall),
                ],
              ),
            ),
          ),
          _buildLargeBtn(context, PhosphorIcons.plus(PhosphorIconsStyle.bold),
              (max == null || value < max!) ? () => onChanged(value + step) : null),
        ],
      ),
    );
  }

  // --- YARDIMCI BUTONLAR (Kompakt ve Large için aynı kaldı) ---
  Widget _buildCompactBtn(BuildContext context, IconData icon, VoidCallback? onTap) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      padding: EdgeInsets.zero,
      style: IconButton.styleFrom(
        backgroundColor: context.colorScheme.primaryContainer.withValues(alpha: 0.5),
        foregroundColor: context.colorScheme.primary,
        disabledForegroundColor: context.colorScheme.onSurface.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildLargeBtn(BuildContext context, IconData icon, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 60,
        alignment: Alignment.center,
        child: Icon(icon, size: 22, color: onTap == null ? Colors.grey : null),
      ),
    );
  }
}
