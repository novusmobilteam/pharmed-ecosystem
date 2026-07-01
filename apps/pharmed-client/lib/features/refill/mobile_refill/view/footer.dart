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
    MobileRefillError() => 'Hata oluştu — tekrar deneyebilir veya çekmeceyi açıp ilaçları çıkartabilirsiniz',
    MobileRefillRollbackInProgress() => switch (stage) {
      MobileDrawerOpening() => 'Çekmece açılıyor, lütfen bekleyin...',
      MobileDrawerOpened() => 'Yerleştirdiğiniz ilaçları kabinden çıkartın, ardından çekmeceyi kapatın.',
      MobileDrawerClosed() =>
        ready.rfidReadEpcs.isEmpty
            ? 'İlaçları çıkardınız. İşlem sonlandırılıyor...'
            : 'İlaçlar hâlâ kabinde. Tekrar denemek için "Tekrar Dene" veya çekmeceyi açmak için ilgili butonu kullanın.',
      _ => 'İşlem geri alınıyor...',
    },
    _ => switch (stage) {
      MobileDrawerOpening() => 'Çekmece açılıyor...',
      MobileDrawerClosed() => switch (ready) {
        _ when ready.canComplete => 'İşlemi bitirmek için tamamla butonuna basın',
        _ when ready.isBlockedByUnexpected => 'Kabine ait olmayan etiket(ler) var, çekmeceyi tekrar açıp çıkartın',
        _ when ready.hasExtraPlacement => 'Seçili ilaçlar dışında etiket kondu, çekmeceyi tekrar açıp çıkartın',
        _ => 'Eksik etiketler var, çekmeceyi tekrar açıp yerleştirmeye devam edin',
      },
      // Drawer Opened
      _ when !ready.baselineCompleted => 'Kabin taranıyor, lütfen bekleyin',
      _ => 'İlaçları yerleştirin, ardından çekmeceyi kapatın',
    },
  };

  // ── Actions ──
  final actions = switch (state) {
    MobileRefillFatalError() => [FooterActions.dismiss(notifier.dismissError)],
    MobileRefillError() => [FooterActions.retry(notifier.retryComplete)],
    MobileRefillRollbackInProgress() => const <Widget>[],
    MobileRefillSaving() => [FooterActions.saving()],
    _ when stage is MobileDrawerClosed && ready.canComplete => [
      FooterActions.primary('İşlemi tamamla', notifier.completeRefill),
    ],
    _ when stage is MobileDrawerClosed => [FooterActions.primary('Doluma Devam Et', notifier.reopenDrawer)],
    _ => [FooterActions.primary('İşlemi tamamla', null)],
  };

  return FooterContent(hint: hint, actions: actions);
}
