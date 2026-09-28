/// [SWREQ-HW-001] Master kabin kübik kapağının fiziksel durumu.
///
/// DrawerPhysicalStatus'tan kasıtlı olarak ayrıdır: kübik kapak yalnızca
/// açık/kapalı bilgisi döner (ac/kp); çekme, yarım açık gibi ara durumları yoktur.
enum CubicLidStatus {
  /// `ac` — kapak açık.
  open,

  /// `kp` — kapak kapalı.
  closed,

  /// Yanıt yok, parse edilemedi, `hz`/`nc`/`no` ya da satır seçilemedi.
  unknown,

  /// Art arda [unknown] sınırı aşıldı — iletişim kopmuş kabul edilir.
  timeoutError,
}
