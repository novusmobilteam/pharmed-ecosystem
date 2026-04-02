import 'package:flutter/material.dart';

import '../core.dart';
import 'logout_button.dart';

class NavigationSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap; // Function(int) yerine ValueChanged daha standarttır
  final List<MenuItem> items;

  const NavigationSidebar({super.key, required this.selectedIndex, required this.onTap, required this.items});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Container(
      width: 270,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(color: colorScheme.surface, borderRadius: BorderRadius.circular(12.0)),
      child: Column(
        children: [
          // App Logo Bölümü
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Image.asset(AppImages.appLogo, height: 48, color: colorScheme.primary),
          ),
          const SizedBox(height: 32),

          // Menü Listesi
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                return _NavItemTile(item: items[index], isSelected: index == selectedIndex, onTap: () => onTap(index));
              },
            ),
          ),

          const LogoutButton(),
        ],
      ),
    );
  }
}

class _NavItemTile extends StatelessWidget {
  const _NavItemTile({required this.item, required this.isSelected, required this.onTap});

  final MenuItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    final foregroundColor = isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant;
    final backgroundColor = isSelected ? colorScheme.primary.withValues(alpha: 0.08) : Colors.transparent;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          hoverColor: colorScheme.primary.withValues(alpha: 0.04),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isSelected ? colorScheme.primary.withValues(alpha: 0.2) : Colors.transparent),
            ),
            child: Row(
              children: [
                Icon(item.icon, color: foregroundColor, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.label ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: foregroundColor,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
