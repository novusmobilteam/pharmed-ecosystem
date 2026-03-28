import 'package:flutter/material.dart';
import '../atoms/med_tokens.dart';

// ─────────────────────────────────────────────────────────────────
// MedNumericStepper
// [SWREQ-UI-MOL-STP-001]
// Sayısal stepper — 48×48px dokunma hedefi olan +/− butonlar.
// Sınıf : Class A (görsel sayısal giriş)
// ─────────────────────────────────────────────────────────────────

class MedNumericStepper extends StatelessWidget {
  const MedNumericStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 99,
    this.step = 1,
    this.label,
    this.helperText,
    this.suffix,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;
  final int step;
  final String? label;
  final String? helperText;
  final String? suffix;

  void _decrement() {
    final next = value - step;
    if (next >= min) onChanged(next);
  }

  void _increment() {
    final next = value + step;
    if (next <= max) onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final canDec = value > min;
    final canInc = value < max;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(
              fontFamily: MedFonts.sans,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: MedColors.text2,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 6),
        ],
        Container(
          decoration: BoxDecoration(
            color: MedColors.surface2,
            border: Border.all(color: MedColors.border, width: 1.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IntrinsicHeight(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _StepButton(
                  icon: Icons.remove,
                  enabled: canDec,
                  onTap: canDec ? _decrement : null,
                  isLeft: true,
                ),
                Container(
                  width: 1,
                  color: MedColors.border2,
                ),
                Container(
                  constraints: const BoxConstraints(minWidth: 60),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  alignment: Alignment.center,
                  child: Text(
                    suffix != null ? '$value$suffix' : '$value',
                    style: TextStyle(
                      fontFamily: MedFonts.mono,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: MedColors.text,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  width: 1,
                  color: MedColors.border2,
                ),
                _StepButton(
                  icon: Icons.add,
                  enabled: canInc,
                  onTap: canInc ? _increment : null,
                  isLeft: false,
                ),
              ],
            ),
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: 4),
          Text(
            helperText!,
            style: const TextStyle(
              fontFamily: MedFonts.sans,
              fontSize: 11,
              color: MedColors.text3,
            ),
          ),
        ],
      ],
    );
  }
}

class _StepButton extends StatefulWidget {
  const _StepButton({
    required this.icon,
    required this.enabled,
    required this.isLeft,
    this.onTap,
  });
  final IconData icon;
  final bool enabled;
  final bool isLeft;
  final VoidCallback? onTap;

  @override
  State<_StepButton> createState() => _StepButtonState();
}

class _StepButtonState extends State<_StepButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: widget.enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: widget.enabled ? (_) => setState(() => _pressed = false) : null,
      onTapCancel:
          widget.enabled ? () => setState(() => _pressed = false) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: _pressed ? MedColors.blue : Colors.transparent,
          borderRadius: BorderRadius.only(
            topLeft: widget.isLeft ? const Radius.circular(7) : Radius.zero,
            bottomLeft:
                widget.isLeft ? const Radius.circular(7) : Radius.zero,
            topRight: !widget.isLeft ? const Radius.circular(7) : Radius.zero,
            bottomRight:
                !widget.isLeft ? const Radius.circular(7) : Radius.zero,
          ),
        ),
        child: Icon(
          widget.icon,
          size: 20,
          color: !widget.enabled
              ? MedColors.text4
              : _pressed
                  ? Colors.white
                  : MedColors.text2,
        ),
      ),
    );
  }
}
