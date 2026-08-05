import 'package:equatable/equatable.dart';

class OtherStationMedicine extends Equatable {
  const OtherStationMedicine({
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

  @override
  List<Object?> get props => [
    stationId,
    stationName,
    serviceName,
    materialId,
    materialName,
    stockQuantity,
    purchaseQuantity,
    isEquivalent,
  ];
}
