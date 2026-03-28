import '../../../medicine/data/model/medicine_dto.dart';
import '../../../station/data/model/station_dto.dart';
import '../../domain/entity/station_stock.dart';

class StationStockDTO {
  final int? id;
  final int? stationId;
  final StationDTO? station;
  final String? code;
  final String? barcode;
  final int? medicineId;
  final MedicineDTO? medicine;
  final num? maxQuantity;
  final num? currentQuantity;
  final num? reservedQuantity;
  final num? remainingQuantity;
  final num? fillingQuantity;

  const StationStockDTO({
    this.id,
    this.stationId,
    this.station,
    this.code,
    this.barcode,
    this.medicineId,
    this.medicine,
    this.maxQuantity,
    this.currentQuantity,
    this.reservedQuantity,
    this.remainingQuantity,
    this.fillingQuantity,
  });

  factory StationStockDTO.fromJson(Map<String, dynamic> json) {
    return StationStockDTO(
      id: json['id'] as int?,
      stationId: json['stationId'] as int?,
      station: json['station'] != null ? StationDTO.fromJson(json['station']) : null,
      code: json['code'] as String?,
      barcode: json['barcode'] as String?,
      medicineId: json['materialId'] as int?,
      medicine: json['material'] != null ? MedicineDTO.fromJson(json['material']) : null,
      maxQuantity: json['maxQuantity'],
      currentQuantity: json['currentQuantity'],
      reservedQuantity: json['reservedQuantity'],
      remainingQuantity: json['remainingQuantity'],
      fillingQuantity: json['fillingQuantity'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'stationId': stationId,
        'station': station,
        'code': code,
        'barcode': barcode,
        'materialId': medicineId,
        //'materialName': medicine?.toEntity(),
        'maxQuantity': maxQuantity,
        'currentQuantity': currentQuantity,
        'reservedQuantity': reservedQuantity,
        'remainingQuantity': remainingQuantity,
        'fillingQuantity': fillingQuantity,
      };

  StationStockDTO copyWith({
    int? id,
    int? stationId,
    StationDTO? station,
    String? code,
    String? barcode,
    int? medicineId,
    MedicineDTO? medicine,
    num? maxQuantity,
    num? currentQuantity,
    num? reservedQuantity,
    num? remainingQuantity,
    num? fillingQuantity,
  }) {
    return StationStockDTO(
      id: id ?? this.id,
      stationId: stationId ?? this.stationId,
      station: station ?? this.station,
      code: code ?? this.code,
      barcode: barcode ?? this.barcode,
      medicineId: medicineId ?? this.medicineId,
      medicine: medicine ?? this.medicine,
      maxQuantity: maxQuantity ?? this.maxQuantity,
      currentQuantity: currentQuantity ?? this.currentQuantity,
      reservedQuantity: reservedQuantity ?? this.reservedQuantity,
      remainingQuantity: remainingQuantity ?? this.remainingQuantity,
      fillingQuantity: fillingQuantity ?? this.fillingQuantity,
    );
  }

  StationStock toEntity() => StationStock(
        id: id,
        station: station?.toEntity(),
        code: code,
        medicine: medicine?.toEntity(),
        maxQuantity: maxQuantity,
        currentQuantity: currentQuantity,
        reservedQuantity: reservedQuantity,
        remainingQuantity: remainingQuantity,
        fillingQuantity: fillingQuantity,
      );
}
