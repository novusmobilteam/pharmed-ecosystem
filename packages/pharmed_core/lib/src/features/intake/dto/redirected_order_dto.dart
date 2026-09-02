import 'package:pharmed_core/pharmed_core.dart';

class RedirectedOrderDto {
  final int? id;
  final int? materialId;
  final num? quantity;
  final bool? isEquivalent;
  final String? materialName;
  final PrescriptionItemDto? prescriptionItem;
  final int? hospitalizationId;
  final int? stationId;
  final String? stationName;
  final int? serviceId;
  final String? serviceName;
  final int? sendStationId;
  final String? sendStationName;
  final int? sendServiceId;
  final String? sendServiceName;
  final int? sendUserId;
  final String? sendUserName;
  final DateTime? receivedDate;
  final int? receivedUserId;
  final String? receivedUserName;
  final bool? isCancel;
  final int? cancelUserId;
  final String? cancelUserName;
  final String? tcNo;
  final String? patientName;
  final String? patientSurname;
  final List<CabinStockDTO>? cabinStocks;

  RedirectedOrderDto({
    this.id,
    this.materialId,
    this.quantity,
    this.isEquivalent,
    this.materialName,
    this.prescriptionItem,
    this.hospitalizationId,
    this.stationId,
    this.stationName,
    this.serviceId,
    this.serviceName,
    this.sendStationId,
    this.sendStationName,
    this.sendServiceId,
    this.sendServiceName,
    this.sendUserId,
    this.sendUserName,
    this.receivedDate,
    this.receivedUserId,
    this.receivedUserName,
    this.isCancel,
    this.cancelUserId,
    this.cancelUserName,
    this.tcNo,
    this.patientName,
    this.patientSurname,
    this.cabinStocks,
  });

  factory RedirectedOrderDto.fromJson(Map<String, dynamic> json) {
    return RedirectedOrderDto(
      id: json['id'] as int?,
      materialId: json['materialId'] as int?,
      quantity: json['quantity'] as num?,
      isEquivalent: json['isEquivalent'] as bool?,
      materialName: json['material'] as String?,
      prescriptionItem: json['prescriptionDetail'] != null
          ? PrescriptionItemDto.fromJson(json['prescriptionDetail'] as Map<String, dynamic>)
          : null,
      hospitalizationId: json['hospitalizationId'] as int?,
      stationId: json['stationId'] as int?,
      stationName: json['station'] as String?,
      serviceId: json['serviceId'] as int?,
      serviceName: json['service'] as String?,
      sendStationId: json['sendStationId'] as int?,
      sendStationName: json['sendStation'] as String?,
      sendServiceId: json['sendServiceId'] as int?,
      sendServiceName: json['sendService'] as String?,
      sendUserId: json['sendUserId'] as int?,
      sendUserName: json['sendUser'] as String?,
      receivedDate: json['receivedDate'] != null ? DateTime.parse(json['receivedDate']) : null,
      receivedUserId: json['receivedUserId'] as int?,
      receivedUserName: json['receivedUserName'] as String?,
      isCancel: json['isCancel'] as bool?,
      cancelUserId: json['cancelUserId'] as int?,
      cancelUserName: json['cancelUserName'] as String?,
      tcNo: json['tcNo'] as String?,
      patientName: json['name'] as String?,
      patientSurname: json['surname'] as String?,
      cabinStocks: (json['cabinDrawrStocks'] != null)
          ? (json['cabinDrawrStocks'] as List).map((e) => CabinStockDTO.fromJson(e)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'materialId': materialId,
      'quantity': quantity,
      'isEquivalent': isEquivalent,
      'materialName': materialName,
      'prescriptionItem': prescriptionItem?.toJson(),
      'hospitalizationId': hospitalizationId,
      'stationId': stationId,
      'stationName': stationName,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'sendStationId': sendStationId,
      'sendStationName': sendStationName,
      'sendServiceId': sendServiceId,
      'sendServiceName': sendServiceName,
      'sendUserId': sendUserId,
      'sendUserName': sendUserName,
      'receivedDate': receivedDate?.toIso8601String(),
      'receivedUserId': receivedUserId,
      'receivedUserName': receivedUserName,
      'isCancel': isCancel,
      'cancelUserId': cancelUserId,
      'cancelUserName': cancelUserName,
      'tcNo': tcNo,
      'patientName': patientName,
      'patientSurname': patientSurname,
      'cabinStocks': cabinStocks?.map((e) => e.toJson()).toList(),
    };
  }
}
