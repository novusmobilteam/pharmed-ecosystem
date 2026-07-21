import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../widgets/side_panel.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../core/core.dart';

import '../notifier/user_form_notifier.dart';
import '../notifier/user_notifier.dart';

part 'user_form_panel.dart';
part 'user_table_view.dart';

class UserScreen extends StatelessWidget {
  const UserScreen({super.key, required this.menu});

  final MenuItem menu;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserNotifier(
        getUsersUseCase: context.read(),
        deleteUserUseCase: context.read(),
        bulkUpdateValidDateUseCase: context.read(),
      )..init(),
      child: Consumer<UserNotifier>(
        builder: (context, notifier, _) {
          return MedResponsiveLayout(
            mobile: SizedBox(),
            tablet: SizedBox(),
            desktop: MedDesktopLayout(
              menu: menu,
              showAddButton: true,
              onAddPressed: notifier.openPanel,
              actions: [
                MedButton(
                  label: context.l10n.userScreenAddButton,
                  size: MedButtonSize.sm,
                  onPressed: () => notifier.openPanel(),
                ),
                if (notifier.showValidDateIcon)
                  MedButton(
                    label: context.l10n.userBulkUpdateValidDateButton,
                    size: MedButtonSize.sm,
                    onPressed: () => _showValidDateDialog(context, notifier),
                  ),
              ],
              child: SidePanelWrapper(
                isOpen: notifier.isPanelOpen,
                width: 500,
                panel: UserFormPanel(),
                child: UserTableView(onEdit: (user) => notifier.openPanel(item: user)),
              ),
            ),
          );
        },
      ),
    );
  }
}

void _showValidDateDialog(BuildContext context, UserNotifier vm) {
  showDialog(
    context: context,
    builder: (ctx) => RegistrationDialog(
      maxHeight: 350,
      width: 400,
      title: context.l10n.userValidDateDialogTitle,
      saveButtonText: context.l10n.userValidDateDialogSaveButton,
      isLoading: vm.isLoading(vm.updateValidDateOp),
      onSave: () async {
        await vm.updateValidDate(successMessage: context.l10n.userValidDateUpdateSuccessMessage);
        if (ctx.mounted && vm.isSuccess(vm.updateValidDateOp)) {
          MessageUtils.showSuccessSnackbar(context, vm.message(vm.updateValidDateOp));
          Navigator.pop(ctx);
        } else if (ctx.mounted && vm.isFailed(vm.updateValidDateOp)) {
          MessageUtils.showErrorSnackbar(
            context,
            vm.message(vm.updateValidDateOp) ?? context.l10n.common_genericErrorMessage,
          );
        }
      },
      child: MedDateInputField(
        label: context.l10n.userNewValidUntilLabel,
        initialValue: vm.validDate,
        onDateSelected: (date) => vm.validDate = date,
      ),
    ),
  );
}

void _onDelete(BuildContext context, UserNotifier vm, User user) {
  MessageUtils.showConfirmDeleteDialog(
    context: context,
    onConfirm: () async {
      showLoading(context);
      await vm.deleteUser(user, successMessage: context.l10n.userDeleteSuccessMessage);
      if (context.mounted) {
        hideLoading(context);
        if (vm.isSuccess(vm.deleteOp)) {
          MessageUtils.showSuccessSnackbar(context, vm.message(vm.deleteOp));
        }
      }
    },
  );
}
