import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../widgets/widgets.dart';

import '../../dashboard/dashboard.dart';
import '../notifier/prescription_notifier.dart';
import '../notifier/prescription_state.dart';

class PrescriptionScreen extends ConsumerStatefulWidget {
  const PrescriptionScreen({super.key, required this.cabinRouteContext});

  final CabinRouteContext? cabinRouteContext;

  @override
  ConsumerState<PrescriptionScreen> createState() => PrescriptionScreenState();
}

class PrescriptionScreenState extends ConsumerState<PrescriptionScreen> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  void _initialize() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(prescriptionNotifierProvider.notifier).init();
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
      return Center(child: MedLoadingIndicator());
    }

    if (state.hospitalizations.isEmpty) {
      return EmptyStateWidget(
        icon: PhosphorIcons.usersThree(),
        size: EmptyStateSize.normal,
        title: context.l10n.prescription_noPatients_title,
        description: context.l10n.prescription_noPatients_message,
      );
    }

    return Row(
      spacing: 12.0,
      children: [
        Expanded(
          flex: 2,
          child: PatientSelectionPanel(
            currentStation: widget.cabinRouteContext!.station!,
            selectedPatient: state.selectedPatient,
            config: PatientSelectionConfig(showFilters: false),
            onPatientSelected: (Hospitalization patient, PatientSelectionTab tab, _) {
              notifier.onPatientTap(patient);
            },
          ),
        ),
        Expanded(flex: 7, child: _PrescriptionRightPanel(state: state)),
      ],
    );
  }
}

class _PrescriptionRightPanel extends StatelessWidget {
  const _PrescriptionRightPanel({required this.state});

  final PrescriptionState state;

  @override
  Widget build(BuildContext context) {
    if (state.isPrescriptionsLoading) {
      return Center(child: MedLoadingIndicator());
    }

    if (!state.isPatientSelected) {
      return const EmptyStateWidget(variant: EmptyStateVariant.noPatientSelected);
    }

    return RxCarousel(items: state.prescriptionItems, emptyVariant: EmptyStateVariant.noData);
  }
}
