import 'package:flutter/material.dart';

class RectangleIconButton extends StatelessWidget {
  const RectangleIconButton({
    super.key,
    required this.iconData,
    this.color,
    this.iconColor,
    this.onPressed,
    this.tooltip,
    this.size = 40.0, // Standart boyut eklendi
    this.iconSize = 20.0,
  });

  final IconData iconData;
  final Color? color;
  final Color? iconColor;
  final VoidCallback? onPressed;
  final String? tooltip;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Arka plan rengi: Dışarıdan gelmezse hafif gri tonu (Tonal Style)
    final backgroundColor =
        color ?? colorScheme.surfaceContainerHighest.withValues(alpha: 0.5);

    // İkon rengi: Dışarıdan gelmezse koyu gri
    final effectiveIconColor = iconColor ?? colorScheme.onSurfaceVariant;

    return SizedBox(
      width: size,
      height: size,
      child: Tooltip(
        message: tooltip ?? '',
        child: Material(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8.0), // Köşe yuvarlaklığı
          clipBehavior: Clip.antiAlias, // Ripple taşmasın diye
          child: InkWell(
            onTap: onPressed,
            splashColor: colorScheme.primary.withValues(alpha: 0.1),
            highlightColor: colorScheme.primary.withValues(alpha: 0.05),
            child: Center(
              child: Icon(
                iconData,
                color: onPressed != null
                    ? effectiveIconColor
                    : effectiveIconColor.withValues(
                        alpha: 0.5), // Disabled durumu
                size: iconSize,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
