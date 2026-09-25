// [SWREQ-CLI-CABINEXEC-001]
// Dolum, dolum listesi, sayım ve boşaltmanın ortak yürütme ekranı. Sol:
// kabin şeridi + kabin yerleşimi. Sağ: (kübikte) çekmece yerleşimi + başlık/
// gövde/footer. Kuyruk hatası dialog'unu da kendisi yönetir. Ekrana özgü
// tek şey başlıktaki bilgilerdir (headerValues / headerTrailing).
//
// Sınıf: Class B

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/hardware/hardware.dart';
import '../../features/dashboard/dashboard.dart';
import '../cabin_shell_widgets/cabin_shell_widgets.dart';
import 'cabin_operation_execution.dart';

class CabinOperationExecutionView extends StatefulWidget {
  const CabinOperationExecutionView({
    super.key,
    required this.controller,
    required this.stationContext,
    this.headerValues,
    this.headerTrailing,
  });

  final CabinOperationExecutionController controller;
  final StationCabinsContext stationContext;

  final List<CabinExecutionInfoValue> Function(BuildContext context, CabinOperationTarget target)? headerValues;
  final Widget? Function(BuildContext context, CabinOperationTarget target)? headerTrailing;

  @override
  State<CabinOperationExecutionView> createState() => _CabinOperationExecutionViewState();
}

class _CabinOperationExecutionViewState extends State<CabinOperationExecutionView> {
  CabinOperationFailure? _lastFailure;

  @override
  void initState() {
    super.initState();
    _lastFailure = widget.controller.failure;
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(covariant CabinOperationExecutionView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  /// Yalnızca YENİ hata anında dialog/snackbar — her notify'da değil.
  void _onControllerChanged() {
    final failure = widget.controller.failure;
    final isNew = failure != null && _lastFailure == null;
    _lastFailure = failure;
    if (!isNew || !mounted) return;

    final controller = widget.controller;
    final message = failure.message(context);

    if (controller.isQueueError) {
      MessageUtils.showConfirmDialog(
        context: context,
        action: ConfirmAction.custom,
        customTitle: context.l10n.cabinExecution_errorTitle,
        customMessage: message.isNotEmpty ? message : context.l10n.cabinExecution_errorTitle,
        iconData: PhosphorIcons.warning(),
        color: MedColors.red,
        confirmButtonText: context.l10n.cabinExecution_errorSkipButton,
        cancelButtonText: context.l10n.cabinExecution_errorAbortButton,
        onConfirm: controller.continueAfterError,
        onCancel: controller.abortAfterError,
      );
    } else {
      MessageUtils.showErrorSnackbar(context, message);
      controller.dismissQueueError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(listenable: widget.controller, builder: (context, _) => _buildContent(context));
  }

  Widget _buildContent(BuildContext context) {
    final controller = widget.controller;
    final job = controller.currentJob;
    final target = controller.currentTarget;
    if (!controller.isExecuting || job == null || target == null) return const SizedBox.shrink();

    final stationContext = widget.stationContext;
    final activeCabin = stationContext.cabinFor(job.cabinId);
    if (activeCabin == null) return const SizedBox.shrink();

    final allGroups = stationContext.dataFor(job.cabinId)?.groups ?? const <DrawerGroup>[];
    final drawerGroup = allGroups.firstWhereOrNull((g) => g.slot.id == job.cabinDrawerId);
    final locationItems = controller.toLocationItems(allGroups);
    final activeItem = locationItems.firstWhereOrNull((i) => i.cabinDrawerId == job.cabinDrawerId);

    return Row(
      spacing: 12.0,
      children: [
        Expanded(
          child: Column(
            spacing: 24.0,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StationCabinsOverview(cabins: stationContext.cabins, activeCabinId: job.cabinId),
              Expanded(
                child: CabinLayoutOverviewPanel(cabin: activeCabin, items: locationItems),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Row(
            spacing: 12.0,
            children: [
              if (activeItem != null)
                Expanded(
                  child: Column(
                    children: [
                      Expanded(child: DrawerLayoutOverviewPanel(item: activeItem)),
                      if (job.isKubik) const Expanded(child: SizedBox()), // bilinçli: panel tüm yüksekliği almasın
                    ],
                  ),
                ),
              Expanded(child: _buildPanel(context, job, target, drawerGroup)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPanel(
    BuildContext context,
    CabinOperationDrawerJob job,
    CabinOperationTarget target,
    DrawerGroup? drawerGroup,
  ) {
    final controller = widget.controller;
    final jobs = controller.jobs;
    final completed = jobs.where((j) => j.status == CabinOperationJobStatus.completed).length;
    final isOpened = controller.drawerStage is MasterDrawerOpened;
    final canConfirm = isOpened && !controller.isSaving && !controller.isStopping && target.isValid;

    return CabinExecutionPanel(
      header: CabinExecutionHeader(
        medicineName: target.assignment.medicine?.name ?? '-',
        values: widget.headerValues?.call(context, target) ?? const [],
        trailing: widget.headerTrailing?.call(context, target),
      ),
      body: CabinDrawerStageOverlay(
        stage: controller.drawerStage,
        isStopping: controller.isStopping,
        isLastJob: controller.currentIndex >= jobs.length - 1,
        child: CabinOperationEntryBody(
          job: job,
          target: target,
          handlers: controller,
          drawerGroup: drawerGroup,
          enabled: !controller.isSaving,
          isPerCellMiadEnabled: controller.isPerCellMiadEnabled,
        ),
      ),
      footer: CabinExecutionFooter(
        currentDrawer: (completed + 1).clamp(1, jobs.length),
        totalDrawers: jobs.length,
        isSaving: controller.isSaving,
        onStop: controller.isStopping ? null : controller.requestStop,
        onConfirm: canConfirm ? controller.confirmCurrent : null,
      ),
    );
  }
}
