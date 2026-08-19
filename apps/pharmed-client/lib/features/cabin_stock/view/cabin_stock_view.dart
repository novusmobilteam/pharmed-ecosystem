// [SWREQ-UI-STOCK-VIEW-001]
// Sınıf : Class A

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/widgets/cabin_shell_widgets/selection/patient_selection/notifier/patient_selection_config.dart';
import 'package:pharmed_client/widgets/cabin_shell_widgets/selection/patient_selection/view/patient_selection_panel.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../widgets/widgets.dart';

import '../cabin_stock.dart';

class CabinStockView extends ConsumerStatefulWidget {
  const CabinStockView({super.key, required this.cabinData, required this.menu});

  final CabinVisualizerData cabinData;
  final MenuItem menu;

  @override
  ConsumerState<CabinStockView> createState() => CabinStockViewState();
}

class CabinStockViewState extends ConsumerState<CabinStockView> {
  @override
  void initState() {
    super.initState();
    _initialize(widget.cabinData.cabinId);
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
