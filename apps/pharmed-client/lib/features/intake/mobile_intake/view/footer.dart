part of 'mobile_intake_dialog.dart';

FooterContent _intakeFooter(
  MobileIntakeState state,
  MobileDrawerStage stage,
  MobileIntakeReady ready,
  MobileIntakeNotifier notifier,
) {
  // ── Hint ──
  final hint = switch (state) {
    MobileIntakeFatalError(:final message) => 'Kritik bir hata oluştu: $message',
    MobileIntakeSaving() => 'Kaydediliyor...',
    MobileIntakeSuccess() => 'İşlem tamamlandı',
    MobileIntakeError() => 'Hata oluştu - tekrar deneyebilirsiniz',
    MobileIntakeWaitingClose() => 'Kayıt alındı. İşlemi bitirmek için çekmeceyi kapatın',
    MobileIntakeClosedEarly() => 'Çekmece kapatıldı. İptal edebilir veya kaldığınız yerden devam edebilirsiniz',
    _ => switch (stage) {
      MobileDrawerOpening() => 'Çekmece açılıyor...',
      _ when !ready.baselineCompleted => 'Kabin taranıyor, lütfen bekleyin',
      _ when ready.canComplete => 'Hazır - işlemi tamamlayabilirsiniz',
      _ when ready.hasExtraPlacement => 'Kabine olmaması gereken bir ilaç yüklendi, lütfen çıkarın.',
      _ => 'İlaçları alın, ardından işlemi tamamlayın',
    },
  };

  // ── Actions ──
  final List<Widget> actions = switch (state) {
    MobileIntakeFatalError() => [FooterActions.dismiss(notifier.dismissError)],
    MobileIntakeSuccess() => [FooterActions.dismiss(notifier.dismissSuccess)],
    MobileIntakeSaving() => [FooterActions.saving()],
    MobileIntakeError() => [FooterActions.retry(notifier.retryComplete)],
    MobileIntakeWaitingClose() => const [],
    MobileIntakeClosedEarly() => [
      FooterActions.secondary('İptal', notifier.cancelEarlyClose),
      SizedBox(width: 10),
      FooterActions.primary('Devam Et', notifier.retryEarlyClose),
    ],
    _ when ready.canComplete => [FooterActions.primary('İşlemi tamamla', notifier.completeIntake)],
    _ => [FooterActions.primary('İşlemi tamamla', null)], // disabled
  };
  return FooterContent(hint: hint, actions: actions);
}
