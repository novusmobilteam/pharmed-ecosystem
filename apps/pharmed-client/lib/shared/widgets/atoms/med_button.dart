import 'package:flutter/material.dart';
import 'med_tokens.dart';

// ─────────────────────────────────────────────────────────────────
// MedButton
// [SWREQ-UI-ATOM-BTN-001]
// Dokunmatik HMI için standart buton bileşeni.
// Min 48px yükseklik (HIG touch target), min 44px sm boyut.
// Sınıf : Class A (görsel eylem, iş kararı notifier'da)
// ─────────────────────────────────────────────────────────────────

enum MedButtonVariant { primary, secondary, ghost, danger, success }

enum MedButtonSize { sm, md, lg }

class MedButton extends StatefulWidget {
  const MedButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = MedButtonVariant.primary,
    this.size = MedButtonSize.md,
    this.prefixIcon,
    this.fullWidth = false,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final MedButtonVariant variant;
  final MedButtonSize size;
  final Widget? prefixIcon;
  final bool fullWidth;
  final bool isLoading;

  @override
  State<MedButton> createState() => _MedButtonState();
}

class _MedButtonState extends State<MedButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null && !widget.isLoading;
    final colors = _resolveColors(widget.variant);
    final sizing = _resolveSizing(widget.size);

    return AnimatedOpacity(
      opacity: isDisabled ? 0.4 : 1.0,
      duration: const Duration(milliseconds: 150),
      child: GestureDetector(
        onTapDown: isDisabled ? null : (_) => setState(() => _pressed = true),
        onTapUp: isDisabled ? null : (_) => setState(() => _pressed = false),
        onTapCancel: isDisabled ? null : () => setState(() => _pressed = false),
        onTap: isDisabled ? null : widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: widget.fullWidth ? double.infinity : null,
          constraints: BoxConstraints(minHeight: sizing.minHeight),
          padding: sizing.padding,
          transform: _pressed
              ? (Matrix4.identity()..translate(0.0, 1.0))
              : Matrix4.identity(),
          decoration: BoxDecoration(
            color: colors.background,
            border: colors.borderColor != null
                ? Border.all(color: colors.borderColor!, width: 1.5)
                : null,
            borderRadius: BorderRadius.circular(sizing.radius),
            boxShadow: _pressed ? null : colors.shadow,
          ),
          child: Row(
            mainAxisSize:
                widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.isLoading) ...[
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(colors.foreground),
                  ),
                ),
                const SizedBox(width: 8),
              ] else if (widget.prefixIcon != null) ...[
                IconTheme(
                  data: IconThemeData(color: colors.foreground, size: 16),
                  child: widget.prefixIcon!,
                ),
                const SizedBox(width: 8),
              ],
              Text(widget.label, style: sizing.textStyle(colors.foreground)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Renk çözümleyici ──────────────────────────────────────────────

final class _ButtonColors {
  const _ButtonColors({
    required this.background,
    required this.foreground,
    this.borderColor,
    this.shadow,
  });
  final Color background;
  final Color foreground;
  final Color? borderColor;
  final List<BoxShadow>? shadow;
}

_ButtonColors _resolveColors(MedButtonVariant v) {
  return switch (v) {
    MedButtonVariant.primary => _ButtonColors(
        background: MedColors.blue,
        foreground: Colors.white,
        shadow: const [
          BoxShadow(
              color: Color(0x4D1A6FD8), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
    MedButtonVariant.secondary => _ButtonColors(
        background: Colors.transparent,
        foreground: MedColors.blue,
        borderColor: MedColors.blue,
      ),
    MedButtonVariant.ghost => _ButtonColors(
        background: MedColors.surface2,
        foreground: MedColors.text2,
        borderColor: MedColors.border,
      ),
    MedButtonVariant.danger => _ButtonColors(
        background: MedColors.red,
        foreground: Colors.white,
        shadow: const [
          BoxShadow(
              color: Color(0x4DDC2626), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
    MedButtonVariant.success => _ButtonColors(
        background: MedColors.green,
        foreground: Colors.white,
        shadow: const [
          BoxShadow(
              color: Color(0x4D0D9E6C), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
  };
}

// ── Boyut çözümleyici ─────────────────────────────────────────────

final class _ButtonSizing {
  const _ButtonSizing({
    required this.padding,
    required this.minHeight,
    required this.fontSize,
    required this.radius,
  });
  final EdgeInsets padding;
  final double minHeight;
  final double fontSize;
  final double radius;

  TextStyle textStyle(Color color) => TextStyle(
        fontFamily: MedFonts.sans,
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1,
      );
}

_ButtonSizing _resolveSizing(MedButtonSize s) {
  return switch (s) {
    MedButtonSize.sm => const _ButtonSizing(
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        minHeight: 36,
        fontSize: 12,
        radius: 8,
      ),
    MedButtonSize.md => const _ButtonSizing(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        minHeight: 48,
        fontSize: 14,
        radius: 8,
      ),
    MedButtonSize.lg => const _ButtonSizing(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        minHeight: 54,
        fontSize: 15,
        radius: 10,
      ),
  };
}
