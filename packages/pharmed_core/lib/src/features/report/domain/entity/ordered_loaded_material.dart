/// Order Edilmiş / Yüklü Malzeme raporu satırı.
///
/// Aktif bir order'ı (reçete kalemi) bulunan ve ilgili istasyonun
/// kabininde stoğu yüklü olan malzemeyi temsil eder.
class OrderedLoadedMaterial {
  final String? serviceName;
  final int? stationId;
  final String? stationName;
  final String? cabinName;
  final String? cabinCode;
  final String? materialName;
  final String? barcode;

  const OrderedLoadedMaterial({
    this.serviceName,
    this.stationId,
    this.stationName,
    this.cabinName,
    this.cabinCode,
    this.materialName,
    this.barcode,
  });
}
