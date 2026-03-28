part of 'user_table_view.dart';

class UserMenuAuthenticationView extends StatelessWidget {
  const UserMenuAuthenticationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserAuthenticationNotifier>(
      builder: (context, vm, child) {
        if (vm.isFetching) {
          return const Center(
            child: CircularProgressIndicator.adaptive(),
          );
        }

        return RegistrationDialog(
          title: 'Kullanıcı Yetkilendirme',
          isLoading: vm.isUpdating,
          width: 1200,
          maxHeight: 850,
          onSave: () async {
            await vm.saveChanges();

            if (context.mounted && vm.isSuccess(vm.submitKey)) {
              MessageUtils.showSuccessSnackbar(context, vm.statusMessage);
              context.pop(true);
            } else if (context.mounted && vm.isFailed(vm.submitKey)) {
              MessageUtils.showErrorDialog(context, vm.statusMessage);
            }
          },
          child: MenuBrowserDialog(
            title: 'Menü Yetkilendirme',
            items: vm.menuTree,
            selectedItems: vm.selectedItems,
            onItemSelected: (menuItem) {
              vm.toggleMenuPermission(menuItem.id ?? 0);
            },
            onCategoryToggled: (category) {
              vm.toggleCategorySelection(category);
            },
            isCategoryFullySelected: (category) {
              return vm.isCategoryFullySelected(category);
            },
            isCategoryPartiallySelected: (category) {
              return vm.isCategoryPartiallySelected(category);
            },
          ),
        );
      },
    );
  }
}
