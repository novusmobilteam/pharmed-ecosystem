part of 'mobile_unload_dialog.dart';

FooterContent _unloadFooter(
  MobileUnloadState state,
  MobileDrawerStage drawerStage,
  MobileUnloadReady ready,
  MobileUnloadNotifier notifier,
) {
  // ── Hint ──
  final hint = switch (state) {
    MobileUnloadSaving() => 'Kaydediliyor...',
    MobileUnloadWaitingClose() => 'Kayıt alındı — boşaltmayı bitirmek için çekmeceyi kapatın',
    MobileUnloadClosedEarly() => 'Çekmece erken kapandı — tekrar deneyebilir veya iptal edebilirsiniz',
    MobileUnloadError() => 'Hata oluştu — tekrar deneyebilirsiniz',
    _ => switch (drawerStage) {
      MobileDrawerOpening() => 'Çekmece açılıyor...',
      MobileDrawerOpened() =>
        !ready.baselineCompleted
            ? 'Kabin taranıyor, lütfen bekleyin'
            : ready.placedEpcs.isNotEmpty
            ? 'Kabine ait olmayan etiket var — çıkarıp devam edin'
            : 'Boşaltmayı tamamlamak için butona basın',
      _ => '',
    },
  };

  // ── Actions ──
  final actions = switch (state) {
    MobileUnloadSaving() => [FooterActions.saving()],
    MobileUnloadWaitingClose() => [FooterActions.primary('Çekmeceyi Kapatın', null)],
    MobileUnloadClosedEarly() => [
      FooterActions.secondary('İptal', notifier.cancelEarlyClose),
      SizedBox(width: 10),
      FooterActions.retry(notifier.retryEarlyClose),
    ],
    MobileUnloadError() => [FooterActions.retry(notifier.retryComplete)],
    _ when drawerStage is MobileDrawerOpened && ready.canComplete => [
      FooterActions.primary('Boşaltmayı Tamamla', notifier.completeUnload),
    ],
    _ => [FooterActions.primary('Boşaltmayı Tamamla', null)],
  };

  return FooterContent(hint: hint, actions: actions);
}
