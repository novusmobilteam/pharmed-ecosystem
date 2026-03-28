import '../../domain/entity/cabin_temperature.dart';
import '../../../station/data/model/station_dto.dart';

class CabinTemperatureDTO {
  final int? id;
  final int? stationId;
  final StationDTO? station;

  CabinTemperatureDTO({
    this.stationId,
    this.station,
    this.id,
  });

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
    return CabinTemperature(
      id: id,
      station: station?.toEntity(),
    );
  }

  /// Mock factory for test data generation
  static CabinTemperatureDTO mockFactory(int id, {bool withNested = true}) {
    final stationId = ((id - 1) % 10) + 1;

    return CabinTemperatureDTO(
      id: id,
      stationId: stationId,
      station: withNested ? StationDTO.mockFactory(stationId, withNested: false) : null,
    );
  }
}
