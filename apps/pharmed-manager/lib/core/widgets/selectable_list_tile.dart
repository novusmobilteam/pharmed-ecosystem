import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../core.dart'; // Selectable mixin'i için

class SelectableListTile<T extends Selectable> extends StatelessWidget {
  const SelectableListTile({
    super.key,
    required this.item,
    this.onDoubleTap,
    required this.onTap,
    required this.isSelected,
  });

  final T item;
  final Function(T item, BuildContext context)? onDoubleTap;
  final Function(T item) onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(2.0),
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.0),
          onTap: () => onTap(item),
          onDoubleTap: onDoubleTap != null ? () => onDoubleTap!(item, context) : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // --- Yazı Alanı ---
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                        ),
                      ),
                      if (item.subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          item.subtitle!,
                          style: theme.textTheme.bodySmall?.copyWith(
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

                const SizedBox(width: 12),

                // --- Seçim İkonu / Kutusu ---
                _buildSelectionIndicator(colorScheme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionIndicator(ColorScheme colorScheme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: isSelected ? colorScheme.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
        ),
      ),
      child: isSelected
          ? Icon(
              PhosphorIcons.check(),
              size: 12,
              color: colorScheme.onPrimary,
            )
          : null,
    );
  }
}
