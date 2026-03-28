import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../../core/core.dart';
import '../../../../../core/widgets/menu_browser_dialog.dart';
import '../../../../../core/widgets/unified_table/unified_table_models.dart';
import '../../../../../core/widgets/unified_table/unified_table_view.dart';
import '../../../../user/user.dart';
import '../notifier/user_authentication_notifier.dart';
import '../notifier/user_table_notifier.dart';

part 'user_menu_authentication_view.dart';

class UserTableView extends StatelessWidget {
  const UserTableView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: context.read<UserTableNotifier>(),
      child: Consumer<UserTableNotifier>(
        builder: (context, vm, child) {
          return UnifiedTableView<User>(
            data: vm.items,
            isLoading: vm.isFetching,
            enableSearch: true,
            enableExcel: true,
            enablePDF: true,
            onSearchChanged: vm.search,

            // enablePagination: true,
            // pageSize: vm.pageSize,
            // currentPage: vm.currentPage,
            // totalCount: vm.totalCount,

            // onPageChanged: (page) {
            //   vm.setPage(page);
            //   vm.getUsers();
            // },
            actions: [
              TableActionItem(
                icon: PhosphorIcons.pen(),
                tooltip: 'Düzenle',
                onPressed: (user) => _openAuthenticationView(context, user),
              ),
            ],
          );
        },
      ),
    );
  }
}

void _openAuthenticationView(BuildContext context, User user) {
  showDialog(
    context: context,
    builder: (context) => ChangeNotifierProvider(
      create: (context) => UserAuthenticationNotifier(
        user: user,
        getAuthUseCase: context.read(),
        saveAuthUseCase: context.read(),
        getMenusUseCase: context.read(),
      )..initialize(),
      child: UserMenuAuthenticationView(),
    ),
  );
}
