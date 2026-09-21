part of 'master_intake_view.dart';

class MasterIntakeExecutionView extends ConsumerWidget {
  const MasterIntakeExecutionView({super.key, required this.stationContext});

  final StationCabinsContext stationContext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(masterIntakeExecutionNotifierProvider);
    final selectionNotifier = ref.watch(masterIntakeSelectionNotifierProvider);

    ref.listen(masterIntakeExecutionNotifierProvider.select((n) => n.qrCodeJob), (previous, next) {
      debugPrint('QR listen fired: previous=$previous, next=$next');
      if (previous == null && next != null) {
        debugPrint('QR dialog opening...');
        showMedDialog<void>(context: context, barrierDismissible: false, builder: (_) => const IntakeQrCodeDialog());
      }
    });

    ref.listen(masterIntakeExecutionNotifierProvider, (previous, next) {
      if (next.failure != null && next.isQueueError) {
        MessageUtils.showConfirmDialog(
          context: context,
          action: ConfirmAction.custom,
          customTitle: context.l10n.intake_error_queueTitle,
          customMessage: next.failure!.message(context).isNotEmpty
              ? next.failure!.message(context)
              : context.l10n.intake_error_queueMessage,
          confirmButtonText: context.l10n.refill_error_continueNext,
          cancelButtonText: context.l10n.refill_error_endProcess,
          onConfirm: next.continueAfterError,
          onCancel: next.abortAfterError,
        );
      } else if (next.failure != null) {
        MessageUtils.showErrorSnackbar(context, next.failure!.message(context));
        next.dismissQueueError();
      }
    });

    final job = notifier.currentJob;
    if (job == null) return const SizedBox.shrink();

    final allGroups = stationContext.dataFor(job.cabinId)?.groups ?? const <DrawerGroup>[];
    final activeCabin = stationContext.cabinFor(job.cabinId);
    final locationItems = notifier.toLocationItems(allGroups);
    final activeItem = locationItems.firstWhereOrNull((i) => i.status == DrawerQueueStatus.active);

    if (activeCabin == null) return const SizedBox.shrink();
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
          child: Column(
            spacing: 24.0,
            children: [
              Expanded(
                flex: 4,
                child: Row(
                  spacing: 24.0,
                  children: [
                    if (activeItem != null) Expanded(flex: 4, child: DrawerLayoutOverviewPanel(item: activeItem)),
                    Expanded(
                      flex: 2,
                      child: IntakeActiveMedicineCard(
                        notifier: notifier,
                        hospitalization: selectionNotifier.hospitalization!,
                      ),
                    ),
                  ],
                ),
              ),
              DrawerStageStatusCard(
                stage: notifier.drawerStage,
                isLastJob: notifier.currentIndex >= notifier.jobs.length - 1,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
