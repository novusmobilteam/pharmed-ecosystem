import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';
import 'package:pharmed_utils/pharmed_utils.dart';

class StationStock implements TableData {
  final int? id;
  final Station? station;
  final Medicine? medicine;
  final String? code;
  final num? maxQuantity;
  final num? currentQuantity;
  final num? reservedQuantity;
  final num? remainingQuantity;
  final num? fillingQuantity;

  @override
  List<String?> get content => [
    code,
    medicine?.barcode,
    medicine?.name,
    maxQuantity?.toCustomString(),
    currentQuantity?.toCustomString(),
    reservedQuantity?.toCustomString(),
    remainingQuantity?.toCustomString(),
    fillingQuantity?.toCustomString(),
  ];

  @override
  List get rawContent => [
    code,
    medicine?.barcode,
    medicine?.name,
    maxQuantity,
    currentQuantity,
    reservedQuantity,
    remainingQuantity,
    fillingQuantity,
  ];

  @override
  List<String?> get titles => ['Kod', 'Barkod', 'Malzeme', 'Maks.', 'Mevcut', 'Rezerve', 'Kalan', 'Dolum'];

  const StationStock({
    this.id,
    this.station,
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
    Station? station,
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
      station: station ?? this.station,
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
    stationId: station?.id,
    station: StationMapper().toDtoOrNull(station),
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
