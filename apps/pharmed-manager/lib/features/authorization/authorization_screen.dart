import 'package:flutter/material.dart';
import '../../../widgets/side_panel.dart';
import 'package:pharmed_manager/features/authorization/authorization_notifier.dart';
import 'package:provider/provider.dart';

import '../../core/core.dart';
import 'role/notifier/role_table_notifier.dart';
import 'role/view/table_view.dart';
import 'user/notifier/user_table_notifier.dart';
import 'user/view/table_view.dart';

class AuthorizationScreen extends StatelessWidget {
  const AuthorizationScreen({super.key, required this.menu});

  final MenuItem menu;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthorizationNotifier()),
        ChangeNotifierProvider(create: (context) => UserTableNotifier(getUsersUseCase: context.read())..fetch()),
        ChangeNotifierProvider(create: (context) => RoleTableNotifier(getRolesUseCase: context.read())..fetch()),
      ],
      child: Consumer<AuthorizationNotifier>(
        builder: (context, notifier, _) {
          final titles = [context.l10n.authorization_userTabTitle, context.l10n.authorization_roleTabTitle];
          return MedResponsiveLayout(
            mobile: SizedBox(),
            tablet: SizedBox(),
            desktop: MedDesktopLayout(
              menu: menu,
              child: SidePanelWrapper(
                isOpen: notifier.isPanelOpen,
                width: 880,
                panel: switch (notifier.panelType) {
                  AuthorizationPanelType.user => UserAuthorizationPanel(),
                  AuthorizationPanelType.role => RoleAuthorizationPanel(),
                  null => const SizedBox.shrink(),
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 20,
                  children: [
                    SizedBox(
                      width: 400,
                      child: MedSegmentedButton(
                        selectedIndex: notifier.activeIndex,
                        onChanged: (index) => notifier.activeIndex = index,
                        labels: titles,
                      ),
                    ),
                    Expanded(
                      child: IndexedStack(
                        index: notifier.activeIndex,
                        children: [
                          UserTableView(onEdit: (user) => notifier.openUserPanel(user: user)),
                          RoleTableView(onEdit: (role) => notifier.openRolePanel(role: role)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
