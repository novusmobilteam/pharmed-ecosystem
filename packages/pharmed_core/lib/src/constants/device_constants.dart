class DeviceConstants {
  // --- Protokol Parametreleri ---
  /// Kübik ana kilidini açmak için gönderilen özel çekmece numarası.
  static const int cubicMasterDrawerId = 30;

  /// Standart ve Kübik ana kilitleri fiziksel olarak genelde Port 1'dedir.
  static const int masterLockPort = 1;

  // --- Cevap Kodları ---
  static const String responseOk = "ok";
  static const String responseError = "no";

  // Durum Kodları (Cihazdan gelen ham stringler)
  static const String rawLocked = "h0"; // Kilitlendi
  static const String rawUnlockedWaiting = "h1"; // Kilit açık, çekilmedi
  static const String rawHalfOpen = "h2"; // Yarım açık
  static const String rawFullyOpen = "h3"; // Tam açık (Kübik Beklenen)
  static const String rawClosed = "h4"; // Kapatıldı
  static const String rawGeneralClosed = "h5"; // Kapalı
  static const String rawGeneralOpen = "h6"; // Açık (Standart Beklenen)

  // Serum (Soğuk Zincir) Protokolü
  static const String serumPrefix = ":";
  static const String serumSuffix = ";";
  static const String serumCmdOpen = 'a';
  static const String serumCmdStatus = 'c';

  static const String serumOpen = "h3"; // Kapak Açık
  static const String serumClosed = "h4"; // Kapak Kapalı (Kilitli)
  static const String serumUnlocked = "h1"; // Kilit Açık
  static const String serumOk = ":ok;"; // Onay

  static const String serumCardId = ".250";

  static const Duration statusPollingInterval = Duration(milliseconds: 500);
}
