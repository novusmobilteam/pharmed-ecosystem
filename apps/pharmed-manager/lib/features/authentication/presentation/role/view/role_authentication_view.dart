part of 'role_table_view.dart';

class RoleAuthenticationView extends StatefulWidget {
  const RoleAuthenticationView({super.key, required this.role});

  final Role role;

  @override
  State<RoleAuthenticationView> createState() => _RoleAuthenticationViewState();
}

class _RoleAuthenticationViewState extends State<RoleAuthenticationView> {
  int _activeTab = 0;

  void changeTab(int index) {
    setState(() {
      _activeTab = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return RegistrationDialog(
      maxHeight: context.height,
      width: context.width * 0.8,
      showSearch: _activeTab == 1,
      isLoading: isLoading(context),
      onSearchChanged: (value) {
        if (_activeTab == 1) {
          context.read<RoleDrugAuthNotifier>().onSearch(value);
        }
      },
      onSave: () => _onSave(context, _activeTab),
      title: 'Rol Yetkilendirme - ${widget.role.name}',
      child: Column(
        spacing: 20,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 500,
            child: PharmedSegmentedButton(
              selectedIndex: _activeTab,
              onChanged: changeTab,
              labels: ['Menü', 'İlaç', 'Tıbbi Sarf'],
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: _activeTab,
              children: [
                // 1. Sekme: Menü
                RoleMenuAuthenticationView(role: widget.role),
                // 2. Sekme: İlaç
                RoleDrugAuthenticationView(role: widget.role),
                // 3. Sekme: Tıbbi Sarf
                RoleMcAuthenticationView(role: widget.role),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

bool isLoading(BuildContext context) {
  return context.watch<RoleMenuAuthNotifier>().isSubmitting ||
      context.watch<RoleDrugAuthNotifier>().isSubmitting ||
      context.watch<RoleMcAuthNotifier>().isSubmitting;
}

void _onSave(BuildContext context, int activeTab) {
  if (activeTab == 0) {
    context.read<RoleMenuAuthNotifier>().submit(
          onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
          onSuccess: (msg) => MessageUtils.showSuccessSnackbar(context, msg),
        );
  }
  if (activeTab == 1) {
    context.read<RoleDrugAuthNotifier>().submit(
          onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
          onSuccess: (msg) => MessageUtils.showSuccessSnackbar(context, msg),
        );
  }
  if (activeTab == 2) {
    context.read<RoleMcAuthNotifier>().submit(
          onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
          onSuccess: (msg) => MessageUtils.showSuccessSnackbar(context, msg),
        );
  }
}
