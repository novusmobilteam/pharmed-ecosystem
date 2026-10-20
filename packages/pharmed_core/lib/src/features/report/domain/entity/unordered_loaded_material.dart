/// Order Edilmemiş / Yüklü Malzeme raporu satırı.
///
/// İstasyon kabinlerinde stoğu bulunan ancak aktif bir order'ı olmayan
/// malzemeyi, istasyon bazında toplam miktarıyla temsil eder.
class UnorderedLoadedMaterial {
  final int? stationId;
  final String? stationName;
  final int? materialId;
  final String? materialName;
  final String? barcode;
  final double? quantity;

  const UnorderedLoadedMaterial({
    this.stationId,
    this.stationName,
    this.materialId,
    this.materialName,
    this.barcode,
    this.quantity,
  });
}
