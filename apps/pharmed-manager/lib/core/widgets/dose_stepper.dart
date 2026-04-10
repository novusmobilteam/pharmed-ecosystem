import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../core.dart';

enum DoseStepperType { large, compact }

enum DoseStepperPlatform { touch, desktop }

class DoseStepper extends StatelessWidget {
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
    this.platform = DoseStepperPlatform.touch,
  });

  final double value;
  final double step;
  final String unit;
  final String? title;
  final ValueChanged<double> onChanged;
  final double min;
  final double? max;
  final DoseStepperType type;
  final DoseStepperPlatform platform;

  factory DoseStepper.compact({
    required double value,
    required ValueChanged<double> onChanged,
    required String unit,
    String? title,
    double step = 1.0,
    double min = 0.0,
    double? max,
    DoseStepperPlatform platform = DoseStepperPlatform.touch,
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
      platform: platform,
    );
  }

  factory DoseStepper.desktop({
    required double value,
    required ValueChanged<double> onChanged,
    required String unit,
    String? title,
    double step = 1.0,
    double min = 0.0,
    double? max,
    DoseStepperType type = DoseStepperType.large,
  }) {
    return DoseStepper(
      value: value,
      onChanged: onChanged,
      unit: unit,
      title: title,
      step: step,
      min: min,
      max: max,
      type: type,
      platform: DoseStepperPlatform.desktop,
    );
  }

  bool get _canDecrement => value > min;
  bool get _canIncrement => max == null || value < max!;

  @override
  Widget build(BuildContext context) {
    return type == DoseStepperType.compact ? _buildCompact(context) : _buildLarge(context);
  }

  Future<void> _handleManualEntry(BuildContext context) async {
    if (platform == DoseStepperPlatform.desktop) return;

    final String? result = await showNumpadView(
      context,
      title: title ?? '$unit Miktarı Giriniz',
      hintText: '0.0',
      initialValue: value == 0 ? '' : value.formatFractional,
    );

    if (result != null) {
      final double? parsed = double.tryParse(result);
      if (parsed != null) {
        double final_ = (parsed / step).round() * step;
        if (final_ < min) final_ = min;
        if (max != null && final_ > max!) final_ = max!;
        onChanged(final_);
      }
    }
  }

  // ── LARGE ──────────────────────────────────────────────────────

  Widget _buildLarge(BuildContext context) {
    final btnSize = platform == DoseStepperPlatform.touch ? 48.0 : 48.0;
    final height = platform == DoseStepperPlatform.touch ? 48.0 : 48.0;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: MedColors.surface2,
        border: Border.all(color: MedColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _StepBtn(
            icon: PhosphorIcons.minus(),
            size: btnSize,
            enabled: _canDecrement,
            onTap: _canDecrement ? () => onChanged(value - step) : null,
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _handleManualEntry(context),
              behavior: HitTestBehavior.opaque,
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: MedColors.border),
                    right: BorderSide(color: MedColors.border),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 1,
                  children: [
                    Text(
                      value.formatFractional,
                      style: TextStyle(
                        fontFamily: MedFonts.title,
                        fontSize: platform == DoseStepperPlatform.touch ? 18 : 18,
                        fontWeight: FontWeight.w800,
                        color: MedColors.text,
                        height: 1,
                      ),
                    ),
                    Text(
                      unit,
                      style: TextStyle(fontFamily: MedFonts.mono, fontSize: 9, color: MedColors.text3),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _StepBtn(
            icon: PhosphorIcons.plus(),
            size: btnSize,
            enabled: _canIncrement,
            onTap: _canIncrement ? () => onChanged(value + step) : null,
          ),
        ],
      ),
    );
  }

  // ── COMPACT ────────────────────────────────────────────────────

  Widget _buildCompact(BuildContext context) {
    final btnSize = platform == DoseStepperPlatform.touch ? 36.0 : 36.0;

    return Container(
      decoration: BoxDecoration(
        color: MedColors.surface2,
        border: Border.all(color: MedColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepBtn(
            icon: PhosphorIcons.minus(),
            size: btnSize,
            enabled: _canDecrement,
            onTap: _canDecrement ? () => onChanged(value - step) : null,
            compact: true,
          ),
          GestureDetector(
            onTap: () => _handleManualEntry(context),
            behavior: HitTestBehavior.opaque,
            child: Container(
              constraints: const BoxConstraints(minWidth: 52),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: MedColors.border),
                  right: BorderSide(color: MedColors.border),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 1,
                children: [
                  Text(
                    value.formatFractional,
                    style: TextStyle(
                      fontFamily: MedFonts.title,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: MedColors.text,
                      height: 1.2,
                    ),
                  ),
                  Text(
                    unit,
                    style: TextStyle(fontFamily: MedFonts.mono, fontSize: 9, color: MedColors.text3),
                  ),
                ],
              ),
            ),
          ),
          _StepBtn(
            icon: PhosphorIcons.plus(),
            size: btnSize,
            enabled: _canIncrement,
            onTap: _canIncrement ? () => onChanged(value + step) : null,
            compact: true,
          ),
        ],
      ),
    );
  }
}

// ── Ortak step butonu ──────────────────────────────────────────────

class _StepBtn extends StatelessWidget {
  const _StepBtn({required this.icon, required this.size, required this.enabled, this.onTap, this.compact = false});

  final IconData icon;
  final double size;
  final bool enabled;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        child: Icon(icon, size: compact ? 14 : 18, color: enabled ? MedColors.text2 : MedColors.text4),
      ),
    );
  }
}
