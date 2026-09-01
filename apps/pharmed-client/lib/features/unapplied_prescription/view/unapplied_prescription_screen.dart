import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../widgets/widgets.dart';

import '../../dashboard/dashboard.dart';
import '../unapplied_prescription.dart';

class UnappliedPrescriptionScreen extends ConsumerStatefulWidget {
  const UnappliedPrescriptionScreen({super.key, this.cabinRouteContext});

  final CabinRouteContext? cabinRouteContext;

  @override
  ConsumerState<UnappliedPrescriptionScreen> createState() => UnappliedPrescriptionScreenState();
}

class UnappliedPrescriptionScreenState extends ConsumerState<UnappliedPrescriptionScreen> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  void _initialize() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final deviceMode = widget.cabinRouteContext?.deviceMode;
      ref.read(unappliedPrescriptionNotifierProvider.notifier).init(deviceMode);
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

    return Row(
      spacing: 12.0,
      children: [
        Expanded(
          flex: 2,
          child: PatientSelectionPanel(
            currentStation: widget.cabinRouteContext!.station!,
            selectedPatient: state.selectedPatient,
            onPatientSelected: (patient, tab, isOrderless) => notifier.onPatientTap(patient),
            config: PatientSelectionConfig(showFilters: false),
          ),
        ),
        Expanded(flex: 7, child: _UnappliedPrescriptionRightPanel(state: state)),
      ],
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
        title: context.l10n.prescription_unadministeredEmptyTitle,
        description: context.l10n.prescription_unadministeredEmptyDescription,
      );
    }

    return RxCarousel(items: state.prescriptionItems, emptyVariant: EmptyStateVariant.error);
  }
}
