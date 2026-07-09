part of 'mobile_census_dialog.dart';

FooterContent _censusFooter(
  BuildContext context,
  MobileCensusState state,
  MobileDrawerStage drawerStage,
  MobileCensusReady ready,
  MobileCensusNotifier notifier,
) {
  final l10n = context.l10n;

  // ── Hint ──
  final hint = switch (state) {
    MobileCensusSaving() => l10n.common_action_saving,
    MobileCensusWaitingClose() => l10n.census_hint_waitingClose,
    MobileCensusClosedEarly() => l10n.census_hint_closedEarly,
    MobileCensusError() => l10n.cabinOperation_hint_error,
    _ => switch (drawerStage) {
      MobileDrawerOpening() => l10n.refill_status_drawerOpening,
      MobileDrawerOpened() =>
        !ready.baselineCompleted
            ? l10n.cabinOperation_hint_scanning
            : ready.placedEpcs.isNotEmpty
            ? l10n.census_hint_unexpectedTag
            : l10n.census_hint_readyToComplete,
      _ => '',
    },
  };

  // ── Actions ──
  final actions = switch (state) {
    MobileCensusSaving() => [FooterActions.saving()],
    MobileCensusWaitingClose() => [FooterActions.primary(l10n.cabinOperation_action_closeDrawer, null)],
    MobileCensusClosedEarly() => [
      FooterActions.secondary(l10n.common_cancelButton, notifier.cancelEarlyClose),
      SizedBox(width: 10),
      FooterActions.retry(notifier.retryEarlyClose),
    ],
    MobileCensusError() => [FooterActions.retry(notifier.retryComplete)],
    _ when drawerStage is MobileDrawerOpened && ready.canComplete => [
      FooterActions.primary(l10n.census_action_complete, notifier.completeCensus),
    ],
    _ => [FooterActions.primary(l10n.census_action_complete, null)],
  };

  return FooterContent(hint: hint, actions: actions);
}
