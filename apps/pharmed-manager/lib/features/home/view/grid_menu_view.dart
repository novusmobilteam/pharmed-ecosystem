import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pharmed_manager/core/core.dart';

import 'menu_card.dart';

class GridMenuView extends StatelessWidget {
  final List<MenuItem> items;
  final String? title;
  final int crossAxisCount;
  final double childAspectRatio;

  const GridMenuView({super.key, required this.items, this.title, this.crossAxisCount = 3, this.childAspectRatio = 2});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // BAŞLIK ALANI
        if (title != null) ...[
          Container(
            alignment: Alignment.centerLeft,
            height: 85,
            child: Text(
              title!,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, letterSpacing: -0.5),
            ),
          ),
          SizedBox(height: 15),
        ],

        // GRID ALANI
        Expanded(
          child: items.isEmpty
              ? _buildEmptyState(context)
              : GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 12, top: 12),
                  itemCount: items.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: childAspectRatio,
                  ),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return MenuCard(item: item, onTap: () => _handleMenuTap(context, item));
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.category_outlined, size: 64, color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            'Bu kategoriye ait alt menü bulunamadı.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.outline),
          ),
        ],
      ),
    );
  }

  void _handleMenuTap(BuildContext context, MenuItem m) {
    debugPrint(m.slug);
    // if (m.builder != null) {
    //   showDialog(context: context, builder: (dialogContext) => m.builder!(dialogContext));
    //   return;
    // }

    if (m.route != null && m.route!.isNotEmpty) {
      context.pushNamed(m.route!);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${m.label} sayfası henüz hazır değil.'), behavior: SnackBarBehavior.floating),
    );
  }
}
