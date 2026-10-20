class UnorderedLoadedMaterialDto {
  final int? stationId;
  final String? stationName;
  final int? materialId;
  final String? materialName;
  final String? barcode;
  final double? quantity;

  const UnorderedLoadedMaterialDto({
    this.stationId,
    this.stationName,
    this.materialId,
    this.materialName,
    this.barcode,
    this.quantity,
  });

  factory UnorderedLoadedMaterialDto.fromJson(Map<String, dynamic> json) {
    return UnorderedLoadedMaterialDto(
      stationId: json['stationId'] as int?,
      stationName: json['stationName'] as String?,
      materialId: json['materialId'] as int?,
      materialName: json['materialName'] as String?,
      barcode: json['barcode'] as String?,
      quantity: (json['quantity'] as num?)?.toDouble(),
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
    };
  }
}
