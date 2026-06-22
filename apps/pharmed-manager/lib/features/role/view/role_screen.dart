import 'package:flutter/material.dart';
import '../../../../widgets/side_panel.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../core/core.dart';

import '../notifier/role_form_notifier.dart';
import '../notifier/role_notifier.dart';

part 'role_form_panel.dart';

class RoleScreen extends StatelessWidget {
  const RoleScreen({super.key, required this.menu});

  final MenuItem menu;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => RoleNotifier(getRolesUseCase: context.read(), deleteRoleUseCase: context.read())..fetch(),
      child: Consumer<RoleNotifier>(
        builder: (context, notifier, _) {
          return MedResponsiveLayout(
            mobile: MedMobileLayout(),
            tablet: MedTabletLayout(),
            desktop: MedDesktopLayout(
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
      return EmptyStateWidget(variant: EmptyStateVariant.noResults);
    }

    return MedTable<Role>(
      data: notifier.items,
      isLoading: notifier.isFetching,
      enableExcel: true,
      enableSearch: true,
      enablePDF: true,
      enablePagination: true,
      currentPage: notifier.currentPage,
      onPageChanged: (page) {
        notifier.setPage(page);
        notifier.fetch();
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
