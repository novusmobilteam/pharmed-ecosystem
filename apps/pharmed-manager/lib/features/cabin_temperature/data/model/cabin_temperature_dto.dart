import 'package:pharmed_manager/core/core.dart';

import '../../domain/entity/cabin_temperature.dart';

class CabinTemperatureDTO {
  final int? id;
  final int? stationId;
  final StationDTO? station;

  CabinTemperatureDTO({this.stationId, this.station, this.id});

  factory CabinTemperatureDTO.fromJson(Map<String, dynamic> json) {
    return CabinTemperatureDTO(
      id: json["id"],
      stationId: json["stationId"],
      station: json['station'] != null ? StationDTO.fromJson(json['station']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      //"id": id,
      "stationId": stationId,
      //"station": station,
    };
  }

  CabinTemperature toEntity() {
    return CabinTemperature(id: id, station: StationMapper().toEntityOrNull(station));
  }
}
