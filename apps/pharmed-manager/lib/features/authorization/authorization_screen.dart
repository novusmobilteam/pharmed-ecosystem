import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/widgets/side_panel.dart';
import 'package:pharmed_manager/features/authorization/authorization_notifier.dart';
import 'package:provider/provider.dart';

import '../../core/core.dart';
import 'role/notifier/role_table_notifier.dart';
import 'role/view/role_table_view.dart';
import 'user/notifier/user_table_notifier.dart';
import 'user/view/user_table_view.dart';

const _titles = ['Kullanıcı Yetkilendirme', 'Rol Yetkilendirme'];

class AuthorizationScreen extends StatelessWidget {
  const AuthorizationScreen({super.key, required this.menu});

  final MenuItem menu;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthorizationNotifier()),
        ChangeNotifierProvider(create: (context) => UserTableNotifier(getUsersUseCase: context.read())..getUsers()),
        ChangeNotifierProvider(create: (context) => RoleTableNotifier(getRolesUseCase: context.read())..getRoles()),
      ],
      child: Consumer<AuthorizationNotifier>(
        builder: (context, notifier, _) {
          return ResponsiveLayout(
            mobile: SizedBox(),
            tablet: SizedBox(),
            desktop: DesktopLayout(
              title: menu.name ?? 'Kullanıcı/Rol Yetkilendirme',
              subtitle: menu.description,
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
                      child: PharmedSegmentedButton(
                        selectedIndex: notifier.activeIndex,
                        onChanged: (index) => notifier.activeIndex = index,
                        labels: _titles,
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
