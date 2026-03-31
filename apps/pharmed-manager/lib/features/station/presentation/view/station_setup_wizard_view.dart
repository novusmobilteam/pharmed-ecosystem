import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/core.dart';
import '../../../../core/widgets/form/form_inputs/base_display_field.dart';
import '../../../service/presentation/view/service_list_view.dart';

import 'package:provider/provider.dart';

import '../notifier/station_form_notifier.dart';
import '../../../warehouse/presentation/view/warehouse_list_view.dart';

class StationSetupWizardView extends StatefulWidget {
  const StationSetupWizardView({super.key});

  @override
  State<StationSetupWizardView> createState() => _StationSetupWizardViewState();
}

class _StationSetupWizardViewState extends State<StationSetupWizardView> {
  int _step = 0;

  // Adım doğrulama kontrolü
  bool _canContinue(StationFormNotifier notifier) {
    switch (_step) {
      case 0:
        // Depo ve durumların seçili olup olmadığını kontrol et
        return notifier.station?.materialWarehouse != null && notifier.station?.medicalConsumableWarehouse != null;
      case 1:
        // Servis seçili mi?
        return notifier.station?.service != null;
      case 2:
        // İstasyon adı girilmiş mi?
        return notifier.station?.name != null && notifier.station!.name!.isNotEmpty;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => StationFormNotifier(
        createStationUseCase: context.read(),
        updateStationUseCase: context.read(),
        getStationUseCase: context.read(),
      )..initialize(),
      child: Consumer<StationFormNotifier>(
        builder: (context, notifier, _) {
          return CustomDialog(
            maxHeight: context.height * 0.7,
            width: context.width * 0.5,
            title: 'İstasyon Kurulum Sihirbazı',
            child: Stepper(
              currentStep: _step,
              // Tıklanan adıma gitme (Sadece geri gitmeye veya geçerli adıma izin verir)
              onStepTapped: (index) {
                if (index < _step) {
                  setState(() => _step = index);
                }
              },
              onStepContinue: _canContinue(notifier) ? () => setState(() => _step < 2 ? _step++ : null) : null,
              onStepCancel: _step > 0 ? () => setState(() => _step--) : null,
              // Dil Desteği ve Buton Tasarımı
              controlsBuilder: (BuildContext context, ControlsDetails details) {
                final bool isLastStep = _step == 2;

                return Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(
                    children: [
                      ElevatedButton(
                        onPressed: _canContinue(notifier)
                            ? (isLastStep ? () => _finishSetup(context, notifier) : details.onStepContinue)
                            : null,
                        child: notifier.isLoading(notifier.submitOp)
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : Text(isLastStep ? 'Kurulumu Tamamla' : 'Devam Et'),
                      ),
                      if (_step > 0) ...[
                        const SizedBox(width: 12),
                        TextButton(onPressed: details.onStepCancel, child: const Text('Geri Dön')),
                      ],
                    ],
                  ),
                );
              },
              steps: [
                Step(
                  state: _step > 0 ? StepState.complete : StepState.indexed,
                  isActive: _step >= 0,
                  title: Text('Depo Tanımlama'),
                  content: _FirstStep(),
                ),
                Step(
                  state: _step > 1 ? StepState.complete : StepState.indexed,
                  isActive: _step >= 1,
                  title: Text('Servis Tanımlama'),
                  content: _SecondStep(),
                ),
                Step(
                  state: _step == 2 ? StepState.editing : StepState.indexed,
                  isActive: _step >= 2,
                  title: Text('İstasyon Tanımlama'),
                  content: _ThirdStep(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

Future<void> _finishSetup(BuildContext context, StationFormNotifier notifier) async {
  await notifier.submit();

  if (context.mounted && notifier.isSuccess(notifier.submitOp)) {
    MessageUtils.showSuccessSnackbar(context, notifier.statusMessage);
    context.pop(true);
  } else if (context.mounted && notifier.isFailed(notifier.submitOp)) {
    MessageUtils.showErrorDialog(context, notifier.statusMessage);
  }
}

// Depo Tanımlama
class _FirstStep extends StatelessWidget {
  const _FirstStep();

  @override
  Widget build(BuildContext context) {
    return Consumer<StationFormNotifier>(
      builder: (context, notifier, child) {
        return Column(
          spacing: AppDimensions.registrationDialogSpacing,
          children: [
            Row(
              spacing: AppDimensions.registrationDialogSpacing,
              children: [
                Expanded(
                  flex: 3,
                  child: BaseDisplayField(
                    label: 'İlaç Depo',
                    displayText: notifier.station?.materialWarehouse?.name ?? '',
                    onTap: () async {
                      final w = await showWarehouseListView(context);
                      notifier.updateMaterialWarehouse(w);
                    },
                  ),
                ),
                Expanded(
                  child: DropdownInputField<OrderStatus>(
                    label: 'İlaç Durumu',
                    options: OrderStatus.values,
                    initialValue: notifier.station?.drugStatus,
                    labelBuilder: (status) => status?.label,
                    validator: (value) => Validators.cannotBlankValidator(value?.toString()),
                    onChanged: notifier.updateDrugStatus,
                  ),
                ),
              ],
            ),
            Row(
              spacing: AppDimensions.registrationDialogSpacing,
              children: [
                Expanded(
                  flex: 3,
                  child: BaseDisplayField(
                    label: 'Tıbbi Sarf Depo',
                    displayText: notifier.station?.medicalConsumableWarehouse?.name ?? '',
                    onTap: () async {
                      final w = await showWarehouseListView(context);
                      notifier.updateConsumableWarehouse(w);
                    },
                  ),
                ),
                Expanded(
                  child: DropdownInputField<OrderStatus>(
                    label: 'Tıbbi Sarf Durumu',
                    options: OrderStatus.values,
                    initialValue: notifier.station?.medicalConsumableStatus,
                    labelBuilder: (status) => status?.label,
                    validator: (value) => Validators.cannotBlankValidator(value?.toString()),
                    onChanged: notifier.updateConsumablesStatus,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _SecondStep extends StatelessWidget {
  const _SecondStep();

  @override
  Widget build(BuildContext context) {
    return Consumer<StationFormNotifier>(
      builder: (context, notifier, _) {
        return BaseDisplayField(
          label: 'Servis',
          displayText: notifier.station?.service?.name ?? '',
          onTap: () async {
            final s = await showServiceListView(context);
            notifier.updateService(s);
          },
        );
      },
    );
  }
}

class _ThirdStep extends StatelessWidget {
  const _ThirdStep();

  @override
  Widget build(BuildContext context) {
    return Consumer<StationFormNotifier>(
      builder: (context, notifier, _) {
        return Column(
          spacing: AppDimensions.registrationDialogSpacing,
          children: [
            TextInputField(
              label: 'İstasyon Adı',
              initialValue: notifier.station?.name,
              onChanged: (String? value) => notifier.updateName(value),
            ),
            MultiDialogInputField<HospitalService>(
              key: key,
              label: 'Hizmet Verdiği Servisler',
              initialValue: notifier.station?.services,
              labelBuilder: (value) => value?.name,
              onSelected: notifier.updateProvidedServices,
              future: () => context.read<IServiceRepository>().getServices(),
            ),
          ],
        );
      },
    );
  }
}
