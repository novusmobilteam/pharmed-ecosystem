import 'package:pharmed_core/pharmed_core.dart';

class EquivalentMedicineDto {
  const EquivalentMedicineDto({
    this.materialId,
    this.materialName,
    this.stockQuantity,
    this.purchaseQuantity,
    this.stocks = const [],
  });

  final int? materialId;
  final String? materialName;
  final double? stockQuantity;
  final double? purchaseQuantity;
  final List<CabinStockDTO> stocks;

  factory EquivalentMedicineDto.fromJson(Map<String, dynamic> json) {
    return EquivalentMedicineDto(
      materialId: json['materialId'] as int?,
      materialName: json['materialName'] as String?,
      stockQuantity: (json['stockQuantity'] as num?)?.toDouble(),
      purchaseQuantity: (json['purchaseQuantity'] as num?)?.toDouble(),
      stocks: json['cabinDrawrStocks'] != null
          ? (json['cabinDrawrStocks'] as List).map((e) => CabinStockDTO.fromJson(e as Map<String, dynamic>)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
    'materialId': materialId,
    'materialName': materialName,
    'stockQuantity': stockQuantity,
    'purchaseQuantity': purchaseQuantity,
  };

  static EquivalentMedicineDto mockFactory(int id) =>
      EquivalentMedicineDto(materialId: id, materialName: 'Mock Material $id', stockQuantity: 100, purchaseQuantity: 1);
}
