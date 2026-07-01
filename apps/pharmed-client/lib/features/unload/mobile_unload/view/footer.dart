part of 'mobile_unload_dialog.dart';

FooterContent _unloadFooter(
  MobileUnloadState state,
  MobileDrawerStage stage,
  MobileUnloadReady ready,
  MobileUnloadNotifier notifier,
) {
  // ── Hint ──
  final hint = switch (state) {
    MobileUnloadFatalError() => 'Kritik bir hata oluştu',
    MobileUnloadSaving() => 'Kaydediliyor...',
    MobileUnloadError() => 'Hata oluştu — tekrar deneyebilirsiniz',
    MobileUnloadRollbackInProgress() => switch (stage) {
      MobileDrawerOpening() => 'Çekmece açılıyor...',
      MobileDrawerOpened() => 'Çıkardığınız ilaçları kabine geri koyun, ardından kapatın.',
      MobileDrawerClosed() =>
        ready.isRollbackComplete
            ? 'İlaçlar geri kondu. İşlem sonlandırılıyor...'
            : 'Bazı ilaçlar hâlâ eksik. Çekmeceyi açıp kalanları geri koyun.',
      _ => 'İşlem geri alınıyor...',
    },
    _ => switch (stage) {
      MobileDrawerOpening() => 'Çekmece açılıyor...',
      MobileDrawerOpened() =>
        ready.baselineCompleted
            ? 'Boşaltmak istediğiniz ilaçları çıkarın, ardından çekmeceyi kapatın'
            : 'Kabin taranıyor, lütfen bekleyin',
      MobileDrawerClosed() =>
        ready.canComplete ? 'İşlemi tamamlamak için butona basın' : 'Tarama tamamlanmadı, lütfen bekleyin',
      _ => '',
    },
  };

  // ── Actions ──
  final actions = switch (state) {
    MobileUnloadFatalError() => [FooterActions.dismiss(notifier.dismissError)],
    MobileUnloadError() => [FooterActions.retry(notifier.retryComplete)],
    MobileUnloadRollbackInProgress() => const <Widget>[],
    MobileUnloadSaving() => [FooterActions.saving()],
    _ when stage is MobileDrawerClosed && ready.canComplete => [
      FooterActions.primary('Boşaltmayı Tamamla', notifier.completeUnload),
    ],
    _ => [FooterActions.primary('Boşaltmayı Tamamla', null)],
  };

  return FooterContent(hint: hint, actions: actions);
}
