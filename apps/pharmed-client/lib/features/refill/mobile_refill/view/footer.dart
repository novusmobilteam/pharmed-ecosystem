part of 'mobile_refill_dialog.dart';

FooterContent _refillFooter(
  MobileRefillState state,
  MobileDrawerStage stage,
  MobileRefillReady ready,
  MobileRefillNotifier notifier,
) {
  // ── Hint ──
  final hint = switch (state) {
    MobileRefillFatalError(:final message) => 'Kritik bir hata oluştu: $message',
    MobileRefillSaving() => 'Kaydediliyor...',
    MobileRefillSuccess() => 'İşlem tamamlandı',
    MobileRefillError() => 'Hata oluştu - tekrar deneyebilirsiniz',
    MobileRefillWaitingClose() => 'Kayıt alındı. İşlemi bitirmek için çekmeceyi kapatın',
    MobileRefillClosedEarly() => 'Çekmece kapatıldı. İptal edebilir veya kaldığınız yerden devam edebilirsiniz',
    _ => switch (stage) {
      MobileDrawerOpening() => 'Çekmece açılıyor...',
      _ when !ready.baselineCompleted => 'Kabin taranıyor, lütfen bekleyin',
      _ when ready.canComplete => 'Hazır — işlemi tamamlayabilirsiniz',
      _ when ready.hasExtraPlacement => 'Seçili ilaçlar dışında etiket kondu, lütfen çıkartın',
      _ => 'İlaçları yerleştirin, ardından işlemi tamamlayın',
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
      FooterActions.secondary('İptal', notifier.cancelEarlyClose),
      SizedBox(width: 10),
      FooterActions.primary('Devam Et', notifier.retryEarlyClose),
    ],
    _ when ready.canComplete => [FooterActions.primary('İşlemi tamamla', notifier.completeRefill)],
    _ => [FooterActions.primary('İşlemi tamamla', null)], // disabled
  };

  return FooterContent(hint: hint, actions: actions);
}
