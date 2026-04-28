part of 'role_table_view.dart';

class RoleAuthorizationPanel extends StatefulWidget {
  const RoleAuthorizationPanel({super.key});

  @override
  State<RoleAuthorizationPanel> createState() => _RoleAuthorizationPanelState();
}

class _RoleAuthorizationPanelState extends State<RoleAuthorizationPanel> {
  int _activeTab = 0;

  void changeTab(int index) {
    setState(() {
      _activeTab = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authNotifier = context.watch<AuthorizationNotifier>();
    final selectedRole = authNotifier.selectedRole!;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => RoleMenuAuthNotifier(
            role: selectedRole,
            getAuthUseCase: context.read(),
            saveAuthUseCase: context.read(),
            getMenusUseCase: context.read(),
          )..initialize(),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              RoleDrugAuthNotifier(role: selectedRole, getAuthUseCase: context.read(), saveAuthUseCase: context.read())
                ..initialize(),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              RoleMcAuthNotifier(role: selectedRole, getAuthUseCase: context.read(), saveAuthUseCase: context.read())
                ..initialize(),
        ),
      ],
      child: Builder(
        builder: (ctx) {
          final isLoading =
              ctx.watch<RoleMenuAuthNotifier>().isSubmitting ||
              ctx.watch<RoleDrugAuthNotifier>().isSubmitting ||
              ctx.watch<RoleMcAuthNotifier>().isSubmitting;

          return SidePanel(
            disableScroll: true,
            onClose: authNotifier.closePanel,
            isLoading: isLoading,
            // onSearchChanged: (value) {
            //   if (_activeTab == 1) {
            //     context.read<RoleDrugAuthNotifier>().onSearch(value);
            //   }
            // },
            onSave: () => _onSave(ctx),
            title: 'Rol Yetkilendirme - ${selectedRole.name}',
            child: Column(
              spacing: 20,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: SizedBox(
                    width: 300,
                    height: 40,
                    child: PharmedSegmentedButton(
                      selectedIndex: _activeTab,
                      onChanged: changeTab,
                      labels: ['Menü', 'İlaç', 'Tıbbi Sarf'],
                    ),
                  ),
                ),
                Expanded(
                  child: IndexedStack(
                    index: _activeTab,
                    children: [
                      // 1. Sekme: Menü
                      RoleMenuAuthenticationView(role: selectedRole),
                      // 2. Sekme: İlaç
                      RoleDrugAuthenticationView(role: selectedRole),
                      // 3. Sekme: Tıbbi Sarf
                      RoleMcAuthenticationView(role: selectedRole),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _onSave(BuildContext context) {
    switch (_activeTab) {
      case 0:
        context.read<RoleMenuAuthNotifier>().submit(
          onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
          onSuccess: (msg) => MessageUtils.showSuccessSnackbar(context, msg),
        );
      case 1:
        context.read<RoleDrugAuthNotifier>().submit(
          onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
          onSuccess: (msg) => MessageUtils.showSuccessSnackbar(context, msg),
        );
      case 2:
        context.read<RoleMcAuthNotifier>().submit(
          onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
          onSuccess: (msg) => MessageUtils.showSuccessSnackbar(context, msg),
        );
    }
  }
}
