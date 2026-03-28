import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../core/core.dart';
import '../../../../core/widgets/unified_table/unified_table_models.dart';
import '../../../../core/widgets/unified_table/unified_table_view.dart';
import '../../domain/entity/role.dart';
import '../notifier/role_form_notifier.dart';
import '../notifier/role_table_notifier.dart';

part 'role_registration_dialog.dart';

class RoleScreen extends StatelessWidget {
  const RoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => RoleTableNotifier(
        getRolesUseCase: context.read(),
        deleteRoleUseCase: context.read(),
      )..getRoles(),
      child: Consumer<RoleTableNotifier>(
        builder: (context, vm, _) {
          return ResponsiveLayout(
            mobile: MobileLayout(),
            tablet: TabletLayout(),
            desktop: _buildDesktopLayout(context, vm),
          );
        },
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, RoleTableNotifier vm) {
    return DesktopLayout(
      title: 'Rol Tanımlama',
      showAddButton: true,
      onAddPressed: () => _showRoleRegisrationDialog(context, vm),
      child: _buildContent(context, vm),
    );
  }

  Widget _buildContent(BuildContext context, RoleTableNotifier vm) {
    if (vm.isFetching && vm.items.isEmpty) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (vm.items.isEmpty) {
      return CommonEmptyStates.generic(
        icon: PhosphorIcons.user(),
        message: 'Henüz rol bulunmuyor',
        subMessage: 'Yeni rol eklemek için "+" butonuna tıklayın',
      );
    }

    return UnifiedTableView<Role>(
      data: vm.items,
      isLoading: vm.isFetching,
      enableExcel: true,
      enableSearch: true,
      enablePDF: true,
      enablePagination: true,
      currentPage: vm.currentPage,
      onPageChanged: (page) {
        vm.setPage(page);
        vm.getRoles();
      },
      onSearchChanged: vm.search,
      actions: [
        TableActionItem(
          icon: PhosphorIcons.trash(),
          tooltip: 'Sil',
          onPressed: vm.deleteRole,
        ),
        TableActionItem(
          icon: PhosphorIcons.pen(),
          tooltip: 'Düzenle',
          onPressed: (role) => _showRoleRegisrationDialog(context, vm, role: role),
        ),
      ],
    );
  }
}

Future<void> _showRoleRegisrationDialog(BuildContext context, RoleTableNotifier notifier, {Role? role}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (_) => ChangeNotifierProvider(
      create: (_) => RoleFormNotifier(
        role: role,
        createRoleUseCase: context.read(),
        updateRoleUseCase: context.read(),
      ),
      child: const RoleRegistrationDialog(),
    ),
  );

  if (result == true && context.mounted) {
    notifier.getRoles();
  }
}
