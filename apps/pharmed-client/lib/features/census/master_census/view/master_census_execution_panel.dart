// [SWREQ-CLI-MCENSUS-008] [IEC 62304 §5.5]
// Sayım kuyruğunun işlendiği tam-ekran yürütme akışı — MasterRefillExecutionPanel
// ile birebir aynı iskelet (CabinOperationTopStrip/CabinDrawerOpeningView/
// CabinOperationBody/CabinOperationFillArea/CabinOperationCellGrid). Fark
// sadece içerik: CensusCellCard (sayım+miad, dolum yok) ve tek-SKT toggle'ı
// hiç yok (sayımda SKT her zaman per-cell).
//
// Sınıf: Class B

part of 'master_census_view.dart';

class MasterCensusExecutionPanel extends ConsumerWidget {
  const MasterCensusExecutionPanel({super.key, required this.allGroups});

  final List<DrawerGroup> allGroups;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(masterCensusNotifierProvider);

    final executing = switch (state) {
      MasterCensusExecuting e => e,
      MasterCensusError(previousState: MasterCensusExecuting e) => e,
      _ => null,
    };
    if (executing == null) return const SizedBox.shrink();

    final notifier = ref.read(masterCensusNotifierProvider.notifier);
    final drawerStage = ref.watch(masterDrawerSessionProvider).stage;
    final isOpened = drawerStage is MasterDrawerOpened;

    final job = executing.currentJob;
    if (job == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CabinOperationTopStrip(
          progressLabel: context.l10n.census_label_queueProgress(executing.completedJobs + 1, executing.totalJobs),
          progress: executing.progress,
          onStop: notifier.stopQueue,
          stopLabel: context.l10n.census_action_stop,
          stopConfirmTitle: context.l10n.census_stop_confirmTitle,
          stopConfirmMessage: context.l10n.census_stop_confirmMessage,
          stopConfirmYesLabel: context.l10n.census_stop_confirmYes,
          cancelLabel: context.l10n.common_cancelButton,
        ),
        const SizedBox(height: 20),
        Expanded(
          child: CabinOperationBody(
            locationGuide: CabinLocationGuide(
              items: executing.toLocationItems(allGroups),
              activeIndex: executing.currentIndex,
            ),
            child: isOpened
                ? _CensusForm(state: executing, job: job, notifier: notifier)
                : _drawerOpeningView(context, drawerStage),
          ),
        ),
      ],
    );
  }

  Widget _drawerOpeningView(BuildContext context, MasterDrawerStage stage) {
    final (String title, String subtitle) = switch (stage) {
      MasterDrawerWaitingForPull() => (
        context.l10n.census_status_waitingPullTitle,
        context.l10n.census_status_waitingPullBody,
      ),
      MasterDrawerOpeningLid() => (
        context.l10n.census_status_openingLidTitle,
        context.l10n.census_status_openingLidBody,
      ),
      _ => (context.l10n.census_status_openingTitle, context.l10n.census_status_openingBody),
    };
    return CabinDrawerOpeningView(title: title, subtitle: subtitle);
  }
}
