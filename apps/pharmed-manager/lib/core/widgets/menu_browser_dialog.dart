import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class MenuBrowserDialog extends StatefulWidget {
  const MenuBrowserDialog({
    super.key,
    required this.title,
    required this.items,
    required this.onItemSelected,
    required this.selectedItems,
    required this.onCategoryToggled,
    required this.isCategoryFullySelected,
    required this.isCategoryPartiallySelected,
  });

  final String title;
  final List<MenuItem> items;
  final Function(MenuItem item) onItemSelected;
  final List<MenuItem> selectedItems;
  final Function(MenuItem category) onCategoryToggled;
  final bool Function(MenuItem category) isCategoryFullySelected;
  final bool Function(MenuItem category) isCategoryPartiallySelected;

  @override
  State<MenuBrowserDialog> createState() => _MenuBrowserDialogState();
}

class _MenuBrowserDialogState extends State<MenuBrowserDialog> {
  int _activeIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final parents = widget.items.where((m) => m.parentId == null).toList();
    final activeParent = parents.isNotEmpty ? parents[_activeIndex] : null;

    return SizedBox(
      height: 600,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 280,
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.3))),
            ),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: parents.length,
              itemBuilder: (context, index) {
                final category = parents[index];
                final isActive = index == _activeIndex;

                return _CategoryListItem(
                  category: category,
                  isActive: isActive,
                  isFullySelected: widget.isCategoryFullySelected(category),
                  isPartiallySelected: widget.isCategoryPartiallySelected(category),
                  onTap: () {
                    setState(() => _activeIndex = index);
                  },
                  onToggle: () => widget.onCategoryToggled(category),
                );
              },
            ),
          ),

          // --- SAĞ: ÜRÜN GRID ---
          Expanded(
            child: activeParent == null
                ? const Center(child: Text("Kategori seçimi yok"))
                : activeParent.children.isEmpty
                ? _buildEmptyState(theme)
                : GridView.builder(
                    padding: const EdgeInsets.all(24),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 220,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: activeParent.children.length,
                    itemBuilder: (context, index) {
                      final item = activeParent.children[index];
                      final isSelected = widget.selectedItems.any((i) => i.id == item.id);

                      return _MenuCard(item: item, isSelected: isSelected, onTap: () => widget.onItemSelected(item));
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            PhosphorIcons.package(PhosphorIconsStyle.duotone),
            size: 64,
            color: theme.colorScheme.outline.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            "Bu kategoride menü bulunamadı",
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _CategoryListItem extends StatelessWidget {
  final MenuItem category;
  final bool isActive;
  final bool isFullySelected;
  final bool isPartiallySelected;
  final VoidCallback onTap;
  final VoidCallback onToggle;

  const _CategoryListItem({
    required this.category,
    required this.isActive,
    required this.isFullySelected,
    required this.isPartiallySelected,
    required this.onTap,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    IconData checkboxIcon;
    Color checkboxColor;
    if (isFullySelected) {
      checkboxIcon = PhosphorIcons.checkSquare(PhosphorIconsStyle.fill);
      checkboxColor = colorScheme.primary;
    } else if (isPartiallySelected) {
      checkboxIcon = PhosphorIcons.minusSquare(PhosphorIconsStyle.fill);
      checkboxColor = colorScheme.tertiary; // Veya secondary
    } else {
      checkboxIcon = PhosphorIcons.square();
      checkboxColor = colorScheme.outline;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isActive ? colorScheme.primaryContainer.withValues(alpha: 0.3) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                // 1. Checkbox Butonu
                InkWell(
                  onTap: onToggle,
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Icon(checkboxIcon, color: checkboxColor, size: 22),
                  ),
                ),

                // 2. Metin
                Expanded(
                  child: Text(
                    category.label ?? '-',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      // Aktifse kalın ve renkli
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color: isActive ? colorScheme.primary : colorScheme.onSurface,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // 3. Ok İşareti (Sadece aktifse görünsün)
                if (isActive) Icon(PhosphorIcons.caretRight(), size: 16, color: colorScheme.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final MenuItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _MenuCard({required this.item, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Sabit border kalınlığı (Layout kaymasını önler)
    const double borderWidth = 2.0;

    // Border rengi: Seçiliyse Primary, değilse çok silik gri
    final borderColor = isSelected ? colorScheme.primary : colorScheme.outlineVariant.withValues(alpha: 0.25);

    // Kart arkaplan rengi: Seçiliyse çok hafif primary tint
    final cardBackgroundColor = isSelected ? colorScheme.primaryContainer.withValues(alpha: 0.08) : colorScheme.surface;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16), // Daha yuvarlak köşeler
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: cardBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: borderWidth),
          // Seçili değilse hafif bir derinlik gölgesi
          boxShadow: isSelected
              ? []
              : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Stack(
          alignment: Alignment.topLeft,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0), // Padding artırıldı
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 42,
                    width: 42,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.primary.withValues(alpha: 0.12)
                          : colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(
                        item.icon ?? PhosphorIcons.cube(PhosphorIconsStyle.duotone),
                        size: 18,
                        color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // İsim Alanı
                  Text(
                    item.label ?? 'İsimsiz',
                    textAlign: TextAlign.left,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                      height: 1.2,
                      fontSize: 15, // Font biraz büyütüldü
                    ),
                  ),
                ],
              ),
            ),

            // 2. SEÇİM İKONU (Sağ Üst Köşe)
            if (isSelected)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.5), blurRadius: 4)],
                  ),
                  child: const Icon(PhosphorIconsRegular.check, size: 14, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
