import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class StationStock {
  final int? id;
  final Cabin? cabin;
  final Medicine? medicine;
  final String? code;
  final num? maxQuantity;
  final num? currentQuantity;
  final num? reservedQuantity;
  final num? remainingQuantity;
  final num? fillingQuantity;

  const StationStock({
    this.id,
    this.cabin,
    this.medicine,
    this.code,
    this.maxQuantity,
    this.currentQuantity,
    this.reservedQuantity,
    this.remainingQuantity,
    this.fillingQuantity,
  });

  StationStock copyWith({
    int? id,
    Cabin? cabin,
    String? code,
    Medicine? medicine,
    int? maxQuantity,
    int? currentQuantity,
    int? reservedQuantity,
    int? remainingQuantity,
    int? fillingQuantity,
  }) {
    return StationStock(
      id: id ?? this.id,
      cabin: cabin ?? this.cabin,
      medicine: medicine ?? this.medicine,
      code: code ?? this.code,
      maxQuantity: maxQuantity ?? this.maxQuantity,
      currentQuantity: currentQuantity ?? this.currentQuantity,
      reservedQuantity: reservedQuantity ?? this.reservedQuantity,
      remainingQuantity: remainingQuantity ?? this.remainingQuantity,
      fillingQuantity: fillingQuantity ?? this.fillingQuantity,
    );
  }

  StationStockDTO toDTO() => StationStockDTO(
    id: id,
    cabin: CabinMapper().toDtoOrNull(cabin),
    code: code,
    barcode: medicine?.barcode,
    medicineId: medicine?.id,
    medicine: MedicineMapper().toDtoOrNull(medicine),
    maxQuantity: maxQuantity,
    currentQuantity: currentQuantity,
    reservedQuantity: reservedQuantity,
    remainingQuantity: remainingQuantity,
    fillingQuantity: fillingQuantity,
  );
}
