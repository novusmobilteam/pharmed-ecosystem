import 'package:pharmed_core/pharmed_core.dart';

class InertMaterialDto {
  final int? stationId;
  final String? stationName;
  final int? materialId;
  final String? materialName;
  final String? barcode;
  final double? quantity;
  final MedicineDto? material;

  const InertMaterialDto({
    this.stationId,
    this.stationName,
    this.materialId,
    this.materialName,
    this.barcode,
    this.quantity,
    this.material,
  });

  factory InertMaterialDto.fromJson(Map<String, dynamic> json) {
    return InertMaterialDto(
      stationId: json['stationId'] as int?,
      stationName: json['stationName'] as String?,
      materialId: json['materialId'] as int?,
      materialName: json['materialName'] as String?,
      barcode: json['barcode'] as String?,
      quantity: (json['quantity'] as num?)?.toDouble(),
      material: json['material'] is Map<String, dynamic>
          ? MedicineDto.fromJson(json['material'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (stationId != null) 'stationId': stationId,
      if (stationName != null) 'stationName': stationName,
      if (materialId != null) 'materialId': materialId,
      if (materialName != null) 'materialName': materialName,
      if (barcode != null) 'barcode': barcode,
      if (quantity != null) 'quantity': quantity,
      if (material != null) 'material': material!.toJson(),
    };
  }
}
