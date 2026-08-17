// [SWREQ-UI-STOCK-VIEW-001]
// Sınıf : Class A

import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../widgets/widgets.dart';
import '../../dashboard/presentation/notifier/dashboard_notifier.dart';
import '../cabin_stock.dart';

class CabinStockView extends StatelessWidget {
  const CabinStockView({super.key, required this.menu});

  final MenuItem menu;

  @override
  Widget build(BuildContext context) {
    final dashboard = context.watch<DashboardNotifier>();
    final cabinId = dashboard.cabinVisualizerData?.cabinId;

    if (cabinId == null) {
      return const EmptyStateWidget(variant: EmptyStateVariant.cabinData);
    }

    return ChangeNotifierProvider<CabinStockNotifier>(
      create: (ctx) =>
          CabinStockNotifier(getBedAssignments: ctx.read(), getPrescriptionHistory: ctx.read())..init(cabinId),
      child: _CabinStockBodyView(cabinId: cabinId, menu: menu),
    );
  }
}

class _CabinStockBodyView extends StatefulWidget {
  const _CabinStockBodyView({required this.cabinId, required this.menu});

  final int cabinId;
  final MenuItem menu;

  @override
  State<_CabinStockBodyView> createState() => _CabinStockBodyViewState();
}

class _CabinStockBodyViewState extends State<_CabinStockBodyView> {
  @override
  void didUpdateWidget(_CabinStockBodyView old) {
    super.didUpdateWidget(old);
    if (widget.cabinId != old.cabinId) {
      context.read<CabinStockNotifier>().init(widget.cabinId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<CabinStockNotifier>();

    if (notifier.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        MessageUtils.showErrorSnackbar(context, notifier.errorMessage!);
        notifier.dismissError();
      });
    }

    if (notifier.isLoading(notifier.initOp) && notifier.hospitalizations.isEmpty) {
      return const Center(child: MedLoadingIndicator());
    }

    if (notifier.hospitalizations.isEmpty) {
      return EmptyStateWidget(
        icon: PhosphorIcons.usersThree(),
        size: EmptyStateSize.normal,
        title: context.l10n.prescription_noPatients_title,
        description: context.l10n.prescription_noPatients_message,
      );
    }

    return CabinOperationSelectionLayout(
      left: SizedBox(),
      // left: PatientSelectionGuide(
      //   patients: notifier.hospitalizations,
      //   selectedPatient: notifier.selectedPatient,
      //   isPatientLoading: notifier.isPrescriptionsLoading,
      //   search: notifier.search,
      //   onPatientTap: notifier.onPatientTap,
      //   onSearchChanged: notifier.onSearchChanged,
      //   title: context.l10n.unappliedPrescription_panel_patientTitle,
      // ),
      right: _StockRightPanel(notifier: notifier),
    );
  }
}

class _StockRightPanel extends StatelessWidget {
  const _StockRightPanel({required this.notifier});

  final CabinStockNotifier notifier;

  @override
  Widget build(BuildContext context) {
    if (notifier.isPrescriptionsLoading) {
      return Center(child: MedLoadingIndicator());
    }

    if (!notifier.isPatientSelected) {
      return const EmptyStateWidget(variant: EmptyStateVariant.noPatientSelected);
    }

    if (notifier.prescriptionItems.isEmpty) {
      return EmptyStateWidget(
        icon: PhosphorIcons.package(),
        title: context.l10n.cabin_stock_empty_title,
        description: context.l10n.cabin_stock_empty_description,
      );
    }
    return RxDrugPanel(
      items: notifier.prescriptionItems,
      selectedItem: notifier.selectedItem,
      isBusy: notifier.isBusy,
      onDrugTap: (_) {},
    );
  }
}
