part of 'master_refill_view.dart';

class MasterRefillExecutionPanel extends ConsumerWidget {
  const MasterRefillExecutionPanel({super.key, required this.allGroups});

  // CabinVisualizerData.groups — tüm kabin çekmeceleri, notInQueue için lazım.
  final List<DrawerGroup> allGroups;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(masterRefillNotifierProvider);

    final executing = switch (state) {
      MasterRefillExecuting e => e,
      MasterRefillError(previousState: MasterRefillExecuting e) => e,
      _ => null,
    };
    if (executing == null) return const SizedBox.shrink();

    final notifier = ref.read(masterRefillNotifierProvider.notifier);
    final drawerStage = ref.watch(masterDrawerSessionProvider).stage;

    // Çekmece henüz açık değilse: tam-ekran bekleme adımı.
    // Opened olur olmaz otomatik olarak forma geçilir (ara "Devam" ekranı yok).
    final isOpened = drawerStage is MasterDrawerOpened;

    final job = executing.currentJob;
    if (job == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CabinOperationTopStrip(
          progressLabel: context.l10n.refill_label_queueProgress(executing.completedJobs + 1, executing.totalJobs),
          progress: executing.progress,
          onStop: notifier.stopQueue,
          stopLabel: context.l10n.refill_action_stop,
          stopConfirmTitle: context.l10n.refill_stop_confirmTitle,
          stopConfirmMessage: context.l10n.refill_stop_confirmMessage,
          stopConfirmYesLabel: context.l10n.refill_stop_confirmYes,
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
                ? _FillForm(state: executing, job: job, notifier: notifier)
                : _drawerOpeningView(context, drawerStage),
          ),
        ),
      ],
    );
  }

  Widget _drawerOpeningView(BuildContext context, MasterDrawerStage stage) {
    final (String title, String subtitle) = switch (stage) {
      MasterDrawerWaitingForPull() => (
        context.l10n.refill_status_waitingPullTitle,
        context.l10n.refill_status_waitingPullBody,
      ),
      MasterDrawerOpeningLid() => (
        context.l10n.refill_status_openingLidTitle,
        context.l10n.refill_status_openingLidBody,
      ),
      _ => (context.l10n.refill_status_openingTitle, context.l10n.refill_status_openingBody),
    };
    return CabinDrawerOpeningView(title: title, subtitle: subtitle);
  }
}
