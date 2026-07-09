part of 'mobile_unload_dialog.dart';

FooterContent _unloadFooter(
  BuildContext context,
  MobileUnloadState state,
  MobileDrawerStage drawerStage,
  MobileUnloadReady ready,
  MobileUnloadNotifier notifier,
) {
  final l10n = context.l10n;

  // ── Hint ──
  final hint = switch (state) {
    MobileUnloadSaving() => l10n.common_action_saving,
    MobileUnloadWaitingClose() => l10n.unload_hint_waitingClose,
    MobileUnloadClosedEarly() => l10n.unload_hint_closedEarly,
    MobileUnloadError() => l10n.cabinOperation_hint_error,
    _ => switch (drawerStage) {
      MobileDrawerOpening() => l10n.refill_status_drawerOpening,
      MobileDrawerOpened() =>
        !ready.baselineCompleted
            ? l10n.cabinOperation_hint_scanning
            : ready.placedEpcs.isNotEmpty
            ? l10n.census_hint_unexpectedTag
            : l10n.unload_hint_readyToComplete,
      _ => '',
    },
  };

  // ── Actions ──
  final actions = switch (state) {
    MobileUnloadSaving() => [FooterActions.saving()],
    MobileUnloadWaitingClose() => [FooterActions.primary(l10n.cabinOperation_action_closeDrawer, null)],
    MobileUnloadClosedEarly() => [
      FooterActions.secondary(l10n.common_cancelButton, notifier.cancelEarlyClose),
      SizedBox(width: 10),
      FooterActions.retry(notifier.retryEarlyClose),
    ],
    MobileUnloadError() => [FooterActions.retry(notifier.retryComplete)],
    _ when drawerStage is MobileDrawerOpened && ready.canComplete => [
      FooterActions.primary(l10n.unload_action_complete, notifier.completeUnload),
    ],
    _ => [FooterActions.primary(l10n.unload_action_complete, null)],
  };

  return FooterContent(hint: hint, actions: actions);
}
