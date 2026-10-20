import 'package:pharmed_core/pharmed_core.dart';

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
  final Medicine? medicine;

  const UnorderedLoadedMaterial({
    this.stationId,
    this.stationName,
    this.materialId,
    this.materialName,
    this.barcode,
    this.quantity,
    this.medicine,
  });
}
