// [SWREQ-PRN-003]
// Termal yazıcı hatalarının nedeni. PrinterException.reason olarak taşınır;
// UI kullanıcıya gösterilecek mesajı bu nedene göre seçer.
//
// Sınıf: Class B

enum PrinterFailureReason {
  /// Kioskta yazıcı bağlantısı (port / kuyruk) tanımlanmamış.
  notConfigured,

  /// Seri port ya da Windows yazıcı kuyruğu açılamadı (yok, başka uygulama kullanıyor vb.).
  connectionFailed,

  /// Veri yazıcıya gönderilirken hata oluştu ya da eksik gönderildi.
  writeFailed,

  /// Gönderim belirlenen sürede tamamlanmadı.
  timeout,

  /// Fiş görüntüye çevrilemedi.
  renderFailed,

  /// Fiş boş ya da içeriği yazdırılamaz durumda.
  invalidDocument,

  unexpected,
}
