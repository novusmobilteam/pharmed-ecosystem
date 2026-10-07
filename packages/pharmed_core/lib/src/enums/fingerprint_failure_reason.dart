// [SWREQ-FP-001]
// Parmak izi okuyucu hatalarının nedeni. FingerprintException.reason olarak taşınır;
// UI kullanıcıya gösterilecek mesajı bu nedene göre seçer.
//
// Sınıf: Class B

enum FingerprintFailureReason {
  /// Okuyucu kütüphanesi (UFScanner.dll) yüklenemedi veya beklenen fonksiyonları içermiyor.
  libraryNotFound,

  /// SDK başlatılamadı ya da bilgisayara bağlı okuyucu bulunamadı.
  deviceNotFound,

  /// Okuyucu işlem sırasında yanıt vermedi (USB çıkarıldı, güç yönetimi vb.).
  /// Bu hatadan sonra `open()` yeniden çağrılmalıdır.
  deviceDisconnected,

  /// `open()` çağrılmadan veya başarısız olduktan sonra okuma istendi.
  notOpen,

  /// Bir okuma sürerken yeni bir okuma ya da sorgu istendi.
  busy,

  /// Belirlenen sürede parmak okutulmadı.
  timeout,

  /// Okuma `cancelCapture()` ile iptal edildi.
  cancelled,

  /// Sensörde hâlâ önceki parmak var; yeni okuma için kaldırılması gerekiyor.
  fingerOnSensor,

  /// Canlılık kontrolü (LFD) sahte parmak tespit etti.
  fakeFinger,

  /// Görüntü veya şablon kalitesi eşiğin altında.
  lowQuality,

  /// Görüntüden şablon çıkarılamadı (parmak sensöre düzgün yerleşmedi vb.).
  extractionFailed,

  /// Sensör yüzeyi kirli.
  sensorDirty,

  unexpected,
}
