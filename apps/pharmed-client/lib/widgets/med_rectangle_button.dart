import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

class MedRectangleButton extends StatelessWidget {
  const MedRectangleButton({
    super.key,
    this.onTap,
    this.width,
    this.height,
    required this.label,
    this.foregroundColor,
    this.backgroundColor,
    this.suffixIcon,
    this.isLoading = false,
    this.isActive = true,
    this.showBorder = false,
    this.textStyle,
  });

  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final String label;
  final Color? foregroundColor;
  final Color? backgroundColor;
  final IconData? suffixIcon;
  final bool isLoading;
  final bool isActive;
  final bool showBorder;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = backgroundColor ?? MedColors.blue;
    final bgColor = isActive ? effectiveColor : effectiveColor.withAlpha(44);

    return GestureDetector(
      onTap: isActive ? onTap : null,
      child: Container(
        width: width,
        height: height ?? 60,
        padding: EdgeInsets.symmetric(horizontal: MedSpacing.insetXl.left),
        decoration: BoxDecoration(
          color: bgColor,
          border: showBorder ? Border.all(color: foregroundColor ?? Colors.black, width: 1.5) : null,
        ),
        child: Builder(
          builder: (context) {
            if (suffixIcon != null) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: textStyle ?? MedTextStyles.titleMd(color: foregroundColor ?? Colors.white),
                    ),
                  ),
                  Builder(
                    builder: (context) {
                      if (isLoading) {
                        return MedLoadingIndicator(color: foregroundColor);
                      } else {
                        return suffixIcon != null ? Icon(suffixIcon, color: foregroundColor) : SizedBox.shrink();
                      }
                    },
                  ),
                ],
              );
            } else {
              return Center(
                child: Text(label, style: textStyle ?? MedTextStyles.titleMd(color: foregroundColor ?? Colors.white)),
              );
            }
          },
        ),
      ),
    );
  }
}
