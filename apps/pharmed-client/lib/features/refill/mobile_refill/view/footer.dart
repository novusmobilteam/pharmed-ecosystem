part of 'mobile_refill_dialog.dart';

FooterContent _refillFooter(
  BuildContext context,
  MobileRefillState state,
  MobileDrawerStage stage,
  MobileRefillReady ready,
  MobileRefillNotifier notifier,
) {
  final l10n = context.l10n;

  // ── Hint ──
  final hint = switch (state) {
    MobileRefillFatalError(:final message) => l10n.cabinOperation_hint_fatalError(message),
    MobileRefillSaving() => l10n.common_action_saving,
    MobileRefillSuccess() => l10n.cabinOperation_hint_completed,
    MobileRefillError() => l10n.cabinOperation_hint_error,
    MobileRefillWaitingClose() => l10n.cabinOperation_hint_waitingCloseGeneric,
    MobileRefillClosedEarly() => l10n.cabinOperation_hint_closedEarlyGeneric,
    _ => switch (stage) {
      MobileDrawerOpening() => l10n.refill_status_drawerOpening,
      _ when !ready.baselineCompleted => l10n.cabinOperation_hint_scanning,
      _ when ready.canComplete => l10n.cabinOperation_hint_ready,
      _ when ready.hasExtraPlacement => l10n.refill_hint_extraPlacement,
      _ => l10n.refill_hint_placeItems,
    },
  };

  // ── Actions ──
  final List<Widget> actions = switch (state) {
    MobileRefillFatalError() => [FooterActions.dismiss(notifier.dismissError)],
    MobileRefillSuccess() => [FooterActions.dismiss(notifier.dismissSuccess)],
    MobileRefillSaving() => [FooterActions.saving()],
    MobileRefillError() => [FooterActions.retry(notifier.retryComplete)],
    MobileRefillWaitingClose() => const [], // buton yok, kapanış bekleniyor
    MobileRefillClosedEarly() => [
      FooterActions.secondary(l10n.common_cancelButton, notifier.cancelEarlyClose),
      SizedBox(width: 10),
      FooterActions.primary(l10n.session_timeout_continueButton, notifier.retryEarlyClose),
    ],
    _ when ready.canComplete => [FooterActions.primary(l10n.cabinOperation_action_completeGeneric, notifier.completeRefill)],
    _ => [FooterActions.primary(l10n.cabinOperation_action_completeGeneric, null)], // disabled
  };

  return FooterContent(hint: hint, actions: actions);
}
