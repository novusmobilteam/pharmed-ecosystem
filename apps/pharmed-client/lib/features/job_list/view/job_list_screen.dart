import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../widgets/widgets.dart';
import '../../dashboard/dashboard.dart';
import '../notifier/job_list_notifier.dart';
import '../notifier/job_list_state.dart';

class JobListScreen extends ConsumerStatefulWidget {
  const JobListScreen({super.key, this.cabinRouteContext});

  final CabinRouteContext? cabinRouteContext;

  @override
  ConsumerState<JobListScreen> createState() => JobListScreenState();
}

class JobListScreenState extends ConsumerState<JobListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      ref.read(jobListNotifierProvider.notifier).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(jobListNotifierProvider);
    final notifier = ref.read(jobListNotifierProvider.notifier);

    ref.listen(jobListNotifierProvider, (_, next) {
      if (next is JobListError) {
        MessageUtils.showErrorSnackbar(context, next.message);
        notifier.dismissError();
      }
    });

    if (state is JobListUninitialized || state is JobListLoading) {
      return const Center(child: MedLoadingIndicator());
    }

    return Row(
      spacing: 12.0,
      children: [
        Expanded(
          flex: 2,
          child: PatientSelectionGuide(
            selectedPatient: state.selectedHospitalization,
            patients: state.allPatients,
            isPatientLoading: state.isJobListLoading,
            search: '',
            onPatientTap: (Hospitalization hospitalization) => notifier.selectPatient(hospitalization),
            onSearchChanged: (String value) => notifier.onSearchChanged(value),
          ),
        ),

        Expanded(flex: 7, child: _PrescriptionPanel(state: state)),
      ],
    );
  }
}

class _PrescriptionPanel extends StatelessWidget {
  const _PrescriptionPanel({required this.state});

  final JobListState state;

  @override
  Widget build(BuildContext context) {
    if (state.selectedHospitalization == null) {
      return EmptyStateWidget(variant: EmptyStateVariant.noPatientSelected);
    }

    if (state.isJobListLoading) {
      return Center(child: MedLoadingIndicator());
    }

    return RxCarousel(items: state.jobList, emptyVariant: EmptyStateVariant.noData);
  }
}
