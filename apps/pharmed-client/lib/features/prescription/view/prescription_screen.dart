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

import '../../../widgets/widgets.dart';
import '../../dashboard/presentation/notifier/dashboard_notifier.dart';
import '../../dashboard/presentation/state/dashboard_ui_state.dart';
import '../notifier/prescription_notifier.dart';
import '../notifier/prescription_state.dart';

class PrescriptionScreen extends ConsumerWidget {
  const PrescriptionScreen({super.key});

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

    return _PrescriptionBodyView(cabinId: cabinId);
  }
}

class _PrescriptionBodyView extends ConsumerStatefulWidget {
  const _PrescriptionBodyView({required this.cabinId});

  final int cabinId;

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
        Expanded(child: _PrescriptionRightPanel(state: state)),
      ],
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
      return Column(
        children: [
          HospitalizationDetailBanner(hospitalization: state.selectedPatient),
          const Expanded(child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
        ],
      );
    }

    return Column(
      children: [
        // Hasta özet şeridi
        HospitalizationDetailBanner(hospitalization: state.selectedPatient),

        // Reçete carousel
        Expanded(child: _PrescriptionCarousel(items: state.prescriptionItems)),
      ],
    );
  }
}

class _PrescriptionCarousel extends StatelessWidget {
  const _PrescriptionCarousel({required this.items});

  final List<PrescriptionItem> items;

  /// items'ı prescriptionId bazında gruplar.
  /// Prescription nesnesi ilk item'dan alınır (tüm item'lar aynı reçeteden).
  /// Sıralama: prescriptionDate desc (en yeni üstte).
  Map<int, ({Prescription prescription, List<PrescriptionItem> items})> _groupByPrescription() {
    final map = <int, ({Prescription prescription, List<PrescriptionItem> items})>{};

    for (final item in items) {
      final id = item.prescriptionId;
      if (id == null) continue;

      if (map.containsKey(id)) {
        map[id] = (prescription: map[id]!.prescription, items: [...map[id]!.items, item]);
      } else {
        // Prescription nesnesi item üzerinden gelir;
        // yoksa minimal stub oluştur (id ile)
        final prescription = item.prescription ?? Prescription(id: id, prescriptionDate: item.prescriptionDate);
        map[id] = (prescription: prescription, items: [item]);
      }
    }

    // prescriptionDate desc sırala
    final sorted = map.entries.toList()
      ..sort((a, b) {
        final dateA = a.value.prescription.prescriptionDate;
        final dateB = b.value.prescription.prescriptionDate;
        if (dateA == null && dateB == null) return 0;
        if (dateA == null) return 1;
        if (dateB == null) return -1;
        return dateB.compareTo(dateA);
      });

    return Map.fromEntries(sorted);
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const EmptyStateWidget(variant: EmptyStateVariant.error);
    }

    final groups = _groupByPrescription();

    if (groups.isEmpty) {
      return const EmptyStateWidget(variant: EmptyStateVariant.error);
    }

    final groupList = groups.values.toList();

    return ListView.separated(
      padding: const EdgeInsets.all(MedSpacing.xl4),
      itemCount: groupList.length,
      separatorBuilder: (_, __) => const SizedBox(height: MedSpacing.xl2),
      itemBuilder: (context, index) {
        final group = groupList[index];
        return RxGroupCard(
          prescription: group.prescription,
          items: group.items,
          // İlk kart açık, geri kalanlar kapalı
          initiallyExpanded: index == 0,
        );
      },
    );
  }
}
