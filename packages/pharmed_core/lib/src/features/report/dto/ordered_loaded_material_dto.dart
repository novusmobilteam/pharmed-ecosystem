import 'package:pharmed_core/pharmed_core.dart';

class OrderedLoadedMaterialDto {
  final String? serviceName;
  final int? stationId;
  final String? stationName;
  final String? cabinName;
  final String? cabinCode;
  final String? materialName;
  final String? barcode;
  final MedicineDto? material;

  const OrderedLoadedMaterialDto({
    this.serviceName,
    this.stationId,
    this.stationName,
    this.cabinName,
    this.cabinCode,
    this.materialName,
    this.barcode,
    this.material,
  });

  factory OrderedLoadedMaterialDto.fromJson(Map<String, dynamic> json) {
    return OrderedLoadedMaterialDto(
      serviceName: json['serviceName'] as String?,
      stationId: json['stationId'] as int?,
      stationName: json['stationName'] as String?,
      cabinName: json['cabinName'] as String?,
      cabinCode: json['cabinCode'] as String?,
      materialName: json['materialName'] as String?,
      barcode: json['barcode'] as String?,
      material: json['material'] is Map<String, dynamic>
          ? MedicineDto.fromJson(json['material'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (serviceName != null) 'serviceName': serviceName,
      if (stationId != null) 'stationId': stationId,
      if (stationName != null) 'stationName': stationName,
      if (cabinName != null) 'cabinName': cabinName,
      if (cabinCode != null) 'cabinCode': cabinCode,
      if (materialName != null) 'materialName': materialName,
      if (barcode != null) 'barcode': barcode,
      if (material != null) 'material': material!.toJson(),
    };
  }
}
