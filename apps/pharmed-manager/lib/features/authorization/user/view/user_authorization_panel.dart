part of 'user_table_view.dart';

class UserAuthorizationPanel extends StatelessWidget {
  const UserAuthorizationPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final authNotifier = context.watch<AuthorizationNotifier>();
    final selectedUser = authNotifier.selectedUser;

    return ChangeNotifierProvider(
      create: (BuildContext context) => UserAuthorizationNotifier(
        user: selectedUser!,
        getAuthUseCase: context.read(),
        saveAuthUseCase: context.read(),
        getMenusUseCase: context.read(),
      )..initialize(),
      child: Consumer<UserAuthorizationNotifier>(
        builder: (context, notifier, child) {
          return SidePanel(
            title: 'Kullanıcı Yetkilendirme',
            disableScroll: true,
            isLoading: notifier.isUpdating,
            onClose: authNotifier.closePanel,
            onSave: () async {
              await notifier.submit(
                onFailed: (msg) => MessageUtils.showErrorDialog(context, notifier.statusMessage),
                onSuccess: (msg) {
                  MessageUtils.showSuccessSnackbar(context, notifier.statusMessage);
                  authNotifier.closePanel();
                },
              );
            },
            child: MenuBrowserView(
              items: notifier.menuTree,
              selectedItems: notifier.selectedItems,
              onItemSelected: (menuItem) {
                notifier.toggleMenuPermission(menuItem.id ?? 0);
              },
              onCategoryToggled: (category) {
                notifier.toggleCategorySelection(category);
              },
              isCategoryFullySelected: (category) {
                return notifier.isCategoryFullySelected(category);
              },
              isCategoryPartiallySelected: (category) {
                return notifier.isCategoryPartiallySelected(category);
              },
            ),
          );
        },
      ),
    );
  }
}
