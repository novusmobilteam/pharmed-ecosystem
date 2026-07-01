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
    MobileCensusError() => 'Hata oluştu — tekrar deneyebilirsiniz',
    _ => switch (drawerStage) {
      MobileDrawerOpening() => 'Çekmece açılıyor...',
      MobileDrawerOpened() =>
        ready.baselineCompleted ? 'Sayımı bitirmek için çekmeceyi kapatın' : 'Kabin taranıyor, lütfen bekleyin',
      MobileDrawerClosed() =>
        ready.canComplete ? 'Sayımı tamamlamak için butona basın' : 'Tarama tamamlanmadı, lütfen bekleyin',
      _ => '',
    },
  };

  // ── Actions ──
  final actions = switch (state) {
    MobileCensusSaving() => [FooterActions.saving()],
    MobileCensusError() => [FooterActions.retry(notifier.retryComplete)],
    _ when drawerStage is MobileDrawerClosed && ready.canComplete => [
      FooterActions.primary('Sayımı Tamamla', notifier.completeCensus),
    ],
    _ => [FooterActions.primary('Sayımı Tamamla', null)],
  };

  return FooterContent(hint: hint, actions: actions);
}
