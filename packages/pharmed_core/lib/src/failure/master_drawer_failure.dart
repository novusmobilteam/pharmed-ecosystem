// [SWREQ-CLI-CABIN-OP-011] [IEC 62304 §5.5]
// Master kabin çekmece oturumu hata nedenleri.
// Sınıf: Class B

enum MasterDrawerFailure {
  managerNotFound,
  managerConnectFailed,
  lockOpenFailed,

  /// Kübik kart/iletişim hatası (hz, nc/no, yanıt yok) — otomatik tekrar
  /// denemeler tükendi. Seçenekler: Tekrar Dene / Bu Gözü Atla / Sonlandır.
  lidOpenFailed,

  /// `ht` — ana çekmece tam açık değil. Kullanıcı çekmeceyi sonuna kadar
  /// çekip tekrar dener.
  lidDrawerNotOpen,

  /// Aç komutu `ok` döndü ama süre içinde `ac` okunmadı (takılı kapak).
  /// İzleme devam eder; `ac` gelirse akış kendiliğinden ilerler.
  lidNotOpened,

  /// Kapak açıkken durum sorgusu koptu (timeoutError).
  lidSensorLost,

  lockOpenTimeout,
  sensorCommunicationLost,
  unexpectedlyClosed,

  /// Serum: avadanlık kilidi açılamadı (yanıt yok / protokol hatası,
  /// otomatik tekrar tükendi). Seçenekler: Tekrar Dene / Bu Avadanlığı Atla.
  trayUnlockFailed,

  /// Serum: rafta başka bir avadanlık çekili (`noo4`/`noo2`). Kullanıcı onu
  /// yerine itip tekrar dener.
  trayBusy,

  /// Serum: avadanlık açıkken durum sorgusu koptu. Avadanlık çekilmiş ve
  /// işlem yapılmış olabilir — atlanamaz; kullanıcı yerine ittiğini onaylar.
  traySensorLost,
}
