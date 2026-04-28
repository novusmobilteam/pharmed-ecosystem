import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:pharmed_manager/core/widgets/side_panel.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../core/core.dart';

import '../../../core/widgets/remaining_day_badge.dart';
import '../../../core/widgets/unified_table/unified_table_models.dart';
import '../../../core/widgets/unified_table/unified_table_view.dart';

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
          return ResponsiveLayout(
            mobile: SizedBox(),
            tablet: SizedBox(),
            desktop: DesktopLayout(
              title: menu.name ?? 'Kullanıcı Listesi',
              subtitle: menu.description,
              showAddButton: true,
              onAddPressed: notifier.openPanel,
              actions: [
                MedButton(label: 'Yeni Kullanıcı', size: MedButtonSize.sm, onPressed: () => notifier.openPanel()),
                if (notifier.showValidDateIcon)
                  MedButton(
                    label: 'Son Geçerlilik Tarihi Güncelle',
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
      title: 'Tarih Güncelle',
      saveButtonText: 'Güncelle',
      isLoading: vm.isLoading(vm.updateValidDateOp),
      onSave: () async {
        await vm.updateValidDate();
        if (ctx.mounted && vm.isSuccess(vm.updateValidDateOp)) {
          MessageUtils.showSuccessSnackbar(context, vm.message(vm.updateValidDateOp));
          Navigator.pop(ctx);
        } else if (ctx.mounted && vm.isFailed(vm.updateValidDateOp)) {
          MessageUtils.showErrorSnackbar(context, vm.message(vm.updateValidDateOp) ?? 'Bir hata oluştu.');
        }
      },
      child: DateInputField(
        label: 'Yeni Son Geçerlilik Tarihi',
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
      await vm.deleteUser(user);
      if (context.mounted) {
        hideLoading(context);
        if (vm.isSuccess(vm.deleteOp)) {
          MessageUtils.showSuccessSnackbar(context, vm.message(vm.deleteOp));
        }
      }
    },
  );
}
