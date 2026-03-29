import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/core.dart';
import '../notifier/warehouse_form_notifier.dart';

class WarehouseRegistrationDialog extends StatelessWidget {
  const WarehouseRegistrationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final notifier = context.read<WarehouseFormNotifier>();
    final String title = notifier.isCreate ? 'Yeni Depo' : 'Depo Düzenle';

    return Consumer<WarehouseFormNotifier>(
      builder: (context, vm, _) {
        return RegistrationDialog(
          title: title,
          maxHeight: 700,
          isLoading: notifier.isSubmitting,
          onClose: () => context.pop(false),
          onSave: () async {
            if (formKey.currentState!.validate()) {
              await notifier.submit();

              if (context.mounted && notifier.isSuccess(notifier.submitOp)) {
                MessageUtils.showSuccessSnackbar(context, notifier.statusMessage);
                context.pop(true);
              } else if (context.mounted && notifier.isFailed(notifier.submitOp)) {
                MessageUtils.showErrorDialog(context, notifier.statusMessage);
              }
            }
          },
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: AppDimensions.registrationDialogSpacing,
              children: const [_NameField(), _CodeField(), _WarehouseTypeField(), _UserField(), _StatusField()],
            ),
          ),
        );
      },
    );
  }
}

class _CodeField extends StatelessWidget {
  const _CodeField();

  @override
  Widget build(BuildContext context) {
    return Consumer<WarehouseFormNotifier>(
      builder: (context, vm, _) {
        return TextInputField(
          label: 'Depo Kodu',
          maxLength: 5,
          keyboardType: TextInputType.number,
          initialValue: vm.warehouse.code.toCustomString(),
          validator: (value) => Validators.cannotBlankValidator(value),
          onChanged: (value) {
            final intValue = int.tryParse(value ?? '');
            vm.updateCode(intValue);
          },
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        );
      },
    );
  }
}

class _NameField extends StatelessWidget {
  const _NameField();

  @override
  Widget build(BuildContext context) {
    return Consumer<WarehouseFormNotifier>(
      builder: (context, vm, _) {
        return TextInputField(
          label: 'Depo Adı',
          autoFocus: vm.isCreate,
          initialValue: vm.warehouse.name,
          validator: Validators.cannotBlankValidator,
          onChanged: vm.updateName,
        );
      },
    );
  }
}

class _WarehouseTypeField extends StatelessWidget {
  const _WarehouseTypeField();

  @override
  Widget build(BuildContext context) {
    return Consumer<WarehouseFormNotifier>(
      builder: (context, vm, _) {
        return DropdownInputField<WarehouseType>(
          label: 'Depo Türü',
          options: WarehouseType.values,
          initialValue: vm.warehouse.type,
          labelBuilder: (value) => value?.label,
          validator: (value) => Validators.cannotBlankValidator(value?.label),
          onChanged: vm.updateType,
        );
      },
    );
  }
}

class _UserField extends StatelessWidget {
  const _UserField();

  @override
  Widget build(BuildContext context) {
    return Consumer<WarehouseFormNotifier>(
      builder: (context, vm, _) {
        return DialogInputField<User>(
          label: 'Depo Sorumlusu',
          initialValue: vm.warehouse.user,
          labelBuilder: (u) => u?.surname == null ? u?.name : u?.fullName,
          future: () => context.read<GetUsersUseCase>().call(const GetUsersParams()),
          validator: (value) => Validators.cannotBlankValidator(value?.fullName),
          onSelected: vm.updateUser,
        );
      },
    );
  }
}

class _StatusField extends StatelessWidget {
  const _StatusField();

  @override
  Widget build(BuildContext context) {
    return Consumer<WarehouseFormNotifier>(
      builder: (context, vm, _) {
        return DropdownInputField<Status>(
          label: 'Durumu',
          options: Status.values,
          initialValue: vm.warehouse.status,
          labelBuilder: (s) => s?.label,
          validator: (value) => Validators.cannotBlankValidator(value?.label),
          onChanged: vm.updateStatus,
        );
      },
    );
  }
}
