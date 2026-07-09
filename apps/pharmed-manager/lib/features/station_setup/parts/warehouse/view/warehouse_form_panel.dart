import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../../core/core.dart';
import '../../../../../../widgets/side_panel.dart';
import '../../../notifier/station_setup_notifier.dart';
import '../notifier/warehouse_form_notifier.dart';
import '../notifier/warehouse_notifier.dart';

class WarehouseFormPanel extends StatelessWidget {
  const WarehouseFormPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final setupNotifier = context.watch<StationSetupNotifier>();
    final formKey = GlobalKey<FormState>();
    final isNew = setupNotifier.selectedWarehouse == null;

    return ChangeNotifierProvider(
      create: (BuildContext context) => WarehouseFormNotifier(
        createWarehouseUseCase: context.read(),
        updateWarehouseUseCase: context.read(),
        warehouse: setupNotifier.selectedWarehouse,
      ),
      child: Consumer<WarehouseFormNotifier>(
        builder: (context, notifier, _) {
          return SidePanel(
            title: isNew ? context.l10n.stationSetup_warehouse_formTitleNew : context.l10n.stationSetup_warehouse_formTitleEdit,
            subtitle: isNew
                ? context.l10n.stationSetup_warehouse_formSubtitleNew
                : context.l10n.stationSetup_warehouse_formSubtitleEdit,
            isLoading: notifier.isSubmitting,
            onClose: () => setupNotifier.closePanel(),
            onSave: () async {
              if (formKey.currentState!.validate()) {
                final wasCreate = notifier.isCreate;
                await notifier.submit();

                if (context.mounted && notifier.isSuccess(notifier.submitOp)) {
                  MessageUtils.showSuccessSnackbar(
                    context,
                    wasCreate
                        ? context.l10n.stationSetup_warehouse_createdSuccessMessage
                        : context.l10n.stationSetup_warehouse_updatedSuccessMessage,
                  );
                  context.read<StationSetupNotifier>().closePanel();
                  context.read<WarehouseNotifier>().fetch();
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
        return MedTextInputField(
          label: context.l10n.stationSetup_warehouse_codeLabel,
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
        return MedTextInputField(
          label: context.l10n.stationSetup_warehouse_nameLabel,
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
        return MedDropdownInputField<WarehouseType>(
          label: context.l10n.stationSetup_warehouse_typeLabel,
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
        return MedSelectionField<User>(
          label: context.l10n.stationSetup_warehouse_managerLabel,
          title: context.l10n.stationSetup_warehouse_managerSelectTitle,
          initialValue: notifier.warehouse.user,
          dataSource: (skip, take, search) =>
              context.read<GetUsersUseCase>().call(GetUsersParams(skip: skip, take: take, search: search)),
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
        return MedDropdownInputField<Status>(
          label: context.l10n.stationSetup_common_statusLabel,
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
