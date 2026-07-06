part of 'mobile_census_dialog.dart';

FooterContent _censusFooter(
  MobileCensusState state,
  MobileDrawerStage drawerStage,
  MobileCensusReady ready,
  MobileCensusNotifier notifier,
) {
  // ── Hint ──
  final hint = switch (state) {
    MobileCensusSaving() => 'Kaydediliyor...',
    MobileCensusWaitingClose() => 'Kayıt alındı — sayımı bitirmek için çekmeceyi kapatın',
    MobileCensusClosedEarly() => 'Çekmece erken kapandı — tekrar deneyebilir veya iptal edebilirsiniz',
    MobileCensusError() => 'Hata oluştu — tekrar deneyebilirsiniz',
    _ => switch (drawerStage) {
      MobileDrawerOpening() => 'Çekmece açılıyor...',
      MobileDrawerOpened() =>
        !ready.baselineCompleted
            ? 'Kabin taranıyor, lütfen bekleyin'
            : ready.placedEpcs.isNotEmpty
            ? 'Kabine ait olmayan etiket var — çıkarıp devam edin'
            : 'Sayımı tamamlamak için butona basın',
      _ => '',
    },
  };

  // ── Actions ──
  final actions = switch (state) {
    MobileCensusSaving() => [FooterActions.saving()],
    MobileCensusWaitingClose() => [FooterActions.primary('Çekmeceyi Kapatın', null)],
    MobileCensusClosedEarly() => [
      FooterActions.secondary('İptal', notifier.cancelEarlyClose),
      SizedBox(width: 10),
      FooterActions.retry(notifier.retryEarlyClose),
    ],
    MobileCensusError() => [FooterActions.retry(notifier.retryComplete)],
    _ when drawerStage is MobileDrawerOpened && ready.canComplete => [
      FooterActions.primary('Sayımı Tamamla', notifier.completeCensus),
    ],
    _ => [FooterActions.primary('Sayımı Tamamla', null)],
  };

  return FooterContent(hint: hint, actions: actions);
}
