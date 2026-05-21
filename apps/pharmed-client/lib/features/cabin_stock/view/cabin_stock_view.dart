// [SWREQ-UI-STOCK-VIEW-001]
// Sınıf : Class A

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../widgets/widgets.dart';
import '../../dashboard/presentation/notifier/dashboard_notifier.dart';
import '../../dashboard/presentation/notifier/dashboard_state.dart';
import '../cabin_stock.dart';

class CabinStockView extends ConsumerWidget {
  const CabinStockView({super.key});

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

    return _CabinStockBodyView(cabinId: cabinId);
  }
}

class _CabinStockBodyView extends ConsumerStatefulWidget {
  const _CabinStockBodyView({required this.cabinId});

  final int cabinId;

  @override
  ConsumerState<_CabinStockBodyView> createState() => _CabinStockBodyViewState();
}

class _CabinStockBodyViewState extends ConsumerState<_CabinStockBodyView> {
  @override
  void initState() {
    super.initState();
    _initialize(widget.cabinId);
  }

  @override
  void didUpdateWidget(_CabinStockBodyView old) {
    super.didUpdateWidget(old);
    if (widget.cabinId != old.cabinId) _initialize(widget.cabinId);
  }

  void _initialize(int cabinId) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(cabinStockNotifierProvider.notifier).init(cabinId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cabinStockNotifierProvider);
    final notifier = ref.read(cabinStockNotifierProvider.notifier);

    ref.listen(cabinStockNotifierProvider, (_, next) {
      if (next is CabinStockError) {
        MessageUtils.showErrorSnackbar(context, next.message);
        notifier.dismissError();
      }
    });

    if (state is CabinStockUninitialized || state is CabinStockLoading) {
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
          ),
        ),

        VerticalDivider(width: 1, thickness: 1, color: MedColors.border),

        Expanded(
          child: _StockRightPanel(state: state, notifier: notifier),
        ),
      ],
    );
  }
}

class _StockRightPanel extends StatelessWidget {
  const _StockRightPanel({required this.state, required this.notifier});

  final CabinStockState state;
  final CabinStockNotifier notifier;

  @override
  Widget build(BuildContext context) {
    // Henüz hasta seçilmedi
    if (!state.isPatientSelected) {
      return const EmptyStateWidget(variant: EmptyStateVariant.error);
    }

    // Hasta seçildi, reçeteler yükleniyor
    if (state.isPrescriptionsLoading) {
      return Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    return Padding(
      padding: const EdgeInsets.all(MedSpacing.xl),
      child: RxDrugPanel(
        title: 'Hastaya Ait Kabinde Bulunan İlaçlar',
        items: state.prescriptionItems,
        selectedItem: state.selectedItem,
        isBusy: state.isBusy,
        onDrugTap: (_) {},
        hospitalization: state.selectedPatient,
        showFilters: false,
      ),
    );
  }
}
