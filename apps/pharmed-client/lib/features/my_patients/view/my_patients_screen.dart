// lib/features/my_patients/view/my_patients_screen.dart
//
// [SWREQ-UI-MYPATIENTS-VIEW-001]
// Sınıf : Class A
//
// Sol : AllPatientsPanel  — kabindeki tüm hastalar, + butonu
// Sağ : MyPatientsPanel   — benim hastalarım, — butonu
//
// Sağ listede olan bir hasta sol listede Opacity(0.4) + onAdd:null ile
// pasif gösterilir; tıklanamaz.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../widgets/widgets.dart';
import '../../dashboard/presentation/notifier/dashboard_notifier.dart';
import '../../dashboard/presentation/notifier/dashboard_state.dart';
import '../notifier/my_patients_notifier.dart';
import '../notifier/my_patients_state.dart';

class MyPatientsScreen extends ConsumerWidget {
  const MyPatientsScreen({super.key, required this.menu});

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

    return _MyPatientsBodyView(cabinId: cabinId, menu: menu);
  }
}

class _MyPatientsBodyView extends ConsumerStatefulWidget {
  const _MyPatientsBodyView({required this.cabinId, required this.menu});

  final int cabinId;
  final MenuItem menu;

  @override
  ConsumerState<_MyPatientsBodyView> createState() => _MyPatientsBodyViewState();
}

class _MyPatientsBodyViewState extends ConsumerState<_MyPatientsBodyView> {
  @override
  void initState() {
    super.initState();
    _initialize(widget.cabinId);
  }

  @override
  void didUpdateWidget(_MyPatientsBodyView old) {
    super.didUpdateWidget(old);
    if (widget.cabinId != old.cabinId) _initialize(widget.cabinId);
  }

  void _initialize(int cabinId) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(myPatientsNotifierProvider.notifier).init(cabinId);
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
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    return TwoColumnLayout(
      menuItem: widget.menu,
      leftTitle: context.l10n.common_patientListTitle,
      leftSubtitle: context.l10n.common_patientCountSubtitle(state.allPatients.length),
      left: _AllPatientsPanel(state: state, notifier: notifier),
      right: _MyPatientsPanel(state: state, notifier: notifier),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Arama
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: MedSpacing.xl, vertical: MedSpacing.md),
          child: MedTextInputField(
            hintText: context.l10n.myPatients_search_hint,
            prefixIcon: Icon(PhosphorIcons.magnifyingGlass()),
            initialValue: state.search,
            onChanged: (q) => notifier.onSearchChanged(q ?? ''),
          ),
        ),

        // Liste
        Expanded(
          child: filtered.isEmpty
              ? const EmptyStateWidget(variant: EmptyStateVariant.noResults)
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: MedSpacing.xl, vertical: MedSpacing.md),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const SizedBox(height: MedSpacing.sm),
                  itemBuilder: (context, index) {
                    final h = filtered[index];
                    final hospId = h.id;
                    final isAlreadyMine = hospId != null && myIds.contains(hospId);
                    final isPending = hospId != null && state.isPending(hospId);

                    return Opacity(
                      opacity: isAlreadyMine ? 0.4 : 1.0,
                      child: HospitalizationCard(
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: myPatients.isEmpty
              ? EmptyStateWidget(
                  variant: EmptyStateVariant.custom,

                  icon: PhosphorIcons.userPlus(),
                  title: context.l10n.myPatients_empty_title,
                  description: context.l10n.myPatients_empty_description,
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(MedSpacing.xl),
                  itemCount: myPatients.length,
                  separatorBuilder: (_, _) => const SizedBox(height: MedSpacing.sm),
                  itemBuilder: (context, index) {
                    final mp = myPatients[index];
                    final h = mp.hospitalization;
                    if (h == null) return const SizedBox.shrink();

                    final hospId = h.id;
                    final isPending = hospId != null && state.isPending(hospId);

                    return HospitalizationCard(
                      hospitalization: h,
                      onTap: () {},
                      showChevron: false,
                      trailing: isPending ? const Center(child: MedLoadingIndicator()) : null,
                      onRemove: isPending ? null : () => notifier.removePatient(mp),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
