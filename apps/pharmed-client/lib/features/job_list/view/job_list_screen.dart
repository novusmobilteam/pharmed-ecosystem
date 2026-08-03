// lib/features/job_list/view/job_list_screen.dart
//
// [SWREQ-UI-JOBLIST-VIEW-001]
// Sınıf : Class A
//
// Sol : PatientListPanel — GetMyPatients'tan gelen hastalar, satır seçimi
// Sağ : RxCarousel        — seçili hastanın reçete/iş listesi
//
// AllPatientsPanel'in aksine burada + / — butonu yok; satıra tıklamak
// doğrudan seçim demek (radio-button gibi), sağ panel o hastaya göre yenilenir.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../widgets/widgets.dart';
import '../../dashboard/presentation/notifier/dashboard_notifier.dart';
import '../../dashboard/presentation/notifier/dashboard_state.dart';
import '../notifier/job_list_notifier.dart';
import '../notifier/job_list_state.dart';

class JobListScreen extends ConsumerWidget {
  const JobListScreen({super.key, required this.menu});

  final MenuItem menu;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cabinId = ref.watch(
      dashboardNotifierProvider.select(
        (s) => switch (s) {
          DashboardLoaded(:final data) => data.cabinVisualizerData?.cabinId,
          _ => null,
        },
      ),
    );

    if (cabinId == null) {
      return const EmptyStateWidget(variant: EmptyStateVariant.cabinData);
    }

    return _JobListBodyView(cabinId: cabinId, menu: menu);
  }
}

class _JobListBodyView extends ConsumerStatefulWidget {
  const _JobListBodyView({required this.cabinId, required this.menu});

  final int cabinId;
  final MenuItem menu;

  @override
  ConsumerState<_JobListBodyView> createState() => _JobListBodyViewState();
}

class _JobListBodyViewState extends ConsumerState<_JobListBodyView> {
  @override
  void initState() {
    super.initState();
    _initialize(widget.cabinId);
  }

  @override
  void didUpdateWidget(_JobListBodyView old) {
    super.didUpdateWidget(old);
    _initialize(widget.cabinId);
  }

  void _initialize(int cabinId) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(jobListNotifierProvider.notifier).init(cabinId);
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
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    return CabinOperationSelectionLayout(
      leftWidth: 440,
      left: _PatientListPanel(state: state, notifier: notifier),
      right: _PrescriptionPanel(state: state),
    );
  }
}

class _PatientListPanel extends StatelessWidget {
  const _PatientListPanel({required this.state, required this.notifier});

  final JobListState state;
  final JobListNotifier notifier;

  List<Hospitalization> get _filtered {
    final q = state.search.toLowerCase();
    if (q.isEmpty) return state.allPatients;
    return state.allPatients.where((h) {
      final name = h.patient?.fullName.toLowerCase() ?? '';
      final room = h.bed?.room?.name?.toLowerCase() ?? h.room?.name?.toLowerCase() ?? '';
      return name.contains(q) || room.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final selectedId = state.selectedHospitalization?.id;
    final filtered = _filtered;

    return Container(
      padding: MedSpacing.panelInsetPadding,
      decoration: MedDecoration.panelDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MedTextInputField(
            hintText: context.l10n.myPatients_search_hint,
            prefixIcon: Icon(PhosphorIcons.magnifyingGlass()),
            initialValue: state.search,
            onChanged: (q) => notifier.onSearchChanged(q ?? ''),
          ),
          SizedBox(height: MedSpacing.sm),
          Expanded(
            child: filtered.isEmpty
                ? const EmptyStateWidget(variant: EmptyStateVariant.noResults)
                : ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: MedSpacing.sm),
                    itemBuilder: (context, index) {
                      final h = filtered[index];
                      final hospId = h.id;
                      final isSelected = hospId != null && hospId == selectedId;
                      //final isRowLoading = isSelected && state.isPrescriptionItemsLoading;

                      return PatientSelectionCard(
                        hospitalization: h,
                        showChevron: false,
                        isSelected: isSelected,
                        //trailing: isRowLoading ? const Center(child: MedLoadingIndicator()) : null,
                        onTap: () => notifier.selectPatient(h),
                        // onTap: (hospId == null || isSelected) ? null : () => notifier.selectPatient(h),
                      );
                    },
                  ),
          ),
        ],
      ),
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
