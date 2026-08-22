import 'package:flutter/material.dart';
import '../../../../widgets/side_panel.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../core/core.dart';

import '../notifier/role_form_notifier.dart';
import '../notifier/role_notifier.dart';

part 'role_form_panel.dart';
part 'table_view.dart';

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
              menu: menu,
              isLoading: notifier.isFetching,
              actions: [
                MedButton(
                  label: context.l10n.role_screenAddButton,
                  size: MedButtonSize.sm,
                  onPressed: () => notifier.openPanel(),
                ),
              ],
              onAddPressed: () => notifier.openPanel(),
              child: SidePanelWrapper(
                isOpen: notifier.isPanelOpen,
                width: 400,
                panel: RoleFormPanel(),
                child: TableView(notifier: notifier),
              ),
            ),
          );
        },
      ),
    );
  }
}
