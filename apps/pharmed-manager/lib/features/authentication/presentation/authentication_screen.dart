import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/core.dart';
import 'role/notifier/role_table_notifier.dart';
import 'role/view/role_table_view.dart';
import 'user/notifier/user_table_notifier.dart';
import 'user/view/user_table_view.dart';

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  int _activeIndex = 0;

  void changeTab(int index) {
    setState(() {
      _activeIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => UserTableNotifier(
            getUsersUseCase: context.read(),
          )..getUsers(),
        ),
        ChangeNotifierProvider(
          create: (context) => RoleTableNotifier(
            getRolesUseCase: context.read(),
          )..getRoles(),
        ),
      ],
      child: ResponsiveLayout(
        mobile: SizedBox(),
        tablet: SizedBox(),
        desktop: DesktopLayout(
          showAddButton: false,
          title: 'Kullanıcı/Rol Yetkilendirme',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 20,
            children: [
              SizedBox(
                width: 400,
                child: PharmedSegmentedButton(
                  selectedIndex: _activeIndex,
                  onChanged: changeTab,
                  labels: [
                    'Kullanıcı Yetkilendirme',
                    'Rol Yetkilendirme',
                  ],
                ),
              ),
              Expanded(
                child: IndexedStack(
                  index: _activeIndex,
                  children: [
                    UserTableView(),
                    RoleTableView(),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
