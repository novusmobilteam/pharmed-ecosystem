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
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../widgets/widgets.dart';
import '../../dashboard/presentation/notifier/dashboard_notifier.dart';
import '../../dashboard/presentation/notifier/dashboard_state.dart';
import '../unapplied_prescription.dart';

class UnappliedPrescriptionScreen extends ConsumerWidget {
  const UnappliedPrescriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cabinId = ref.watch(
      dashboardNotifierProvider.select(
        (s) => switch (s) {
          DashboardLoaded(:final data) => data.cabinVisualizerData?.cabinId,
          DashboardStale(:final data) => data.cabinVisualizerData?.cabinId,
          DashboardPartial(:final data) => data.cabinVisualizerData?.cabinId,
          _ => null,
        },
      ),
    );

    if (cabinId == null) {
      return const EmptyStateWidget(variant: EmptyStateVariant.cabinData);
    }

    return _UnappliedPrescriptionBodyView(cabinId: cabinId);
  }
}

class _UnappliedPrescriptionBodyView extends ConsumerStatefulWidget {
  const _UnappliedPrescriptionBodyView({required this.cabinId});

  final int cabinId;

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
    if (widget.cabinId != old.cabinId) _initialize(widget.cabinId);
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
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    return Row(
      children: [
        SizedBox(
          width: 380,
          child: PatientListPanel(
            patients: state.patients,
            selectedPatient: state.selectedPatient,
            isPatientLoading: state.isPrescriptionsLoading,
            search: state.search,
            onPatientTap: notifier.onPatientTap,
            onSearchChanged: notifier.onSearchChanged,
            title: 'Hastalar',
          ),
        ),
        VerticalDivider(width: 1, thickness: 1, color: MedColors.border),
        Expanded(child: _UnappliedPrescriptionRightPanel(state: state)),
      ],
    );
  }
}

class _UnappliedPrescriptionRightPanel extends StatelessWidget {
  const _UnappliedPrescriptionRightPanel({required this.state});

  final UnappliedPrescriptionState state;

  @override
  Widget build(BuildContext context) {
    if (!state.isPatientSelected) {
      return const EmptyStateWidget(variant: EmptyStateVariant.error);
    }

    if (state.isPrescriptionsLoading) {
      return Column(
        children: [
          HospitalizationDetailBanner(hospitalization: state.selectedPatient),
          const Expanded(child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
        ],
      );
    }

    return Column(
      children: [
        HospitalizationDetailBanner(hospitalization: state.selectedPatient),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(MedSpacing.xl),
            child: RxCarousel(items: state.prescriptionItems, emptyVariant: EmptyStateVariant.error),
          ),
        ),
      ],
    );
  }
}
