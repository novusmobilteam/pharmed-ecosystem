// part of 'mobile_intake_dialog.dart';

// FooterContent _intakeFooter(
//   BuildContext context,
//   MobileIntakeState state,
//   MobileDrawerStage stage,
//   MobileIntakeReady ready,
//   MobileIntakeNotifier notifier,
// ) {
//   final l10n = context.l10n;

//   // ── Hint ──
//   final hint = switch (state) {
//     MobileIntakeFatalError(:final failure) => failure.message(context),
//     MobileIntakeSaving() => l10n.common_action_saving,
//     MobileIntakeSuccess() => l10n.cabinOperation_hint_completed,
//     MobileIntakeError() => l10n.cabinOperation_hint_error,
//     MobileIntakeWaitingClose() => l10n.cabinOperation_hint_waitingCloseGeneric,
//     MobileIntakeClosedEarly() => l10n.cabinOperation_hint_closedEarlyGeneric,
//     _ => switch (stage) {
//       MobileDrawerOpening() => l10n.refill_status_drawerOpening,
//       _ when !ready.baselineCompleted => l10n.cabinOperation_hint_scanning,
//       _ when ready.canComplete => l10n.cabinOperation_hint_ready,
//       _ when ready.hasExtraPlacement => l10n.intake_hint_extraPlacement,
//       _ => l10n.intake_hint_takeItems,
//     },
//   };

//   // ── Actions ──
//   final List<Widget> actions = switch (state) {
//     MobileIntakeFatalError() => [FooterActions.dismiss(notifier.dismissError)],
//     MobileIntakeSuccess() => [FooterActions.dismiss(notifier.dismissSuccess)],
//     MobileIntakeSaving() => [FooterActions.saving()],
//     MobileIntakeError() => [FooterActions.retry(notifier.retryComplete)],
//     MobileIntakeWaitingClose() => const [],
//     MobileIntakeClosedEarly() => [
//       FooterActions.secondary(l10n.common_cancelButton, notifier.cancelEarlyClose),
//       SizedBox(width: 10),
//       FooterActions.primary(l10n.session_timeout_continueButton, notifier.retryEarlyClose),
//     ],
//     _ when ready.canComplete => [
//       FooterActions.primary(l10n.cabinOperation_action_completeGeneric, notifier.completeIntake),
//     ],
//     _ => [FooterActions.primary(l10n.cabinOperation_action_completeGeneric, null)], // disabled
//   };
//   return FooterContent(hint: hint, actions: actions);
// }
