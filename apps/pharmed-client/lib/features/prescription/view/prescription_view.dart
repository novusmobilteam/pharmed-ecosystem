// [SWREQ-UI-PRESC-VIEW-001]
// Sınıf : Class A
//
// Sol: PatientListPanel (hasta listesi)
// Sağ: HospitalizationDetailBanner + PrescriptionDetailCard carousel
//
// items prescriptionId'ye göre gruplandırılır;
// her grup bir PrescriptionDetailCard olarak render edilir.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../widgets/widgets.dart';
import '../../dashboard/presentation/notifier/dashboard_notifier.dart';
import '../../dashboard/presentation/notifier/dashboard_state.dart';
import '../notifier/prescription_notifier.dart';
import '../notifier/prescription_state.dart';

class PrescriptionView extends ConsumerWidget {
  const PrescriptionView({super.key, required this.menu});

  final MenuItem menu;

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

    return _PrescriptionBodyView(cabinId: cabinId, menu: menu);
  }
}

class _PrescriptionBodyView extends ConsumerStatefulWidget {
  const _PrescriptionBodyView({required this.cabinId, required this.menu});

  final int cabinId;
  final MenuItem menu;

  @override
  ConsumerState<_PrescriptionBodyView> createState() => _PrescriptionBodyViewState();
}

class _PrescriptionBodyViewState extends ConsumerState<_PrescriptionBodyView> {
  @override
  void initState() {
    super.initState();
    _initialize(widget.cabinId);
  }

  @override
  void didUpdateWidget(_PrescriptionBodyView old) {
    super.didUpdateWidget(old);
    if (widget.cabinId != old.cabinId) _initialize(widget.cabinId);
  }

  void _initialize(int cabinId) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(prescriptionNotifierProvider.notifier).init(cabinId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(prescriptionNotifierProvider);
    final notifier = ref.read(prescriptionNotifierProvider.notifier);

    ref.listen(prescriptionNotifierProvider, (_, next) {
      if (next is PrescriptionError) {
        MessageUtils.showErrorSnackbar(context, next.message);
        notifier.dismissError();
      }
    });

    if (state is PrescriptionUninitialized || state is PrescriptionLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    return TwoColumnLayout(
      menuItem: widget.menu,
      leftTitle: 'Hasta Listesi',
      leftSubtitle: 'Toplam ${state.patients.length} hasta',
      leftIcon: PhosphorIcons.users(),
      left: PatientListPanel(
        patients: state.patients,
        selectedPatient: state.selectedPatient,
        isPatientLoading: state.isPrescriptionsLoading,
        search: state.search,
        onPatientTap: notifier.onPatientTap,
        onSearchChanged: notifier.onSearchChanged,
        title: 'Hasta Listesi',
      ),
      right: _PrescriptionRightPanel(state: state),
    );
  }
}

class _PrescriptionRightPanel extends StatelessWidget {
  const _PrescriptionRightPanel({required this.state});

  final PrescriptionState state;

  @override
  Widget build(BuildContext context) {
    if (!state.isPatientSelected) {
      return const EmptyStateWidget(variant: EmptyStateVariant.error);
    }

    if (state.isPrescriptionsLoading) {
      return Center(child: MedLoadingIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(MedSpacing.xl),
      child: RxCarousel(items: state.prescriptionItems),
    );
  }
}
