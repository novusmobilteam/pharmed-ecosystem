// lib/features/unapplied_prescription_screen/unapplied_prescription_screen.dart
//
// [SWREQ-UI-UNAPP-VIEW-001]
// Sınıf : Class A
//
// Sol: PatientListPanel (hasta listesi)
// Sağ: HospitalizationDetailBanner + RxCarousel
//
// prescriptionItems notifier katmanında filtrelenmiştir (pendingPickup).
// View hiç filtre uygulamaz; RxCarousel'e direkt state.prescriptionItems geçilir.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/widgets/cabin_shell_widgets/selection/patient_selection/notifier/patient_selection_config.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../widgets/cabin_shell_widgets/selection/patient_selection/view/patient_selection_panel.dart';
import '../../../widgets/widgets.dart';

import '../unapplied_prescription.dart';

class UnappliedPrescriptionScreen extends ConsumerWidget {
  const UnappliedPrescriptionScreen({super.key, required this.menu, this.cabinData, this.deviceMode});

  final MenuItem menu;
  final CabinVisualizerData? cabinData;
  final CabinType? deviceMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cabinId = cabinData?.cabinId;

    if (cabinId == null) {
      return const EmptyStateWidget(variant: EmptyStateVariant.cabinData);
    }

    return _UnappliedPrescriptionBodyView(cabinId: cabinId, menu: menu);
  }
}

class _UnappliedPrescriptionBodyView extends ConsumerStatefulWidget {
  const _UnappliedPrescriptionBodyView({required this.cabinId, required this.menu});

  final int cabinId;
  final MenuItem menu;

  @override
  ConsumerState<_UnappliedPrescriptionBodyView> createState() => _UnappliedPrescriptionBodyViewState();
}

class _UnappliedPrescriptionBodyViewState extends ConsumerState<_UnappliedPrescriptionBodyView> {
  @override
  void initState() {
    super.initState();
    _initialize(widget.cabinId);
  }

  @override
  void didUpdateWidget(_UnappliedPrescriptionBodyView old) {
    super.didUpdateWidget(old);
    _initialize(widget.cabinId);
  }

  void _initialize(int cabinId) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(unappliedPrescriptionNotifierProvider.notifier).init(cabinId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(unappliedPrescriptionNotifierProvider);
    final notifier = ref.read(unappliedPrescriptionNotifierProvider.notifier);

    ref.listen(unappliedPrescriptionNotifierProvider, (_, next) {
      if (next is UnappliedPrescriptionError) {
        MessageUtils.showErrorSnackbar(context, next.message);
        notifier.dismissError();
      }
    });

    if (state is UnappliedPrescriptionUninitialized || state is UnappliedPrescriptionLoading) {
      return const Center(child: MedLoadingIndicator());
    }

    if (state.hospitalizations.isEmpty) {
      return EmptyStateWidget(
        icon: PhosphorIcons.usersThree(),
        size: EmptyStateSize.normal,
        title: context.l10n.prescription_noPatients_title,
        description: context.l10n.prescription_noPatients_message,
      );
    }

    return CabinOperationSelectionLayout(
      left: PatientSelectionPanel(
        selectedPatient: state.selectedPatient,
        onPatientSelected: (patient, tab, isOrderless) => notifier.onPatientTap(patient),
        config: PatientSelectionConfig(showFilters: false),
      ),
      right: _UnappliedPrescriptionRightPanel(state: state),
    );
  }
}

class _UnappliedPrescriptionRightPanel extends StatelessWidget {
  const _UnappliedPrescriptionRightPanel({required this.state});

  final UnappliedPrescriptionState state;

  @override
  Widget build(BuildContext context) {
    if (state.isPrescriptionsLoading) {
      return Center(child: MedLoadingIndicator());
    }

    if (!state.isPatientSelected) {
      return const EmptyStateWidget(variant: EmptyStateVariant.noPatientSelected);
    }

    if (state.prescriptionItems.isEmpty) {
      return EmptyStateWidget(
        icon: PhosphorIcons.receiptX(),
        title: context.l10n.unadministered_prescriptions_empty_title,
        description: context.l10n.unadministered_prescriptions_empty_description,
      );
    }

    return RxCarousel(items: state.prescriptionItems, emptyVariant: EmptyStateVariant.error);
  }
}
