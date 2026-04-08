import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../../core/core.dart';
import '../../../../../core/widgets/side_panel.dart';
import '../../../notifier/station_setup_notifier.dart';
import '../notifier/warehouse_form_notifier.dart';
import '../notifier/warehouse_notifier.dart';

class WarehouseFormPanel extends StatelessWidget {
  const WarehouseFormPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final setupNotifier = context.watch<StationSetupNotifier>();
    final formKey = GlobalKey<FormState>();
    final isNew = setupNotifier.editingWarehouse == null;

    return ChangeNotifierProvider(
      create: (BuildContext context) => WarehouseFormNotifier(
        createWarehouseUseCase: context.read(),
        updateWarehouseUseCase: context.read(),
        warehouse: setupNotifier.editingWarehouse,
      ),
      child: Consumer<WarehouseFormNotifier>(
        builder: (context, notifier, _) {
          return SidePanel(
            title: isNew ? 'Yeni Depo' : 'Depo Düzenle',
            subtitle: isNew ? 'Depo bilgilerini doldurun' : 'Depo bilgilerini güncelleyin',
            isLoading: notifier.isSubmitting,
            onClose: () => setupNotifier.closePanel(),
            onSave: () async {
              if (formKey.currentState!.validate()) {
                await notifier.submit();

                if (context.mounted && notifier.isSuccess(notifier.submitOp)) {
                  MessageUtils.showSuccessSnackbar(context, notifier.statusMessage);
                  context.read<StationSetupNotifier>().closePanel();
                  context.read<WarehouseNotifier>().getWarehouses();
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
      ),
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
      builder: (context, notifier, _) {
        return SelectionField<User>(
          label: 'Depo Sorumlusu',
          title: 'Depo Sorumlusu Seç',
          initialValue: notifier.warehouse.user,
          dataSource: (skip, take, search) => context.read<GetUsersUseCase>().call(GetUsersParams()),
          labelBuilder: (w) => w.fullName,
          onSelected: notifier.updateUser,
          validator: (value) => Validators.cannotBlankValidator(value?.toString()),
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
