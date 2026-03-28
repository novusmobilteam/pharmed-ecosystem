import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../core/core.dart';

import '../../../../core/widgets/remaining_day_badge.dart';
import '../../../../core/widgets/unified_table/unified_table_models.dart';
import '../../../../core/widgets/unified_table/unified_table_view.dart';
import '../../user.dart';
import '../../../station/domain/entity/station.dart';
import '../../../station/domain/repository/i_station_repository.dart';
import '../../../role/domain/entity/role.dart';
import '../../../role/domain/repository/i_role_repository.dart';
import '../notifier/user_form_notifier.dart';
import '../notifier/user_table_notifier.dart';

part 'user_registration_dialog.dart';
part 'user_table_view.dart';

class UserScreen extends StatelessWidget {
  const UserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserTableNotifier(
        getUsersUseCase: context.read(),
        deleteUserUseCase: context.read(),
        bulkUpdateValidDateUseCase: context.read(),
      )..init(),
      child: Consumer<UserTableNotifier>(
        builder: (context, notifier, _) {
          return ResponsiveLayout(
            mobile: SizedBox(),
            tablet: SizedBox(),
            desktop: DesktopLayout(
              title: 'Kullanıcı Tanımlama',
              showAddButton: true,
              onAddPressed: () => _showUserRegistrationDialog(context, notifier),
              actions: [
                if (notifier.showValidDateIcon)
                  IconButton(
                    onPressed: () => _showValidDateDialog(context, notifier),
                    tooltip: 'Son Geçerlilik Tarihi Güncelle',
                    icon: Icon(PhosphorIcons.calendar()),
                  ),
              ],
              child: UserTableView(),
            ),
          );
        },
      ),
    );
  }
}

void _showValidDateDialog(BuildContext context, UserTableNotifier vm) {
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

void _showUserRegistrationDialog(BuildContext context, UserTableNotifier notifier, {User? user}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => ChangeNotifierProvider(
      create: (context) => UserFormNotifier(
        user: user,
        saveUserUseCase: context.read(),
        stationRepository: context.read(),
      ),
      child: const UserRegistrationDialog(),
    ),
  );

  if (result == true) {
    notifier.getUsers();
  }
}

void _onDelete(BuildContext context, UserTableNotifier vm, User user) {
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
