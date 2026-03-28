import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class EditableListItem extends StatelessWidget {
  const EditableListItem({
    super.key,
    required this.title,
    this.subtitle,
    required this.onEdit,
    this.onDelete,
    this.additionalActions = const [],
    this.maxTrailingWidth = 140,
    this.onTap,
    this.isSelected = false,
  });

  final String title;
  final String? subtitle;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;
  final List<Widget> additionalActions;
  final double maxTrailingWidth;
  final VoidCallback? onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Seçili ise primaryContainer, değilse surface (veya şeffaf)
    final backgroundColor = isSelected ? colorScheme.primaryContainer.withValues(alpha: 0.3) : colorScheme.surface;

    final borderColor =
        isSelected ? colorScheme.primary.withValues(alpha: 0.5) : colorScheme.outlineVariant.withValues(alpha: 0.5);

    return Container(
      margin: const EdgeInsets.only(bottom: 8.0), // Öğeler arası boşluk
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: borderColor, width: 1.0),
        // Hafif gölge (seçili değilken)
        boxShadow: isSelected
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                // --- Sol Taraf: Yazılar ---
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // --- Sağ Taraf: Aksiyonlar ---
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Ekstra Aksiyonlar
                    ...additionalActions,

                    // Düzenle Butonu
                    IconButton(
                      icon: Icon(PhosphorIcons.pencilSimple()), // Daha sade kalem ikonu
                      onPressed: onEdit,
                      iconSize: 20,
                      color: colorScheme.onSurfaceVariant,
                      tooltip: 'Düzenle',
                      style: IconButton.styleFrom(
                        padding: const EdgeInsets.all(8),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),

                    // Sil Butonu
                    if (onDelete != null)
                      IconButton(
                        icon: Icon(PhosphorIcons.trash()),
                        onPressed: onDelete,
                        iconSize: 20,
                        // Tema error rengi
                        color: colorScheme.error,
                        tooltip: 'Sil',
                        style: IconButton.styleFrom(
                          padding: const EdgeInsets.all(8),
                          visualDensity: VisualDensity.compact,
                          hoverColor: colorScheme.errorContainer.withValues(alpha: 0.2),
                        ),
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

// Yardımcı widget: Additional action için standart ikon butonu
class AdditionalActionButton extends StatelessWidget {
  const AdditionalActionButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.color,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return IconButton(
      icon: Icon(icon),
      onPressed: onPressed,
      iconSize: 20,
      padding: const EdgeInsets.all(8),
      visualDensity: VisualDensity.compact, // Daha sıkı yerleşim
      tooltip: tooltip,
      color: color ?? colorScheme.onSurfaceVariant, // Varsayılan gri
    );
  }
}
