import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../core.dart';

/// Hasta İlaç İşlemleri ve Stok İşlemleri ekranlarında kullanılan
/// grid menü.
class SubGridMenuView extends StatelessWidget {
  const SubGridMenuView({super.key, required this.items});

  final List<MenuItem> items;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 2,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return GestureDetector(
          onTap: () {
            // if (item.builder != null) {
            //   showDialog(context: context, builder: (context) => item.builder!(context));
            // }
          },
          child: Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: context.colorScheme.surfaceContainerLow.withAlpha(80),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.colorScheme.primary.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: context.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item.icon, color: context.colorScheme.onPrimaryContainer, size: 20),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.label ?? '',
                      style: context.theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 2,
                    ),
                    Icon(PhosphorIcons.caretRight(), size: 16),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
