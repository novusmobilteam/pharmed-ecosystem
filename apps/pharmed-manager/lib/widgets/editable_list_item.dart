import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class EditableListItem extends StatelessWidget {
  const EditableListItem({
    super.key,
    required this.title,
    this.subtitle,
    required this.onEdit,
    this.onDelete,
    this.additionalActions = const [],
    this.onTap,
    this.isSelected = false,
  });

  final String title;
  final String? subtitle;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;
  final List<Widget> additionalActions;
  final VoidCallback? onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isSelected ? MedColors.blueLight : MedColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isSelected ? MedColors.blue.withValues(alpha: 0.4) : MedColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                // ── Sol: metin
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: MedFonts.sans,
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? MedColors.blue : MedColors.text,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: const TextStyle(fontFamily: MedFonts.sans, fontSize: 11, color: MedColors.text3),
                        ),
                      ],
                    ],
                  ),
                ),

                // ── Sağ: aksiyonlar
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...additionalActions,
                    _ActionIcon(icon: PhosphorIcons.pencilSimple(), onPressed: onEdit, tooltip: 'Düzenle'),
                    if (onDelete != null)
                      _ActionIcon(
                        icon: PhosphorIcons.trash(),
                        onPressed: onDelete!,
                        tooltip: 'Sil',
                        color: MedColors.red.withValues(alpha: 0.7),
                        hoverColor: MedColors.redLight,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── _ActionIcon ──────────────────────────────────────────────────────────────

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({required this.icon, required this.onPressed, this.tooltip, this.color, this.hoverColor});

  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final Color? color;
  final Color? hoverColor;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon),
      onPressed: onPressed,
      iconSize: 15,
      tooltip: tooltip,
      color: color ?? MedColors.text3,
      hoverColor: hoverColor ?? MedColors.surface2,
      style: IconButton.styleFrom(padding: const EdgeInsets.all(6), visualDensity: VisualDensity.compact),
    );
  }
}

// ─── AdditionalActionButton ───────────────────────────────────────────────────

class AdditionalActionButton extends StatelessWidget {
  const AdditionalActionButton({super.key, required this.icon, required this.onPressed, this.tooltip, this.color});

  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return _ActionIcon(icon: icon, onPressed: onPressed, tooltip: tooltip, color: color);
  }
}
