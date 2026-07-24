// widgets/cabin_shell_widgets/patient_selection/patient_selection_panel.dart
//
// Master kabin işlemlerinde (alım, iade, fire/imha) ORTAK sol panel: hasta
// listesi + arama + filtre + acil hasta oluşturma. PatientSelectionNotifier'ı
// (ortak, ekrandan bağımsız) PatientSelectionGuide'ın (saf sunum) slotlarına
// bağlar.
//
// Seçili hasta / kilit durumu DIŞARIDAN verilir — bu widget hangi akışta
// (intake/iade/fire-imha) olduğunu bilmez, yalnızca listeyi yönetir.
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../cabin_shell_widgets.dart';

class PatientSelectionPanel extends ConsumerStatefulWidget {
  const PatientSelectionPanel({
    super.key,
    required this.onPatientSelected,
    required this.selectedPatient,
    this.isLocked = false,
  });

  /// Hasta seçildiğinde (veya acil hasta oluşturulduğunda) tetiklenir.
  /// Akış türü (IntakeType/ReturnType vb.) çağıranın kararıdır — bu widget
  /// bilmez, sadece o anki order modunu (isOrderless) bildirir.
  final void Function(Hospitalization hospitalization, bool isOrderless) onPatientSelected;

  /// Aktif akışın hastası (vurgulu satır için) — çağıranın kendi state'inden gelir.
  final Hospitalization? selectedPatient;

  /// true iken liste tamamen etkileşimsiz (execution fazı gibi).
  final bool isLocked;

  @override
  ConsumerState<PatientSelectionPanel> createState() => _PatientSelectionPanelState();
}

class _PatientSelectionPanelState extends ConsumerState<PatientSelectionPanel> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(patientSelectionNotifierProvider.notifier).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(patientSelectionNotifierProvider);
    final notifier = ref.read(patientSelectionNotifierProvider.notifier);

    ref.listen(patientSelectionNotifierProvider, (_, next) {
      if (next is PatientSelectionError) {
        MessageUtils.showErrorSnackbar(context, next.message);
        notifier.dismissError();
      }
    });

    final ready = switch (state) {
      PatientSelectionReady r => r,
      PatientSelectionError(previousState: PatientSelectionReady r) => r,
      _ => null,
    };

    // MasterCabinRootScaffold'un extraBootGate mekanizması bu widget'ı hazır
    // olana kadar Offstage ile mount tutuyor — buraya normalde düşülmemeli.
    if (ready == null) return const SizedBox.shrink();

    return PatientSelectionGuide(
      patients: ready.visiblePatients,
      selectedPatient: widget.selectedPatient,
      // Liste yeniden çekilirken (toggle/filtre) satır seçimi değil, tüm
      // panel hafifçe kilitlenir — bkz. isLocked altında ready.isFetching.
      isPatientLoading: false,
      search: ready.search,
      onSearchChanged: notifier.onSearchChanged,
      onPatientTap: (h) => widget.onPatientSelected(h, ready.isOrderless),
      isLocked: widget.isLocked || ready.isFetching,
      //title: context.l10n.patientSelectionGuide_title,
      filterFields: [
        SegmentedFilterField<PatientViewType>(
          key: 'viewType',
          label: context.l10n.patientListPanel_filter_patientStatusLabel,
          initialValue: ready.viewType,
          options: PatientViewType.values,
          labelBuilder: (p) => p == PatientViewType.allPatients
              ? context.l10n.enumCore_patientFilterAll
              : context.l10n.patientPicker_myPatientsToggleLabel,
          defaultValue: PatientViewType.allPatients,
        ),
        if (ready.isStatusButtonVisible)
          ToggleFilterField(
            key: 'isOrdered',
            label: context.l10n.patientListPanel_filter_orderStatusLabel,
            initialValue: ready.viewOrderStatus.isOrdered,
            trueLabel: context.l10n.patientPicker_orderedToggleLabel,
            falseLabel: context.l10n.patientPicker_orderlessToggleLabel,
            defaultValue: true,
          ),
        DropdownFilterField<HospitalService?>(
          key: 'service',
          label: context.l10n.assignment_serviceLabel,
          initialValue: ready.selectedService,
          options: [null, ...ready.availableServices],
          labelBuilder: (s) => s?.name ?? context.l10n.filter_all,
          defaultValue: null,
        ),
        DropdownFilterField<PatientFilterType>(
          key: 'filter',
          label: context.l10n.prescriptionDetailStatusLabel,
          initialValue: ready.filter,
          options: PatientFilterType.values,
          labelBuilder: (f) => f?.label,
          defaultValue: PatientFilterType.all,
        ),
      ],
      onFilterApply: (result) {
        if (result['viewType'] != ready.viewType) notifier.togglePatientView();
        if (result['service'] != ready.selectedService) {
          notifier.toggleService(result['service'] as HospitalService?);
        }
        if (result.containsKey('isOrdered') && result['isOrdered'] != ready.viewOrderStatus.isOrdered) {
          notifier.toggleOrderlessStatus();
        }
        if (result['filter'] != ready.filter) {
          notifier.changeFilter(result['filter'] as PatientFilterType);
        }
      },
      footer: ready.isUrgentPatientButtonVisible
          ? _UrgentPatientFooter(state: ready, notifier: notifier, onCreated: (h) => widget.onPatientSelected(h, true))
          : null,
    );
  }
}

class _UrgentPatientFooter extends StatelessWidget {
  const _UrgentPatientFooter({required this.state, required this.notifier, required this.onCreated});

  final PatientSelectionReady state;
  final PatientSelectionNotifier notifier;
  final ValueChanged<Hospitalization> onCreated;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: MedButton(
        label: context.l10n.patientPicker_createUrgentPatientButton,
        size: MedButtonSize.sm,
        variant: MedButtonVariant.danger,
        prefixIcon: Icon(PhosphorIconsBold.plus),
        isLoading: state.isCreatingUrgent,
        onPressed: () => notifier.createUrgentPatient(
          onSuccess: (h) {
            MessageUtils.showSuccessSnackbar(context, context.l10n.patientPicker_urgentPatientCreatedMessage);
            onCreated(h);
          },
          onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
        ),
      ),
    );
  }
}
