// packages/pharmed_ui/lib/src/list/editable_list_item.dart
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../cards/med_selectable_card.dart';
import '../buttons/med_rectangle_icon_button.dart';
import '../../theme/med_tokens.dart'; // MedColors/MedFonts — gerçek yola göre ayarla

class MedEditableListCard extends StatelessWidget {
  const MedEditableListCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.onEdit,
    this.editTooltip,
    this.onDelete,
    this.deleteTooltip,
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

  /// Widget pharmed_ui'de saf kalsın diye tooltip'ler çağıran taraftan
  /// (manager l10n) parametre olarak geliyor.
  final String? editTooltip;
  final String? deleteTooltip;

  @override
  Widget build(BuildContext context) {
    return MedSelectableCard(
      isSelected: isSelected,
      onTap: onTap,
      child: Row(
        children: [
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
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...additionalActions,
              MedRectangleIconButton(
                iconData: PhosphorIcons.pencilSimple(),
                onPressed: onEdit,
                tooltip: editTooltip,
                size: 28,
                iconSize: 14,
              ),
              if (onDelete != null)
                MedRectangleIconButton(
                  iconData: PhosphorIcons.trash(),
                  onPressed: onDelete,
                  tooltip: deleteTooltip,
                  size: 28,
                  iconSize: 14,
                  iconColor: MedColors.red.withValues(alpha: 0.7),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── AdditionalActionButton ────────────────────────────────────────────────
// _ActionIcon kalktı, artık doğrudan MedRectangleIconButton'a delege ediyor.
class AdditionalActionButton extends StatelessWidget {
  const AdditionalActionButton({super.key, required this.icon, required this.onPressed, this.tooltip, this.color});

  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return MedRectangleIconButton(
      iconData: icon,
      onPressed: onPressed,
      tooltip: tooltip,
      iconColor: color,
      size: 28,
      iconSize: 14,
    );
  }
}
