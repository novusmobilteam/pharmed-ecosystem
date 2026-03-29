import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../../core/widgets/unified_table/unified_table_models.dart';
import '../../../../../core/widgets/unified_table/unified_table_view.dart';
import '../notifier/role_table_notifier.dart';

import 'package:provider/provider.dart';

import '../../../../../core/core.dart';
import 'role_drug_authentication_view.dart';
import '../notifier/role_drug_auth_notifier.dart';
import 'role_mc_authentication_view.dart';
import '../notifier/role_mc_auth_notifier.dart';
import '../notifier/role_menu_auth_notifier.dart';
import 'role_menu_authentication_view.dart';

part 'role_authentication_view.dart';

class RoleTableView extends StatefulWidget {
  const RoleTableView({super.key});

  @override
  State<RoleTableView> createState() => _RoleTableViewState();
}

class _RoleTableViewState extends State<RoleTableView> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: context.read<RoleTableNotifier>(),
      child: Consumer<RoleTableNotifier>(
        builder: (context, vm, child) {
          if (vm.isFetching && vm.isEmpty) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          if (vm.isEmpty) {
            return CommonEmptyStates.noData();
          }

          return UnifiedTableView<Role>(
            data: vm.items,
            isLoading: vm.isFetching,
            enableSearch: true,
            enableExcel: true,
            enablePDF: true,
            enablePagination: true,
            pageSize: vm.pageSize,
            currentPage: vm.currentPage,
            // totalCount: vm.totalCount,
            onSearchChanged: vm.search,
            onPageChanged: (page) {
              vm.setPage(page);
              vm.getRoles();
            },
            actions: [
              TableActionItem(
                icon: PhosphorIcons.pen(),
                tooltip: 'Düzenle',
                onPressed: (user) => showRoleMenuAuthenticationView(context, user),
              ),
            ],
          );
        },
      ),
    );
  }
}

void showRoleMenuAuthenticationView(BuildContext context, Role role) {
  showDialog(
    context: context,
    builder: (context) => MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => RoleMenuAuthNotifier(
            role: role,
            getAuthUseCase: context.read(),
            saveAuthUseCase: context.read(),
            getMenusUseCase: context.read(),
          )..initialize(),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              RoleDrugAuthNotifier(role: role, getAuthUseCase: context.read(), saveAuthUseCase: context.read())
                ..initialize(),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              RoleMcAuthNotifier(role: role, getAuthUseCase: context.read(), saveAuthUseCase: context.read())
                ..initialize(),
        ),
      ],
      child: RoleAuthenticationView(role: role),
    ),
  );
}
