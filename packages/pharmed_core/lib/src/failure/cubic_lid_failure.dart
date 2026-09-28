/// [SWREQ-HW-001] Kübik kapak açma komutunun protokol seviyesindeki
/// başarısızlık nedeni. Oturum katmanı bunu MasterDrawerFailure'a eşler.
enum CubicLidFailure {
  /// `ht` — ana çekmece tam açık değilken aç komutu geldi (donanım interlock'u).
  drawerNotOpen,

  /// `hz` — master kart slave karttan 250ms içinde yanıt alamadı.
  slaveNoResponse,

  /// `nc` / `no` / beklenmeyen yanıt.
  protocolError,

  /// Yanıt yok (timeout) veya satır seçilemedi.
  noResponse,
}

class CubicLidException implements Exception {
  const CubicLidException(this.failure, {this.detail});

  final CubicLidFailure failure;

  /// Ham donanım yanıtı — log ve teşhis için.
  final String? detail;

  @override
  String toString() => 'CubicLidException(${failure.name}, detail: $detail)';
}
