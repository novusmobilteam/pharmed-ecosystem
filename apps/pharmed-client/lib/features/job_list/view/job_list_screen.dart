// lib/features/job_list/view/job_list_screen.dart
//
// [SWREQ-UI-JOBLIST-VIEW-001]
// Sınıf : Class A
//
// Sol : PatientListPanel — GetMyPatients'tan gelen hastalar, satır seçimi
// Sağ : RxCarousel        — seçili hastanın reçete/iş listesi

import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../widgets/widgets.dart';
import '../../dashboard/presentation/notifier/dashboard_notifier.dart';
import '../notifier/job_list_notifier.dart';

class JobListScreen extends StatelessWidget {
  const JobListScreen({super.key, required this.menu});

  final MenuItem menu;

  @override
  Widget build(BuildContext context) {
    final cabinId = context.watch<DashboardNotifier>().cabinVisualizerData?.cabinId;

    if (cabinId == null) {
      return const EmptyStateWidget(variant: EmptyStateVariant.cabinData);
    }

    return ChangeNotifierProvider<JobListNotifier>(
      create: (ctx) => JobListNotifier(getMyPatients: ctx.read(), getJobList: ctx.read())..init(cabinId),
      child: _JobListBodyView(cabinId: cabinId, menu: menu),
    );
  }
}

class _JobListBodyView extends StatefulWidget {
  const _JobListBodyView({required this.cabinId, required this.menu});

  final int cabinId;
  final MenuItem menu;

  @override
  State<_JobListBodyView> createState() => _JobListBodyViewState();
}

class _JobListBodyViewState extends State<_JobListBodyView> {
  @override
  void didUpdateWidget(_JobListBodyView old) {
    super.didUpdateWidget(old);
    if (widget.cabinId != old.cabinId) {
      context.read<JobListNotifier>().init(widget.cabinId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<JobListNotifier>();

    if (notifier.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        MessageUtils.showErrorSnackbar(context, notifier.errorMessage!);
        notifier.dismissError();
      });
    }

    if (notifier.isInitialLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    return CabinOperationSelectionLayout(
      leftWidth: 440,
      left: _PatientListPanel(notifier: notifier),
      right: _PrescriptionPanel(notifier: notifier),
    );
  }
}

class _PatientListPanel extends StatelessWidget {
  const _PatientListPanel({required this.notifier});

  final JobListNotifier notifier;

  List<Hospitalization> get _filtered {
    final q = notifier.search.toLowerCase();
    if (q.isEmpty) return notifier.allPatients;
    return notifier.allPatients.where((h) {
      final name = h.patient?.fullName.toLowerCase() ?? '';
      final room = h.bed?.room?.name?.toLowerCase() ?? h.room?.name?.toLowerCase() ?? '';
      return name.contains(q) || room.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final selectedId = notifier.selectedHospitalization?.id;
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
            initialValue: notifier.search,
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

                      return Center();

                      // return PatientSelectionCard(
                      //   hospitalization: h,
                      //   showChevron: false,
                      //   isSelected: isSelected,
                      //   onTap: () => notifier.selectPatient(h),
                      // );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _PrescriptionPanel extends StatelessWidget {
  const _PrescriptionPanel({required this.notifier});

  final JobListNotifier notifier;

  @override
  Widget build(BuildContext context) {
    if (notifier.selectedHospitalization == null) {
      return const EmptyStateWidget(variant: EmptyStateVariant.noPatientSelected);
    }

    if (notifier.isJobListLoading) {
      return Center(child: MedLoadingIndicator());
    }

    return RxCarousel(items: notifier.jobList, emptyVariant: EmptyStateVariant.noData);
  }
}
