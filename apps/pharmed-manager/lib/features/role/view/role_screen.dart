import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/widgets/side_panel.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../core/core.dart';
import '../../../core/widgets/unified_table/unified_table_models.dart';
import '../../../core/widgets/unified_table/unified_table_view.dart';
import '../notifier/role_form_notifier.dart';
import '../notifier/role_notifier.dart';

part 'role_form_panel.dart';

class RoleScreen extends StatelessWidget {
  const RoleScreen({super.key, required this.menu});

  final MenuItem menu;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => RoleNotifier(getRolesUseCase: context.read(), deleteRoleUseCase: context.read())..getRoles(),
      child: Consumer<RoleNotifier>(
        builder: (context, notifier, _) {
          return ResponsiveLayout(
            mobile: MobileLayout(),
            tablet: TabletLayout(),
            desktop: DesktopLayout(
              title: menu.name ?? 'Rol Tanımlama',
              subtitle: menu.description,
              actions: [MedButton(label: 'Yeni Rol', size: MedButtonSize.sm, onPressed: () => notifier.openPanel())],
              onAddPressed: () => notifier.openPanel(),
              child: SidePanelWrapper(
                isOpen: notifier.isPanelOpen,
                width: 400,
                panel: RoleFormPanel(),
                child: _buildContent(context, notifier),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, RoleNotifier notifier) {
    if (notifier.isFetching && notifier.items.isEmpty) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (notifier.items.isEmpty) {
      return CommonEmptyStates.generic(
        icon: PhosphorIcons.user(),
        message: 'Henüz rol bulunmuyor',
        subMessage: 'Yeni rol eklemek için "+" butonuna tıklayın',
      );
    }

    return UnifiedTableView<Role>(
      data: notifier.items,
      isLoading: notifier.isFetching,
      enableExcel: true,
      enableSearch: true,
      enablePDF: true,
      enablePagination: true,
      currentPage: notifier.currentPage,
      onPageChanged: (page) {
        notifier.setPage(page);
        notifier.getRoles();
      },
      onSearchChanged: notifier.search,
      actions: [
        TableActionItem(icon: PhosphorIcons.trash(), tooltip: 'Sil', onPressed: notifier.deleteRole),
        TableActionItem(
          icon: PhosphorIcons.pen(),
          tooltip: 'Düzenle',
          onPressed: (role) => notifier.openPanel(item: role),
        ),
      ],
    );
  }
}
