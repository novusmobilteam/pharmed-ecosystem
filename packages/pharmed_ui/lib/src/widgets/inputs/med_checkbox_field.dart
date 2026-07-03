import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

/// Checkbox boyut varyantları — butonlarla aynı dil (sm/md/lg).
enum MedCheckboxSize {
  sm, // 16px kutu — yoğun listelerde, satır içi seçim
  md, // 22px kutu — varsayılan, form alanları
  lg, // 26px kutu — birincil onay, dokunmatik öncelikli
}

class _CheckboxSpec {
  const _CheckboxSpec({
    required this.box,
    required this.icon,
    required this.border,
    required this.minHeight,
    required this.radius,
    required this.gap,
    required this.labelStyle,
  });

  final double box;
  final double icon;
  final double border;
  final double minHeight;
  final BorderRadius radius;
  final double gap;
  final TextStyle labelStyle;

  static _CheckboxSpec of(MedCheckboxSize size) {
    switch (size) {
      case MedCheckboxSize.sm:
        return _CheckboxSpec(
          box: 16,
          icon: 10,
          border: 1.5,
          minHeight: 32,
          radius: BorderRadius.circular(4),
          gap: 8,
          labelStyle: MedTextStyles.bodySm(color: MedColors.text),
        );
      case MedCheckboxSize.md:
        return _CheckboxSpec(
          box: 22,
          icon: 12,
          border: 2,
          minHeight: 44,
          radius: BorderRadius.circular(6),
          gap: 10,
          labelStyle: MedTextStyles.bodyMd(color: MedColors.text),
        );
      case MedCheckboxSize.lg:
        return _CheckboxSpec(
          box: 26,
          icon: 16,
          border: 2,
          minHeight: 52,
          radius: BorderRadius.circular(7),
          gap: 12,
          labelStyle: MedTextStyles.bodyMd(color: MedColors.text, weight: FontWeight.w500),
        );
    }
  }
}

// ─────────────────────────────────────────────────────────────────
// MedCheckbox
// [SWREQ-UI-ATOM-CHK-001]
// Özel checkbox — sm/md/lg varyantlar, partial destek, parametrik renk.
// Sınıf : Class A (görsel seçim)
// ─────────────────────────────────────────────────────────────────

/// Özel onay kutusu — sm/md/lg boyut, partial destek, opsiyonel renk.
///
/// ```dart
/// MedCheckbox(value: isChecked, onChanged: (v) => ...);
/// MedCheckbox(value: isChecked, size: MedCheckboxSize.sm, onChanged: ...);
/// MedCheckbox(value: true, partial: true, onChanged: ...); // kısmi seçim
/// MedCheckbox(value: true, activeColor: MedColors.green, onChanged: ...); // özel renk
/// ```
class MedCheckbox extends StatelessWidget {
  const MedCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.enabled = true,
    this.partial = false,
    this.size = MedCheckboxSize.md,
    this.activeColor,
    this.checkColor,
    this.borderColor,
    this.inactiveColor,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;
  final bool enabled;
  final bool partial;
  final MedCheckboxSize size;

  /// Seçili durumdaki dolgu ve kenarlık rengi. Verilmezse `MedColors.blue`.
  final Color? activeColor;

  /// Tik/tire ikon rengi. Verilmezse beyaz.
  final Color? checkColor;

  /// Seçili değilken kenarlık rengi. Verilmezse `MedColors.border`.
  final Color? borderColor;

  /// Seçili değilken dolgu rengi. Verilmezse `MedColors.surface2`.
  final Color? inactiveColor;

  @override
  Widget build(BuildContext context) {
    final spec = _CheckboxSpec.of(size);

    return GestureDetector(
      onTap: enabled && onChanged != null ? () => onChanged!(!value) : null,
      behavior: HitTestBehavior.opaque,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.4,
        child: Container(
          constraints: BoxConstraints(minHeight: spec.minHeight),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _CheckBox(
                value: value,
                partial: partial,
                spec: spec,
                activeColor: activeColor ?? MedColors.blue,
                checkColor: checkColor ?? Colors.white,
                borderColor: borderColor ?? MedColors.border,
                inactiveColor: inactiveColor ?? MedColors.surface2,
              ),
              if (label != null) ...[SizedBox(width: spec.gap), Flexible(child: Text(label!, style: spec.labelStyle))],
            ],
          ),
        ),
      ),
    );
  }
}

class MedCheckboxField extends StatelessWidget {
  const MedCheckboxField({
    super.key,
    required this.value,
    this.onChanged,
    required this.label,
    this.enabled = true,
    this.size = MedCheckboxSize.md,
    this.activeColor,
    this.checkColor,
    this.borderColor,
    this.inactiveColor,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String label;
  final bool enabled;
  final MedCheckboxSize size;
  final Color? activeColor;
  final Color? checkColor;
  final Color? borderColor;
  final Color? inactiveColor;

  @override
  Widget build(BuildContext context) {
    final spec = _CheckboxSpec.of(size);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled && onChanged != null ? () => onChanged!(!value) : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          MedCheckbox(
            value: value,
            onChanged: onChanged,
            enabled: enabled,
            size: size,
            activeColor: activeColor,
            checkColor: checkColor,
            borderColor: borderColor,
            inactiveColor: inactiveColor,
          ),
          SizedBox(width: spec.gap - MedSpacing.xs),
          Text(label, style: spec.labelStyle),
        ],
      ),
    );
  }
}

class _CheckBox extends StatelessWidget {
  const _CheckBox({
    required this.value,
    required this.partial,
    required this.spec,
    required this.activeColor,
    required this.checkColor,
    required this.borderColor,
    required this.inactiveColor,
  });

  final bool value;
  final bool partial;
  final _CheckboxSpec spec;
  final Color activeColor;
  final Color checkColor;
  final Color borderColor;
  final Color inactiveColor;

  @override
  Widget build(BuildContext context) {
    final isOn = value || partial;
    return AnimatedContainer(
      alignment: Alignment.center,
      duration: const Duration(milliseconds: 150),
      width: spec.box,
      height: spec.box,
      decoration: BoxDecoration(
        color: isOn ? activeColor : inactiveColor,
        border: Border.all(color: isOn ? activeColor : borderColor, width: spec.border),
        borderRadius: spec.radius,
      ),
      child: AnimatedOpacity(
        opacity: isOn ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 100),
        child: isOn
            ? Icon(partial ? Icons.remove_rounded : Icons.check_rounded, size: spec.icon, color: checkColor)
            : null,
      ),
    );
  }
}
