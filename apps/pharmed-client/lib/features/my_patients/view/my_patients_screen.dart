import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../widgets/widgets.dart';

import '../../dashboard/dashboard.dart';
import '../notifier/my_patients_notifier.dart';
import '../notifier/my_patients_state.dart';

class MyPatientsScreen extends ConsumerStatefulWidget {
  const MyPatientsScreen({super.key, this.cabinRouteContext});

  final CabinRouteContext? cabinRouteContext;

  @override
  ConsumerState<MyPatientsScreen> createState() => MyPatientsScreenState();
}

class MyPatientsScreenState extends ConsumerState<MyPatientsScreen> {
  @override
  void initState() {
    super.initState();
    _initialize(widget.cabinRouteContext);
  }

  void _initialize(CabinRouteContext? cabinRouteContext) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(myPatientsNotifierProvider.notifier).init(cabinRouteContext);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(myPatientsNotifierProvider);
    final notifier = ref.read(myPatientsNotifierProvider.notifier);

    ref.listen(myPatientsNotifierProvider, (_, next) {
      if (next is MyPatientsError) {
        MessageUtils.showErrorSnackbar(context, next.message);
        notifier.dismissError();
      }
    });

    if (state is MyPatientsUninitialized || state is MyPatientsLoading) {
      return const Center(child: MedLoadingIndicator());
    }

    return Row(
      spacing: 12.0,
      children: [
        Expanded(
          flex: 2,
          child: _AllPatientsPanel(state: state, notifier: notifier),
        ),
        Expanded(
          flex: 7,
          child: _MyPatientsPanel(state: state, notifier: notifier),
        ),
      ],
    );
  }
}

class _AllPatientsPanel extends StatelessWidget {
  const _AllPatientsPanel({required this.state, required this.notifier});

  final MyPatientsState state;
  final MyPatientsNotifier notifier;

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
    final myIds = state.myPatientHospitalizationIds;
    final filtered = _filtered;

    return Container(
      padding: MedSpacing.panelInsetPadding,
      decoration: MedDecoration.panelDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Arama
          CabinOperationSearchField(
            onChanged: notifier.onSearchChanged,
            hintText: context.l10n.patientPicker_searchHint,
          ),

          SizedBox(height: MedSpacing.sm),

          // Liste
          Expanded(
            child: filtered.isEmpty
                ? const EmptyStateWidget(variant: EmptyStateVariant.noResults)
                : ListView.separated(
                    //padding: const EdgeInsets.symmetric(horizontal: MedSpacing.xl, vertical: MedSpacing.md),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: MedSpacing.sm),
                    itemBuilder: (context, index) {
                      final h = filtered[index];
                      final hospId = h.id;
                      final isAlreadyMine = hospId != null && myIds.contains(hospId);
                      final isPending = hospId != null && state.isPending(hospId);

                      return Opacity(
                        opacity: isAlreadyMine ? 0.4 : 1.0,
                        child: PatientSelectionCard(
                          hospitalization: h,
                          onTap: () {},
                          showChevron: false,
                          trailing: isPending ? const Center(child: MedLoadingIndicator()) : null,
                          onAdd: (!isAlreadyMine && !isPending) ? () => notifier.addPatient(h) : null,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _MyPatientsPanel extends StatelessWidget {
  const _MyPatientsPanel({required this.state, required this.notifier});

  final MyPatientsState state;
  final MyPatientsNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final myPatients = state.myPatients;

    if (myPatients.isEmpty) {
      return Center(child: EmptyStateWidget(variant: EmptyStateVariant.noData));
    }
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisExtent: 150,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: myPatients.length,
      itemBuilder: (BuildContext context, int index) {
        final mp = myPatients[index];
        final h = mp.hospitalization;
        final hospId = h?.id;
        final isPending = hospId != null && state.isPending(hospId);
        return PatientSelectionCard(
          hospitalization: h ?? Hospitalization(),
          onTap: () {},
          showChevron: false,
          trailing: isPending ? const Center(child: MedLoadingIndicator()) : null,
          onRemove: isPending ? null : () => notifier.removePatient(mp),
        );
      },
    );
  }
}
