import 'package:pharmed_core/pharmed_core.dart';

class RedirectedIntakeOrderDTO {
  const RedirectedIntakeOrderDTO({
    required this.id,
    this.materialId,
    this.quantity,
    this.isEquivalent = false,
    this.stationId,
    this.stationName,
    this.sendStationId,
    this.sendStationName,
    this.sendServiceName,
    this.sendUserName,
    this.receiveDate,
    this.isCancel = false,
    this.prescriptionItem,
    this.stocks = const [],
  });

  final int id; // referralId — check/complete servisleri bunu kullanıyor
  final int? materialId;
  final double? quantity;
  final bool isEquivalent;
  final int? stationId;
  final String? stationName;
  final int? sendStationId;
  final String? sendStationName;
  final String? sendServiceName;
  final String? sendUserName;
  final DateTime? receiveDate;
  final bool isCancel;

  final PrescriptionItemDto? prescriptionItem;
  final List<CabinStockDTO> stocks;

  factory RedirectedIntakeOrderDTO.fromJson(Map<String, dynamic> json) {
    final prescriptionDetailJson = json['prescriptionDetail'] as Map<String, dynamic>?;

    // PrescriptionItemDto.fromJson yalnızca prescriptionDetail'in DOĞRUDAN
    // üstündeki 'patientHospitalization'ı okuyor — bizim gövdemizde bu bilgi
    // prescriptionDetail.prescription.patientHospitalization altında, bir kat
    // daha derinde. PrescriptionItemDto'yu (başka akışlarda da kullanıldığı
    // için) bozmadan, gerçek hastane JSON'unu buradan ayrıca çekip
    // PrescriptionItemDto.fromJson'a "sanki üstteymiş gibi" veriyoruz.
    final hospitalizationJson = prescriptionDetailJson?['prescription']?['patientHospitalization'];
    final patchedDetailJson = prescriptionDetailJson == null
        ? null
        : {...prescriptionDetailJson, 'patientHospitalization': hospitalizationJson};

    return RedirectedIntakeOrderDTO(
      id: json['id'] as int,
      materialId: json['materialId'] as int?,
      quantity: (json['quantity'] as num?)?.toDouble(),
      isEquivalent: json['isEquivalent'] as bool? ?? false,
      stationId: json['stationId'] as int?,
      stationName: json['station'] as String?,
      sendStationId: json['sendStationId'] as int?,
      sendStationName: json['sendStation'] as String?,
      sendServiceName: json['sendService'] as String?,
      sendUserName: json['sendUser'] as String?,
      receiveDate: json['receiveDate'] == null ? null : DateTime.tryParse(json['receiveDate'] as String),
      isCancel: json['isCancel'] as bool? ?? false,
      prescriptionItem: patchedDetailJson == null ? null : PrescriptionItemDto.fromJson(patchedDetailJson),
      stocks: (json['cabinDrawrStocks'] as List<dynamic>? ?? [])
          .map((e) => CabinStockDTO.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
