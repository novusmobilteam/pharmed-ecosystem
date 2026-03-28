import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../core/core.dart';
import '../../../menu/menu.dart';
import '../notifier/favorite_notifier.dart';

part 'add_favorite_button.dart';
part 'add_favorite_view.dart';
part 'favorite_card.dart';
part 'favorite_list_card.dart';

class FavoriteQuickAccess extends StatelessWidget {
  const FavoriteQuickAccess({super.key, required this.allMenuItems});

  final List<MenuItem> allMenuItems;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<FavoriteNotifier>(
      create: (context) => FavoriteNotifier(
        getFavoriteItemsUseCase: context.read(),
        toggleFavoriteUseCase: context.read(),
      )..initialize(allMenuItems),
      child: _FavoriteContent(allMenuItems),
    );
  }
}

class _FavoriteContent extends StatelessWidget {
  const _FavoriteContent(this.allMenuItems);

  final List<MenuItem> allMenuItems;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Consumer<FavoriteNotifier>(
          builder: (context, notifier, _) {
            final favorites = notifier.favoriteMenuItems;

            if (notifier.isLoading(notifier.fetchOp)) {
              return SizedBox();
            }

            if (favorites.isEmpty) {
              return const SizedBox();
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final item = favorites[index];
                return FavoriteListCard(
                  item: item,
                  onTap: () => _handleMenuNavigation(context, item),
                );
              },
            );
          },
        ),
        Spacer(),
        AddFavoriteButton(allMenuItems: allMenuItems),
      ],
    );
  }

  void _handleMenuNavigation(BuildContext context, MenuItem item) {
    if (item.builder != null) {
      showDialog(context: context, builder: (context) => item.builder!(context));
    } else if (item.route != null) {
      context.pushNamed(item.route!);
    }
  }
}
