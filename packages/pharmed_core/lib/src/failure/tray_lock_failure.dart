// [SWREQ-HW-TRAY-001] [IEC 62304 §5.5]
// Serum kabini avadanlık kilit kartı — protokol seviyesindeki hata nedenleri.
// Oturum katmanı bunu kullanıcıya gösterilecek hataya eşler.
// Sınıf: Class B

enum TrayLockFailure {
  /// `/noo1\` — geçersiz cihaz ID (ID değişikliğinde 1-99 dışı).
  invalidDeviceId,

  /// `/noo2\` — bir avadanlık çekilmişken (STATE_OPEN) k/x gönderildi.
  trayOpen,

  /// `/noo3\` — port 1-8 dışında.
  invalidPort,

  /// `/noo4\` — kart meşgul, başka bir avadanlık işlemi sürüyor.
  busy,

  /// `/noo5\` — avadanlık çekilmiş, iptal (c) yapılamaz.
  alreadyPulled,

  /// `/noo6\` — kart komut karakterini tanımadı.
  unknownCommand,

  /// Yanıt yok (timeout) ya da seri port bağlı değil.
  noResponse,

  /// Beklenmeyen/ayrıştırılamayan yanıt (ör. status yerine tuş değeri).
  protocolError,
}

class TrayLockException implements Exception {
  const TrayLockException(this.failure, {this.detail});

  final TrayLockFailure failure;

  /// Ham donanım yanıtı ya da hata detayı — log ve teşhis için.
  final String? detail;

  @override
  String toString() => 'TrayLockException(${failure.name}, detail: $detail)';
}
