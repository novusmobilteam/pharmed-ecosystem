import 'package:pharmed_core/pharmed_core.dart';

/// Hareketsiz Malzeme raporu satırı.
///
/// İstasyon kabinlerinde stoğu bulunan ancak hareket görmeyen malzemeyi,
/// istasyon bazında miktarıyla temsil eder.
class InertMaterial {
  final int? stationId;
  final String? stationName;
  final int? materialId;
  final String? materialName;
  final String? barcode;
  final double? quantity;
  final Medicine? medicine;

  const InertMaterial({
    this.stationId,
    this.stationName,
    this.materialId,
    this.materialName,
    this.barcode,
    this.quantity,
    this.medicine,
  });
}
