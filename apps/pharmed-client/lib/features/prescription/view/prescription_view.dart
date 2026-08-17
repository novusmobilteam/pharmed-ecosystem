// [SWREQ-UI-PRESC-VIEW-001]
// Sınıf : Class A
//
// Sol: PatientListPanel (hasta listesi)
// Sağ: HospitalizationDetailBanner + PrescriptionDetailCard carousel

import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../widgets/widgets.dart';
import '../../dashboard/presentation/notifier/dashboard_notifier.dart';
import '../../settings/notifier/settings_notifier.dart';
import '../notifier/prescription_notifier.dart';

class PrescriptionView extends StatelessWidget {
  const PrescriptionView({super.key, required this.menu});

  final MenuItem menu;

  @override
  Widget build(BuildContext context) {
    final cabinId = context.watch<DashboardNotifier>().cabinVisualizerData?.cabinId;

    if (cabinId == null) {
      return const EmptyStateWidget(variant: EmptyStateVariant.cabinData);
    }

    return ChangeNotifierProvider<PrescriptionNotifier>(
      create: (ctx) => PrescriptionNotifier(
        getBedAssignments: ctx.read(),
        getHospitalizations: ctx.read(),
        getPrescriptionHistory: ctx.read(),
        getDeviceMode: ctx.read<SettingsNotifier>().getDeviceMode,
      )..init(cabinId),
      child: _PrescriptionBodyView(cabinId: cabinId, menu: menu),
    );
  }
}

class _PrescriptionBodyView extends StatefulWidget {
  const _PrescriptionBodyView({required this.cabinId, required this.menu});

  final int cabinId;
  final MenuItem menu;

  @override
  State<_PrescriptionBodyView> createState() => _PrescriptionBodyViewState();
}

class _PrescriptionBodyViewState extends State<_PrescriptionBodyView> {
  @override
  void didUpdateWidget(_PrescriptionBodyView old) {
    super.didUpdateWidget(old);
    if (widget.cabinId != old.cabinId) {
      context.read<PrescriptionNotifier>().init(widget.cabinId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<PrescriptionNotifier>();

    if (notifier.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        MessageUtils.showErrorSnackbar(context, notifier.errorMessage!);
        notifier.dismissError();
      });
    }

    if (notifier.isInitialLoading) {
      return Center(child: MedLoadingIndicator());
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
      //   title: context.l10n.common_patientListTitle,
      // ),
      right: _PrescriptionRightPanel(notifier: notifier),
    );
  }
}

class _PrescriptionRightPanel extends StatelessWidget {
  const _PrescriptionRightPanel({required this.notifier});

  final PrescriptionNotifier notifier;

  @override
  Widget build(BuildContext context) {
    if (notifier.isPrescriptionsLoading) {
      return Center(child: MedLoadingIndicator());
    }

    if (!notifier.isPatientSelected) {
      return const EmptyStateWidget(variant: EmptyStateVariant.noPatientSelected);
    }

    return Padding(
      padding: const EdgeInsets.all(MedSpacing.xl),
      child: RxCarousel(items: notifier.prescriptionItems),
    );
  }
}
