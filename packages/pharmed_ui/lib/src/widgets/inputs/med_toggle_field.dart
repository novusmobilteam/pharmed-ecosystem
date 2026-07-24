import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

/// Açma/kapama anahtarı + kalın etiket satırı.
///
/// [MedToggle] ile aynı API'yi sunar ancak yanına etiket ekler.
///
/// ```dart
/// ToggleField(
///   value: _isActive,
///   label: 'Aktif',
///   onChanged: (v) => setState(() => _isActive = v),
/// )
/// ```
class MedToggleField extends StatelessWidget {
  const MedToggleField({
    super.key,
    required this.value,
    this.onChanged,
    required this.label,
    this.enabled = true,
    this.textStyle,
    this.showBorder = false,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String label;
  final bool enabled;
  final TextStyle? textStyle;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    if (showBorder) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: MedSpacing.insetXl.left, vertical: MedSpacing.insetMd.bottom),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: value ? MedColors.blue : MedColors.border, width: 1),
          borderRadius: MedRadius.mdAll,
          //boxShadow: MedShadows.md,
        ),
        child: _toggleBody(),
      );
    } else {
      return _toggleBody();
    }
  }

  Widget _toggleBody() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      spacing: MedSpacing.md,
      children: [
        Text(label, style: textStyle ?? MedTextStyles.bodySm(weight: FontWeight.w700)),
        MedToggle(value: value, onChanged: onChanged, enabled: enabled),
      ],
    );
  }
}

class MedToggle extends StatelessWidget {
  const MedToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.enabled = true,
    this.textStyle,
    this.color,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;
  final bool enabled;
  final TextStyle? textStyle;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled && onChanged != null ? () => onChanged!(!value) : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.4,
        child: Container(
          //onstraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _TrackWidget(value: value, color: color),
              if (label != null) ...[
                const SizedBox(width: 12),
                Text(label!, style: textStyle ?? MedTextStyles.bodyMd()),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TrackWidget extends StatelessWidget {
  const _TrackWidget({required this.value, this.color});

  final bool value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 50,
      height: 24,
      decoration: BoxDecoration(
        color: value ? color ?? MedColors.blue : MedColors.border,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          curve: Curves.elasticOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Color(0x331A2332), blurRadius: 4, offset: Offset(0, 1))],
            ),
          ),
        ),
      ),
    );
  }
}
