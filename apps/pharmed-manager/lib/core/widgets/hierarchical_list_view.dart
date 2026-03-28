import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../core.dart';

class HierarchicalListView<T extends GroupItem<U>, U> extends StatelessWidget {
  final List<T> groups;
  final String Function(T group) groupTitleBuilder;
  final String Function(U item) itemTitleBuilder;
  final void Function(T group, int groupIndex)? onGroupTap;
  final void Function(U item, int groupIndex, int itemIndex)? onItemTap;
  final int? selectedGroupIndex;
  final int? selectedItemIndex;
  final bool expandAllGroups;
  final String? title;

  const HierarchicalListView({
    super.key,
    required this.groups,
    required this.groupTitleBuilder,
    required this.itemTitleBuilder,
    this.onGroupTap,
    this.onItemTap,
    this.selectedGroupIndex,
    this.selectedItemIndex,
    this.expandAllGroups = false,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5), width: 1.0),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                title!,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: colorScheme.onSurface),
              ),
            ),
            const SizedBox(height: 12),
            Divider(color: colorScheme.outlineVariant.withValues(alpha: 0.5), height: 1),
            const SizedBox(height: 12),
          ],
          Expanded(
            child: ListView.separated(
              itemCount: groups.length,
              separatorBuilder: (context, index) => const SizedBox(height: 4),
              itemBuilder: (context, groupIndex) {
                final group = groups[groupIndex];
                final isGroupSelected = selectedGroupIndex == groupIndex;
                final shouldExpand = expandAllGroups || isGroupSelected;

                return _GroupSection(
                  group: group,
                  groupIndex: groupIndex,
                  groupTitleBuilder: groupTitleBuilder,
                  itemTitleBuilder: itemTitleBuilder,
                  onGroupTap: onGroupTap,
                  onItemTap: onItemTap,
                  isExpanded: shouldExpand,
                  isGroupSelected: isGroupSelected,
                  selectedItemIndex: selectedItemIndex,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupSection<T extends GroupItem<U>, U> extends StatelessWidget {
  final T group;
  final int groupIndex;
  final String Function(T group) groupTitleBuilder;
  final String Function(U item) itemTitleBuilder;
  final void Function(T group, int groupIndex)? onGroupTap;
  final void Function(U item, int groupIndex, int itemIndex)? onItemTap;
  final bool isExpanded;
  final bool isGroupSelected;
  final int? selectedItemIndex;

  const _GroupSection({
    required this.group,
    required this.groupIndex,
    required this.groupTitleBuilder,
    required this.itemTitleBuilder,
    this.onGroupTap,
    this.onItemTap,
    required this.isExpanded,
    required this.isGroupSelected,
    this.selectedItemIndex,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Grup başlığı için çok hafif bir zemin (isteğe bağlı, side list'te grup olmadığı için burada farklı olabilir)
    // Ama tutarlılık için çok silik bir primaryContainer kullanabiliriz.
    final backgroundColor = isGroupSelected ? colorScheme.primaryContainer.withValues(alpha: 0.2) : Colors.transparent;

    return Theme(
      data: theme.copyWith(dividerColor: Colors.transparent),
      child: Container(
        decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(8.0)),
        child: ExpansionTile(
          key: PageStorageKey('group_$groupIndex'),
          initiallyExpanded: isExpanded,
          shape: const Border(),
          collapsedShape: const Border(),
          tilePadding: const EdgeInsets.symmetric(horizontal: 12.0),
          childrenPadding: const EdgeInsets.only(bottom: 8.0),
          // Grup başlığı renkleri
          iconColor: colorScheme.primary,
          collapsedIconColor: colorScheme.onSurfaceVariant,

          title: Text(
            groupTitleBuilder(group),
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              // Grup başlığı rengi
              color: isGroupSelected ? colorScheme.primary : colorScheme.onSurface,
            ),
          ),

          onExpansionChanged: (expanded) {
            if (expanded && onGroupTap != null) {
              onGroupTap!(group, groupIndex);
            }
          },

          children: group.items.asMap().entries.map((entry) {
            final itemIndex = entry.key;
            final item = entry.value;
            final isItemSelected = isGroupSelected && selectedItemIndex == itemIndex;

            return _buildSubItem(context, item, itemIndex, isItemSelected, colorScheme);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSubItem(BuildContext context, U item, int itemIndex, bool isSelected, ColorScheme colorScheme) {
    // --- GÖRSEL AYARLAR (SideList ile Eşleşme) ---

    // Zemin Rengi: PrimaryContainer (Daha yumuşak)
    final backgroundColor = isSelected ? colorScheme.primaryContainer : Colors.transparent;

    // Yazı ve İkon Rengi: OnPrimaryContainer (Koyu ton)
    final contentColor = isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant;

    final fontWeight = isSelected ? FontWeight.w600 : FontWeight.normal;

    return Padding(
      // Margin sorununu çözmek için Padding'i dışarı aldık
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onItemTap?.call(item, groupIndex, itemIndex),
          borderRadius: BorderRadius.circular(8.0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8.0),
              // Seçiliyse hafif bir border da ekleyebiliriz (SideList'teki gibi)
              border: isSelected ? Border.all(color: colorScheme.primary.withValues(alpha: 0.1)) : null,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    itemTitleBuilder(item),
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: contentColor, fontWeight: fontWeight),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isSelected)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Icon(PhosphorIcons.caretRight(), size: 16, color: contentColor),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
