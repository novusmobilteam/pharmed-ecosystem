import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class PharmedSideListView<T> extends StatelessWidget {
  const PharmedSideListView({
    super.key,
    required this.items,
    required this.activeIndex,
    required this.onTap,
    required this.labelBuilder,
    this.itemBuilder,
    this.isLoading = false,
    this.title,
  });

  final List<T> items;
  final int activeIndex;
  final Function(T data) onTap;
  final String? Function(T item) labelBuilder;
  final Widget Function(T item, int index, bool isActive)? itemBuilder;
  final bool isLoading;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      // İçerik kenarlara yapışmasın diye padding
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: colorScheme.surface, // Zemin rengi
        borderRadius: BorderRadius.circular(16.0), // Standart Radius
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1.0,
        ),
        // Hafif gölge
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --- Başlık Alanı ---
          if (title != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                title!,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Divider(
              height: 1,
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
          ],

          // --- Liste Alanı ---
          Expanded(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.primary,
                    ),
                  )
                : ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 4),
                    itemBuilder: (BuildContext context, int index) {
                      final item = items[index];
                      final isActive = activeIndex == index;

                      // Eğer özel builder varsa onu kullan, yoksa default
                      return itemBuilder?.call(item, index, isActive) ?? _buildDefaultItem(context, item, isActive);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultItem(BuildContext context, T item, bool isActive) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Aktifse renkli, pasifse şeffaf
    final backgroundColor = isActive
        ? colorScheme.primaryContainer // Vurgulu zemin
        : Colors.transparent;

    final textColor = isActive
        ? colorScheme.onPrimaryContainer // Vurgulu yazı
        : colorScheme.onSurfaceVariant; // Normal yazı

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTap(item),
        borderRadius: BorderRadius.circular(8.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8.0),
            // Sadece aktif olanda hafif border olsun mu? Opsiyonel.
            border: isActive
                ? Border.all(color: colorScheme.primary.withValues(alpha: 0.1))
                : Border.all(color: Colors.transparent),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  labelBuilder(item) ?? "-",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: textColor,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Seçili öğeyi belirtmek için sol tarafa ikon veya bar
              if (isActive)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Icon(
                    PhosphorIcons.caretRight(), // Veya checkCircle
                    size: 16,
                    color: textColor,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
