import '../../domain/entity/directed_order.dart';
import '../../../station/data/model/station_dto.dart';
import '../../../prescription/data/model/prescription_item_dto.dart';

class DirectedOrderDTO {
  final int? id;
  final StationDTO? station;
  final PrescriptionItemDTO? medicine;

  DirectedOrderDTO({
    this.id,
    this.station,
    this.medicine,
  });

  factory DirectedOrderDTO.fromJson(Map<String, dynamic> json) {
    return DirectedOrderDTO(
      id: json['id'] as int?,
      station: json['station'] != null ? StationDTO.fromJson(json['station']) : null,
      medicine: json['medicine'] != null ? PrescriptionItemDTO.fromJson(json['medicine']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'station': station,
      'medicine': medicine,
    };
  }

  DirectedOrderDTO copyWith({
    int? id,
    StationDTO? station,
    PrescriptionItemDTO? medicine,
  }) {
    return DirectedOrderDTO(
      id: id ?? this.id,
      station: station ?? this.station,
      medicine: medicine ?? this.medicine,
    );
  }

  DirectedOrder toEntity() {
    return DirectedOrder(
      id: id,
      station: station?.toEntity(),
      item: medicine?.toEntity(),
    );
  }

  /// Mock factory for test data generation
  static DirectedOrderDTO mockFactory(int id, {bool withNested = true}) {
    final stationId = ((id - 1) % 10) + 1;
    final medicineId = 1000 + id;

    return DirectedOrderDTO(
      id: id,
      station: withNested ? StationDTO.mockFactory(stationId, withNested: false) : null,
      medicine: withNested ? PrescriptionItemDTO.mockFactory(medicineId, withNested: false) : null,
    );
  }
}
