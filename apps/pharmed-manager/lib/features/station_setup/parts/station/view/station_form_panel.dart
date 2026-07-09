import 'package:flutter/material.dart';
import 'package:pharmed_manager/features/station_setup/notifier/station_setup_notifier.dart';
import 'package:provider/provider.dart';

import '../../../../../core/core.dart';
import '../../../../../../widgets/side_panel.dart';
import '../notifier/station_form_notifier.dart';
import '../notifier/station_notifier.dart';

class StationFormPanel extends StatelessWidget {
  const StationFormPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final setupNotifier = context.watch<StationSetupNotifier>();
    final formKey = GlobalKey<FormState>();
    final isNew = setupNotifier.selectedStation == null;

    return ChangeNotifierProvider(
      key: ValueKey(setupNotifier.selectedStation?.id ?? 'new'),
      create: (BuildContext context) => StationFormNotifier(
        station: setupNotifier.selectedStation,
        createStationUseCase: context.read(),
        updateStationUseCase: context.read(),
        getStationUseCase: context.read(),
      )..initialize(station: setupNotifier.selectedStation),
      child: Consumer<StationFormNotifier>(
        builder: (context, formNotifier, _) {
          return SidePanel(
            title: isNew ? context.l10n.stationSetup_station_formTitleNew : context.l10n.stationSetup_station_formTitleEdit,
            subtitle: isNew
                ? context.l10n.stationSetup_station_formSubtitleNew
                : context.l10n.stationSetup_station_formSubtitleEdit,
            isLoading: formNotifier.isSubmitting,
            onClose: setupNotifier.closePanel,
            onSave: () async {
              if (formKey.currentState!.validate()) {
                final wasCreate = formNotifier.isCreate;
                await formNotifier.submit();

                if (context.mounted && formNotifier.isSuccess(formNotifier.submitOp)) {
                  MessageUtils.showSuccessSnackbar(
                    context,
                    wasCreate
                        ? context.l10n.stationSetup_station_createdSuccessMessage
                        : context.l10n.stationSetup_station_updatedSuccessMessage,
                  );
                  context.read<StationSetupNotifier>().closePanel();
                  context.read<StationNotifier>().fetch();
                } else if (context.mounted && formNotifier.isFailed(formNotifier.submitOp)) {
                  MessageUtils.showErrorDialog(context, formNotifier.statusMessage);
                }
              }
            },

            child: formNotifier.isFetching
                ? const Center(child: CircularProgressIndicator.adaptive())
                : _buildForm(formKey),
          );
        },
      ),
    );
  }

  Form _buildForm(GlobalKey<FormState> formKey) {
    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: AppDimensions.registrationDialogSpacing,
        children: [
          _NameField(),
          Row(
            spacing: AppDimensions.registrationDialogSpacing,
            children: [
              Expanded(flex: 2, child: _MaterialWarehouseField()),
              Expanded(child: _DrugStatusField()),
            ],
          ),
          Row(
            spacing: AppDimensions.registrationDialogSpacing,
            children: [
              Expanded(flex: 2, child: _ConsumableWarehouseField()),
              Expanded(child: _ConsumablesStatusField()),
            ],
          ),
          _ServiceField(),
          _ProvidedServices(),
          _StationTypeField(),
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
        return MedTextInputField(
          label: context.l10n.stationSetup_station_nameLabel,
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
        return MedSelectionField<Warehouse>(
          label: context.l10n.stationSetup_station_drugWarehouseLabel,
          title: context.l10n.stationSetup_station_drugWarehouseSelectTitle,
          initialValue: notifier.station?.materialWarehouse,
          dataSource: (skip, take, search) =>
              context.read<GetWarehousesUseCase>().call(PagedQueryParams(skip: skip, take: take, searchQuery: search)),
          labelBuilder: (w) => w.name ?? '—',
          onSelected: notifier.updateMaterialWarehouse,
          validator: (value) => Validators.cannotBlankValidator(value?.toString()),
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
        return MedDropdownInputField<OrderStatus>(
          label: context.l10n.stationSetup_station_drugStatusLabel,
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
        return MedSelectionField<Warehouse>(
          label: context.l10n.stationSetup_station_consumableWarehouseLabel,
          title: context.l10n.stationSetup_station_consumableWarehouseSelectTitle,
          initialValue: notifier.station?.medicalConsumableWarehouse,
          labelBuilder: (w) => w.name ?? '—',
          validator: (value) => Validators.cannotBlankValidator(value?.toString()),
          onSelected: notifier.updateConsumableWarehouse,
          dataSource: (skip, take, search) =>
              context.read<GetWarehousesUseCase>().call(PagedQueryParams(skip: skip, take: take, searchQuery: search)),
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
        return MedDropdownInputField<OrderStatus>(
          label: context.l10n.authorization_tabConsumableLabel,
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
        return MedSelectionField<HospitalService>(
          key: key,
          label: context.l10n.stationSetup_station_serviceLabel,
          title: context.l10n.stationSetup_station_serviceSelectTitle,
          initialValue: notifier.station?.service,
          labelBuilder: (value) => value.name ?? '-',
          onSelected: notifier.updateService,
          dataSource: (skip, take, search) =>
              context.read<GetServicesUseCase>().call(PagedQueryParams(skip: skip, take: take, searchQuery: search)),
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
        return MedMultiSelectionField<HospitalService>(
          label: context.l10n.stationSetup_station_providedServicesLabel,
          title: context.l10n.stationSetup_station_serviceSelectTitle,
          initialValue: notifier.station?.services,
          dataSource: (skip, take, search) =>
              context.read<GetServicesUseCase>().call(PagedQueryParams(skip: skip, take: take, searchQuery: search)),
          labelBuilder: (s) => s.name ?? '—',
          onSelected: notifier.updateProvidedServices,
        );
      },
    );
  }
}

class _StationTypeField extends StatelessWidget {
  const _StationTypeField();

  @override
  Widget build(BuildContext context) {
    return Consumer<StationFormNotifier>(
      builder: (context, notifier, _) {
        return MedRadioInputField<StationType>(
          label: context.l10n.stationSetup_station_typeLabel,
          initialValue: notifier.station?.type,
          options: [
            MedRadioOption(
              value: StationType.patientBased,
              label: context.l10n.stationSetup_station_typePatientBasedLabel,
            ),
            MedRadioOption(
              value: StationType.medicineBased,
              label: context.l10n.stationSetup_station_typeMedicineBasedLabel,
            ),
          ],
          onChanged: notifier.updateType,
        );
      },
    );
  }
}
