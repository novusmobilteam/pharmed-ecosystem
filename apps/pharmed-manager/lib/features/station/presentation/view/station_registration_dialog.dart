import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/core.dart';
import '../../../service/domain/entity/service.dart';
import '../../../service/domain/repository/i_service_repository.dart';
import '../../../warehouse/domain/entity/warehouse.dart';
import '../../../warehouse/domain/repository/i_warehouse_repository.dart';
import '../notifier/station_form_notifier.dart';

class StationRegistrationDialog extends StatelessWidget {
  const StationRegistrationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final notifier = context.read<StationFormNotifier>();
    final String title = notifier.isCreate ? 'Yeni İstasyon' : 'İstasyon Düzenle';

    return Consumer<StationFormNotifier>(
      builder: (context, notifier, _) {
        return RegistrationDialog(
          title: title,
          width: 600,
          isLoading: notifier.isSubmitting,
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
          onClose: () => context.pop(false),
          child: notifier.isFetching ? Center(child: CircularProgressIndicator.adaptive()) : _buildForm(formKey),
        );
      },
    );
  }

  Form _buildForm(GlobalKey<FormState> formKey) {
    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: AppDimensions.registrationDialogSpacing,
        children: const [
          _NameField(),
          Row(
            spacing: AppDimensions.registrationDialogSpacing,
            children: [
              Expanded(
                flex: 2,
                child: _MaterialWarehouseField(),
              ),
              Expanded(child: _DrugStatusField()),
            ],
          ),
          Row(
            spacing: AppDimensions.registrationDialogSpacing,
            children: [
              Expanded(
                flex: 2,
                child: _ConsumableWarehouseField(),
              ),
              Expanded(child: _ConsumablesStatusField()),
            ],
          ),
          _ServiceField(),
          _ProvidedServices(),
        ],
      ),
    );
  }
}

class _NameField extends StatelessWidget {
  const _NameField();

  @override
  Widget build(BuildContext context) {
    return Consumer<StationFormNotifier>(
      builder: (context, notifier, _) {
        return TextInputField(
          label: 'İstasyon Adı',
          initialValue: notifier.station?.name,
          onChanged: notifier.updateName,
          validator: (v) => Validators.cannotBlankValidator(v),
        );
      },
    );
  }
}

class _MaterialWarehouseField extends StatelessWidget {
  const _MaterialWarehouseField();

  @override
  Widget build(BuildContext context) {
    return Consumer<StationFormNotifier>(
      builder: (context, notifier, _) {
        return DialogInputField<Warehouse>(
          label: 'İlaç Depo',
          initialValue: notifier.station?.materialWarehouse,
          labelBuilder: (status) => status?.name,
          onSelected: notifier.updateMaterialWarehouse,
          validator: (value) => Validators.cannotBlankValidator(value?.toString()),
          future: () => context.read<IWarehouseRepository>().getWarehouses(),
        );
      },
    );
  }
}

class _DrugStatusField extends StatelessWidget {
  const _DrugStatusField();

  @override
  Widget build(BuildContext context) {
    return Consumer<StationFormNotifier>(
      builder: (context, notifier, _) {
        return DropdownInputField<OrderStatus>(
          label: 'İlaç Durumu',
          options: OrderStatus.values,
          initialValue: notifier.station?.drugStatus,
          labelBuilder: (status) => status?.label,
          validator: (value) => Validators.cannotBlankValidator(value?.toString()),
          onChanged: notifier.updateDrugStatus,
        );
      },
    );
  }
}

class _ConsumableWarehouseField extends StatelessWidget {
  const _ConsumableWarehouseField();

  @override
  Widget build(BuildContext context) {
    return Consumer<StationFormNotifier>(
      builder: (context, notifier, _) {
        return DialogInputField<Warehouse>(
          label: 'Tıbbi Sarf Depo',
          initialValue: notifier.station?.medicalConsumableWarehouse,
          labelBuilder: (status) => status?.name,
          validator: (value) => Validators.cannotBlankValidator(value?.toString()),
          onSelected: notifier.updateConsumableWarehouse,
          future: () => context.read<IWarehouseRepository>().getWarehouses(),
        );
      },
    );
  }
}

class _ConsumablesStatusField extends StatelessWidget {
  const _ConsumablesStatusField();

  @override
  Widget build(BuildContext context) {
    return Consumer<StationFormNotifier>(
      builder: (context, notifier, _) {
        return DropdownInputField<OrderStatus>(
          label: 'Tıbbi Sarf',
          initialValue: notifier.station?.medicalConsumableStatus,
          options: OrderStatus.values,
          labelBuilder: (status) => status?.label,
          validator: (value) => Validators.cannotBlankValidator(value?.toString()),
          onChanged: notifier.updateConsumablesStatus,
        );
      },
    );
  }
}

class _ServiceField extends StatelessWidget {
  const _ServiceField();

  @override
  Widget build(BuildContext context) {
    return Consumer<StationFormNotifier>(
      builder: (context, notifier, _) {
        return DialogInputField<HospitalService>(
          key: key,
          label: 'Servis',
          initialValue: notifier.station?.service,
          labelBuilder: (value) => value?.name,
          onSelected: notifier.updateService,
          future: () => context.read<IServiceRepository>().getServices(),
          validator: (value) => Validators.cannotBlankValidator(value?.name),
        );
      },
    );
  }
}

// Hizmet verdiği servisler
class _ProvidedServices extends StatelessWidget {
  const _ProvidedServices();

  @override
  Widget build(BuildContext context) {
    return Consumer<StationFormNotifier>(
      builder: (context, notifier, _) {
        return MultiDialogInputField<HospitalService>(
          key: key,
          label: 'Hizmet Verdiği Servisler',
          initialValue: notifier.station?.services,
          labelBuilder: (value) => value?.name,
          onSelected: notifier.updateProvidedServices,
          future: () => context.read<IServiceRepository>().getServices(),
        );
      },
    );
  }
}
