import 'package:pharmed_core/pharmed_core.dart';

/// Order Edilmiş / Yüklenmemiş Malzeme raporu satırı.
///
/// Aktif bir order'ı (reçete kalemi) bulunan ancak ilgili istasyonun
/// kabinlerinde stoğu olmayan malzemeyi temsil eder.
class OrderedNotLoadedMaterial {
  final int? prescriptionItemId;
  final int? stationId;
  final String? stationName;
  final String? serviceName;
  final int? materialId;
  final String? barcode;
  final String? materialName;
  final DateTime? orderDate;
  final String? protocolNo;
  final double? quantity;
  final String? patientFullName;
  final Medicine? medicine;

  const OrderedNotLoadedMaterial({
    this.prescriptionItemId,
    this.stationId,
    this.stationName,
    this.serviceName,
    this.materialId,
    this.barcode,
    this.materialName,
    this.orderDate,
    this.protocolNo,
    this.quantity,
    this.patientFullName,
    this.medicine,
  });
}
