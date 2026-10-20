import 'package:pharmed_core/pharmed_core.dart';

class HospitalStock {
  final int? serviceId;
  final String? serviceName;
  final int? materialId;
  final String? materialName;
  final String? code;
  final num? quantity;
  final Medicine? medicine;

  HospitalStock({
    this.serviceId,
    this.serviceName,
    this.materialId,
    this.materialName,
    this.quantity,
    this.code,
    this.medicine,
  });
}
