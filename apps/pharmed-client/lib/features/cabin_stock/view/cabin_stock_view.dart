// [SWREQ-UI-STOCK-VIEW-001]
// Sınıf : Class A

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../widgets/widgets.dart';
import '../../dashboard/presentation/notifier/dashboard_notifier.dart';
import '../../dashboard/presentation/notifier/dashboard_state.dart';
import '../cabin_stock.dart';

class CabinStockView extends ConsumerWidget {
  const CabinStockView({super.key, required this.menu});

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

    return _CabinStockBodyView(cabinId: cabinId, menu: menu);
  }
}

class _CabinStockBodyView extends ConsumerStatefulWidget {
  const _CabinStockBodyView({required this.cabinId, required this.menu});

  final int cabinId;
  final MenuItem menu;

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
    _initialize(widget.cabinId);
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

    return TwoColumnLayout(
      menuItem: widget.menu,
      leftTitle: context.l10n.common_patientListTitle,
      leftSubtitle: context.l10n.common_patientCountSubtitle(state.hospitalizations.length),
      leftIcon: PhosphorIcons.users(),
      left: PatientListPanel(
        patients: state.hospitalizations,
        selectedPatient: state.selectedPatient,
        isPatientLoading: state.isPrescriptionsLoading,
        search: state.search,
        onPatientTap: notifier.onPatientTap,
        onSearchChanged: notifier.onSearchChanged,
        title: context.l10n.unappliedPrescription_panel_patientTitle,
      ),
      right: _StockRightPanel(state: state),
    );
  }
}

class _StockRightPanel extends StatelessWidget {
  const _StockRightPanel({required this.state});

  final CabinStockState state;

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
        icon: PhosphorIcons.package(),
        title: context.l10n.cabin_stock_empty_title,
        description: context.l10n.cabin_stock_empty_description,
      );
    }
    return RxDrugPanel(
      items: state.prescriptionItems,
      selectedItem: state.selectedItem,
      isBusy: state.isBusy,
      onDrugTap: (_) {},
    );
  }
}
