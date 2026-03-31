// pharmed_core/lib/src/cabin/scan_status.dart
//
// [SWREQ-SCAN-001] [IEC 62304 §5.5]
// Kabin tarama sürecinin adım adım durumunu temsil eder.
// ScanCabinUseCase tarafından üretilir, UI katmanı tarafından tüketilir.
// Sınıf: Class B

/// Kabin tarama sürecinin her adımını tanımlayan durum enum'u.
///
/// ScanCabinUseCase.call() çağrıldığında [onStatusChanged] callback'i
/// bu değerleri sırasıyla iletir. UI katmanı bu değerleri adım adım
/// log satırlarına dönüştürerek kullanıcıya gösterir.
///
/// Akış sırası:
/// ```
/// connecting
///   → connected | connectionFailed
///     → fetchingMetadata
///       → metadataReady | metadataFailed
///         → searchingManager
///           → managerFound | managerNotFound
///             → scanningCards
///               → drawerFound (her çekmece için tekrar)
///                 → noCardsFound | completed
/// ```
enum ScanStatus {
  // ── Bağlantı ────────────────────────────────────────────────────

  /// Seri porta bağlantı kuruluyor.
  /// [detail]: Bağlanılmaya çalışılan port adı (ör. "COM3")
  connecting,

  /// Seri port bağlantısı başarıyla kuruldu.
  /// [detail]: Bağlanan port adı (ör. "COM3")
  connected,

  /// Seri porta bağlanılamadı.
  /// [detail]: Hata mesajı
  connectionFailed,

  // ── Meta veri ────────────────────────────────────────────────────

  /// Veritabanından DrawerConfig ve DrawerType tanımları çekiliyor.
  fetchingMetadata,

  /// DrawerConfig ve DrawerType tanımları başarıyla alındı.
  /// [detail]: Yüklenen konfigürasyon sayısı (ör. "12 konfigürasyon")
  metadataReady,

  /// Veritabanı tanımları alınamadı.
  /// [detail]: Hata mesajı
  metadataFailed,

  // ── Donanım taraması ─────────────────────────────────────────────

  /// Seri hat üzerinde yönetim kartı (management card) aranıyor.
  searchingManager,

  /// Yönetim kartı bulundu.
  /// [detail]: Kartın adres bilgisi (ör. "Adres: 1")
  managerFound,

  /// Yönetim kartı bulunamadı — tarama durduruluyor.
  managerNotFound,

  /// Yönetim kartına bağlı kontrol kartları (control cards) taranıyor.
  scanningCards,

  /// Bir kontrol kartı başarıyla eşleştirildi ve DrawerGroup oluşturuldu.
  /// Her çekmece için ayrı ayrı tetiklenir.
  /// [detail]: Çekmece tipi ve sırası (ör. "1. Çekmece — Kübik 4×4")
  drawerFound,

  /// Hiçbir kontrol kartı bulunamadı veya eşleştirilemedi.
  noCardsFound,

  /// Tüm tarama adımları başarıyla tamamlandı.
  /// [detail]: Bulunan toplam çekmece sayısı (ör. "5 çekmece")
  completed,
}
