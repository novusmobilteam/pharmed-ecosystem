class OtherStationMedicineDTO {
  const OtherStationMedicineDTO({
    this.stationId,
    this.stationName,
    this.serviceName,
    this.materialId,
    this.materialName,
    this.stockQuantity,
    this.purchaseQuantity,
    this.isEquivalent = false,
  });

  final int? stationId;
  final String? stationName;
  final String? serviceName;
  final int? materialId;
  final String? materialName;
  final double? stockQuantity;
  final double? purchaseQuantity;
  final bool isEquivalent;

  factory OtherStationMedicineDTO.fromJson(Map<String, dynamic> json) => OtherStationMedicineDTO(
    stationId: json['stationId'] as int?,
    stationName: json['stationName'] as String?,
    serviceName: json['serviceName'] as String?,
    materialId: json['materialId'] as int?,
    materialName: json['materialName'] as String?,
    stockQuantity: (json['stockQuantity'] as num?)?.toDouble(),
    purchaseQuantity: (json['purchaseQuantity'] as num?)?.toDouble(),
    isEquivalent: json['isEquivalent'] as bool? ?? false,
  );
}
