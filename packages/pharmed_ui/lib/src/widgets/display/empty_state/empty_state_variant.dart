/// [EmptyStateWidget] için önceden tanımlı boş durum senaryoları.
///
/// Her varyant lokalize başlık, açıklama ve ikon içerir.
/// Özel içerik için [custom] kullanılır.
enum EmptyStateVariant {
  /// Kabin verisi henüz yüklenmemiş veya bulunamadı.
  cabinData,

  /// Arama veya filtre sonucu boş.
  noResults,

  /// Göz seçilmemiş.
  noCellSelected,

  /// Göze hasta atanmamış veya hasta seçimi bekleniyor.
  noPatient,

  /// Hasta var fakat aktif reçetesi yok.
  noPrescription,

  /// Tanımlı kabin bulunamadı.
  noCabin,

  /// İade edilebilecek ilaç bulunamadı.
  noRefundableDrugs,

  /// Fire/imha edilebilir ilaç bulunamadı.
  noWastableDrugs,

  /// Ağ bağlantısı yok.
  networkError,

  /// Sunucuya erişilemiyor.
  serverError,

  /// Genel hata durumu.
  error,

  /// Servisten veri gelmedi / liste boş.
  noData,

  noPatientSelected,

  /// Özel içerik.
  ///
  /// [EmptyStateWidget.icon], [EmptyStateWidget.title] ve
  /// [EmptyStateWidget.description] alanları doldurulmalıdır.
  custom,
}
