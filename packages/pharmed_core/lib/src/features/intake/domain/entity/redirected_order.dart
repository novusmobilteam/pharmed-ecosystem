import 'package:pharmed_core/pharmed_core.dart';

class RedirectedOrder {
  final int? id;
  final int? materialId;
  final num? quantity;
  final bool? isEquivalent;
  final String? materialName;
  final PrescriptionItem? prescriptionItem;
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
  final List<CabinStock>? cabinStocks;

  RedirectedOrder({
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
}
