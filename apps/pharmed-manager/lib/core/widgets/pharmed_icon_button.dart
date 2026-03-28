import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class PharmedIconButton extends StatefulWidget {
  const PharmedIconButton({
    super.key,
    this.onPressed,
    this.icon,
    required this.label,
  });

  final VoidCallback? onPressed;
  final String label;
  final IconData? icon;

  @override
  State<PharmedIconButton> createState() => _PharmedIconButtonState();
}

class _PharmedIconButtonState extends State<PharmedIconButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final colorScheme = Theme.of(context).colorScheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 130),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: enabled
                ? (_hovered ? colorScheme.primary.withValues(alpha: 0.88) : colorScheme.primary)
                : colorScheme.onSurface.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            boxShadow: enabled && _hovered
                ? [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon ?? PhosphorIcons.plus(),
                size: 15,
                color: enabled ? Colors.white : colorScheme.onSurface.withValues(alpha: 0.35),
              ),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: enabled ? Colors.white : colorScheme.onSurface.withValues(alpha: 0.35),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
