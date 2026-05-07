// [SWREQ-CABIN-OP-001] [IEC 62304 §5.5]
// Mobil kabin çekmece operasyon oturumunun aşamaları.
// Operation tipinden bağımsız (refill / pickup / return / fault).
// Sınıf: Class B

sealed class MobileDrawerStage {
  const MobileDrawerStage();
}

/// Henüz başlatılmadı.
final class MobileDrawerIdle extends MobileDrawerStage {
  const MobileDrawerIdle();
}

/// COM porta bağlanılıyor + openMobileDrawer komutu gönderildi.
/// Çekmecenin fiziksel olarak açıldığı henüz teyit edilmedi.
final class MobileDrawerOpening extends MobileDrawerStage {
  const MobileDrawerOpening({required this.port, required this.slotId});

  final int port;
  final int slotId;
}

/// Çekmece fiziksel olarak açıldı.
final class MobileDrawerOpened extends MobileDrawerStage {
  const MobileDrawerOpened({required this.port, required this.slotId});

  final int port;
  final int slotId;
}

/// Çekmece kapatıldı.
final class MobileDrawerClosed extends MobileDrawerStage {
  const MobileDrawerClosed({required this.port, required this.slotId});

  final int port;
  final int slotId;
}

/// Oturum hata aldı (port bağlanamadı, status timeout, vb.).
final class MobileDrawerFailed extends MobileDrawerStage {
  const MobileDrawerFailed({required this.message, this.port, this.slotId});

  final String message;
  final int? port;
  final int? slotId;
}

// ── Yardımcı extension ──────────────────────────────────────────────────────

extension MobileDrawerStageX on MobileDrawerStage {
  bool get isIdle => this is MobileDrawerIdle;
  bool get isOpening => this is MobileDrawerOpening;
  bool get isOpened => this is MobileDrawerOpened;
  bool get isClosed => this is MobileDrawerClosed;
  bool get isFailed => this is MobileDrawerFailed;

  /// Aktif oturum: opening, opened veya closed (işlem akışı bitmemiş).
  bool get isActive => isOpening || isOpened || isClosed;
}
