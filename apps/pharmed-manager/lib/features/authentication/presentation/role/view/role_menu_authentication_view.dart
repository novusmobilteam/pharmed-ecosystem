import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';
import 'package:provider/provider.dart';

import '../../../../../core/widgets/menu_browser_dialog.dart';
import '../notifier/role_menu_auth_notifier.dart';

class RoleMenuAuthenticationView extends StatelessWidget {
  const RoleMenuAuthenticationView({super.key, required this.role});

  final Role role;

  @override
  Widget build(BuildContext context) {
    return Consumer<RoleMenuAuthNotifier>(
      builder: (context, notifier, child) {
        if (notifier.isFetching) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }

        return MenuBrowserDialog(
          title: 'Rol Yetkilendirme',
          items: notifier.menuTree,
          selectedItems: notifier.selectedItems,
          onItemSelected: (menuItem) {
            notifier.toggleMenuPermission(menuItem.id ?? 0);
          },
          onCategoryToggled: (category) {
            notifier.toggleCategorySelection(category);
          },
          isCategoryFullySelected: (category) {
            return notifier.isCategoryFullySelected(category);
          },
          isCategoryPartiallySelected: (category) {
            return notifier.isCategoryPartiallySelected(category);
          },
        );
      },
    );
  }
}
