import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../widgets/widgets.dart';

import '../../dashboard/dashboard.dart';
import '../cabin_stock.dart';

class CabinStockView extends ConsumerStatefulWidget {
  const CabinStockView({super.key, this.cabinRouteContext});

  final CabinRouteContext? cabinRouteContext;

  @override
  ConsumerState<CabinStockView> createState() => CabinStockViewState();
}

class CabinStockViewState extends ConsumerState<CabinStockView> {
  @override
  void initState() {
    super.initState();
    final cabinId = widget.cabinRouteContext?.cabin?.id ?? 0;
    _initialize(cabinId);
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

    return CabinOperationSelectionLayout(
      left: PatientSelectionPanel(
        selectedPatient: state.selectedPatient,
        config: PatientSelectionConfig(showFilters: false),
        onPatientSelected: (Hospitalization patient, PatientSelectionTab tab, bool isOrderless) {
          notifier.onPatientTap(patient);
        },
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
        title: context.l10n.cabinStock_emptyTitle,
        description: context.l10n.cabinStock_emptyDescription,
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
