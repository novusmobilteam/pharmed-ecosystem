// lib/features/unapplied_prescription_screen/unapplied_prescription_screen.dart
//
// [SWREQ-UI-UNAPP-VIEW-001]
// Sınıf : Class A
//
// Sol: PatientListPanel (hasta listesi)
// Sağ: HospitalizationDetailBanner + RxCarousel
//
// prescriptionItems notifier katmanında filtrelenmiştir (purchasePending).
// View hiç filtre uygulamaz.

import 'package:flutter/material.dart';
import 'package:pharmed_client/features/settings/notifier/settings_notifier.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../widgets/widgets.dart';
import '../../dashboard/presentation/notifier/dashboard_notifier.dart';
import '../unapplied_prescription.dart';

class UnappliedPrescriptionScreen extends StatelessWidget {
  const UnappliedPrescriptionScreen({super.key, required this.menu});

  final MenuItem menu;

  @override
  Widget build(BuildContext context) {
    final cabinId = context.watch<DashboardNotifier>().cabinVisualizerData?.cabinId;

    if (cabinId == null) {
      return const EmptyStateWidget(variant: EmptyStateVariant.cabinData);
    }

    return ChangeNotifierProvider<UnappliedPrescriptionNotifier>(
      create: (ctx) => UnappliedPrescriptionNotifier(
        getBedAssignments: ctx.read(),
        getHospitalizations: ctx.read(),
        getPrescriptionHistory: ctx.read(),
        getDeviceMode: ctx.read<SettingsNotifier>().getDeviceMode, // GEÇİCİ köprü
      )..init(cabinId),
      child: _UnappliedPrescriptionBodyView(cabinId: cabinId, menu: menu),
    );
  }
}

class _UnappliedPrescriptionBodyView extends StatefulWidget {
  const _UnappliedPrescriptionBodyView({required this.cabinId, required this.menu});

  final int cabinId;
  final MenuItem menu;

  @override
  State<_UnappliedPrescriptionBodyView> createState() => _UnappliedPrescriptionBodyViewState();
}

class _UnappliedPrescriptionBodyViewState extends State<_UnappliedPrescriptionBodyView> {
  @override
  void didUpdateWidget(_UnappliedPrescriptionBodyView old) {
    super.didUpdateWidget(old);
    if (widget.cabinId != old.cabinId) {
      context.read<UnappliedPrescriptionNotifier>().init(widget.cabinId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<UnappliedPrescriptionNotifier>();

    if (notifier.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        MessageUtils.showErrorSnackbar(context, notifier.errorMessage!);
        notifier.dismissError();
      });
    }

    if (notifier.isInitialLoading) {
      return const Center(child: MedLoadingIndicator());
    }

    if (notifier.hospitalizations.isEmpty) {
      return EmptyStateWidget(
        icon: PhosphorIcons.usersThree(),
        size: EmptyStateSize.normal,
        title: context.l10n.prescription_noPatients_title,
        description: context.l10n.prescription_noPatients_message,
      );
    }

    return CabinOperationSelectionLayout(
      left: SizedBox(),
      // left: PatientSelectionGuide(
      //   patients: notifier.hospitalizations,
      //   selectedPatient: notifier.selectedPatient,
      //   isPatientLoading: notifier.isPrescriptionsLoading,
      //   search: notifier.search,
      //   onPatientTap: notifier.onPatientTap,
      //   onSearchChanged: notifier.onSearchChanged,
      //   title: context.l10n.unappliedPrescription_panel_patientTitle,
      // ),
      right: _UnappliedPrescriptionRightPanel(notifier: notifier),
    );
  }
}

class _UnappliedPrescriptionRightPanel extends StatelessWidget {
  const _UnappliedPrescriptionRightPanel({required this.notifier});

  final UnappliedPrescriptionNotifier notifier;

  @override
  Widget build(BuildContext context) {
    if (notifier.isPrescriptionsLoading) {
      return Center(child: MedLoadingIndicator());
    }

    if (!notifier.isPatientSelected) {
      return const EmptyStateWidget(variant: EmptyStateVariant.noPatientSelected);
    }

    if (notifier.prescriptionItems.isEmpty) {
      return EmptyStateWidget(
        icon: PhosphorIcons.receiptX(),
        title: context.l10n.unadministered_prescriptions_empty_title,
        description: context.l10n.unadministered_prescriptions_empty_description,
      );
    }

    return RxCarousel(items: notifier.prescriptionItems, emptyVariant: EmptyStateVariant.error);
  }
}
