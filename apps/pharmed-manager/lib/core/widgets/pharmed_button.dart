import 'package:flutter/material.dart';

import '../core.dart';

class PharmedButton extends StatelessWidget {
  const PharmedButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.backgroundColor,
    this.foregroundColor,
    this.isActive = true,
    this.height,
    this.isLoading = false,
  });

  final VoidCallback? onPressed;
  final String label;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool isActive;
  final double? height;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 35,
      child: ElevatedButton(
        style: ButtonStyle(
          foregroundColor: WidgetStatePropertyAll(foregroundColor ?? context.colorScheme.onPrimary),
          backgroundColor: !isActive
              ? WidgetStatePropertyAll(Colors.grey)
              : WidgetStatePropertyAll(backgroundColor ?? context.colorScheme.primary),
          shape: WidgetStatePropertyAll<OutlinedBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0)), side: BorderSide.none),
          ),
        ),
        onPressed: onPressed,
        child: isLoading
            ? Center(
                child: CircularProgressIndicator.adaptive(
                  backgroundColor: foregroundColor ?? context.colorScheme.onPrimary,
                ),
              )
            : Text(
                label,
                style: context.textTheme.bodySmall?.copyWith(
                  color: foregroundColor ?? context.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
