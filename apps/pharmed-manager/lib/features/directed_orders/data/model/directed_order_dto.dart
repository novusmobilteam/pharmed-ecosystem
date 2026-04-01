import 'package:pharmed_manager/core/core.dart';

import '../../domain/entity/directed_order.dart';

class DirectedOrderDTO {
  final int? id;
  final StationDTO? station;
  final PrescriptionItemDTO? medicine;

  DirectedOrderDTO({this.id, this.station, this.medicine});

  factory DirectedOrderDTO.fromJson(Map<String, dynamic> json) {
    return DirectedOrderDTO(
      id: json['id'] as int?,
      station: json['station'] != null ? StationDTO.fromJson(json['station']) : null,
      medicine: json['medicine'] != null ? PrescriptionItemDTO.fromJson(json['medicine']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'station': station, 'medicine': medicine};
  }

  DirectedOrderDTO copyWith({int? id, StationDTO? station, PrescriptionItemDTO? medicine}) {
    return DirectedOrderDTO(id: id ?? this.id, station: station ?? this.station, medicine: medicine ?? this.medicine);
  }

  DirectedOrder toEntity() {
    return DirectedOrder(
      id: id,
      station: StationMapper().toEntityOrNull(station),
      item: PrescriptionItemMapper().toEntityOrNull(medicine),
    );
  }
}
