// Teknisyenin test edeceği kabin tipi. Giriş sonrası seçilir; menüde hangi
// testlerin görüneceğini ve raporda kabin tipini belirler.
//
// Client'taki istasyon tipleriyle aynı ayrım: Hasta Bazlı istasyon mobil kabin,
// İlaç Bazlı istasyon master kabin (ve ona bağlı serum kartı / serum kabini).

enum HwCabinType {
  medicineBased(
    label: 'İlaç Bazlı Kabin',
    shortLabel: 'İlaç Bazlı',
    summary: 'Master kabin ve ona bağlı kabinler',
    items: [
      'Master kabin çekmeceleri (standart, kübik, birim doz)',
      'Serum kartına bağlı kabinler',
      'Serum kabini, raflar ve avadanlık kilitleri',
    ],
  ),
  patientBased(
    label: 'Hasta Bazlı Kabin',
    shortLabel: 'Hasta Bazlı',
    summary: 'Mobil kabin',
    items: [
      'Mobil kabin çekmeceleri (port 1–8)',
      'Çekmece kilit ve durum kontrolü',
      'RFID okuyucu',
    ],
  );

  const HwCabinType({required this.label, required this.shortLabel, required this.summary, required this.items});

  /// Tam ad: "İlaç Bazlı Kabin" / "Hasta Bazlı Kabin".
  final String label;

  /// Üst çubuktaki kısa ad.
  final String shortLabel;

  /// Seçim kartındaki tek satırlık açıklama.
  final String summary;

  /// Seçim kartında listelenen test kapsamı.
  final List<String> items;
}
