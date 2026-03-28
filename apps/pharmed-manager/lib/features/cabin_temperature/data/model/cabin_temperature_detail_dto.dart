import '../../domain/entity/cabin_temperature_detail.dart';
import '../../../station/data/model/station_dto.dart';
import '../../../cabin/data/model/cabin_dto.dart';

class CabinTemperatureDetailDTO {
  final int? id;

  final StationDTO? station;
  final CabinDTO? cabin;

  final int? bottomTemperatureInside;
  final int? topTemperatureInside;
  final int? bottomTemperatureOutside;
  final int? topTemperatureOutside;
  final int? bottomLimitHumidity;
  final int? topLimitHumidity;

  CabinTemperatureDetailDTO({
    this.id,
    this.station,
    this.cabin,
    this.bottomTemperatureInside,
    this.topTemperatureInside,
    this.bottomTemperatureOutside,
    this.topTemperatureOutside,
    this.bottomLimitHumidity,
    this.topLimitHumidity,
  });

  factory CabinTemperatureDetailDTO.fromJson(Map<String, dynamic> json) {
    return CabinTemperatureDetailDTO(
      id: json["id"],
      station: json['cabinTemperatureControlStation'] != null
          ? StationDTO.fromJson(json['cabinTemperatureControlStation'])
          : null,
      cabin: json['cabin'] != null ? CabinDTO.fromJson(json['cabin']) : null,
      bottomTemperatureInside: json["bottomTemperatureInside"],
      topTemperatureInside: json["topTemperatureInside"],
      bottomTemperatureOutside: json["bottomTemperatureOutside"],
      topTemperatureOutside: json["topTemperatureOutside"],
      bottomLimitHumidity: json["bottomLimitHumidity"],
      topLimitHumidity: json["topLimitHumidity"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "cabinTemperatureControlStation": station?.toJson(),
      "cabin": cabin?.toJson(),
      "bottomTemperatureInside": bottomTemperatureInside,
      "topTemperatureInside": topTemperatureInside,
      "bottomTemperatureOutside": bottomTemperatureOutside,
      "topTemperatureOutside": topTemperatureOutside,
      "bottomLimitHumidity": bottomLimitHumidity,
      "topLimitHumidity": topLimitHumidity,
    };
  }

  CabinTemperatureDetail toEntity() {
    return CabinTemperatureDetail(
      id: id,
      station: station?.toEntity(),
      cabin: cabin?.toEntity(),
      bottomTemperatureInside: bottomTemperatureInside,
      topTemperatureInside: topTemperatureInside,
      bottomTemperatureOutside: bottomTemperatureOutside,
      topTemperatureOutside: topTemperatureOutside,
      bottomLimitHumidity: bottomLimitHumidity,
      topLimitHumidity: topLimitHumidity,
    );
  }

  /// Mock factory for test data generation
  static CabinTemperatureDetailDTO mockFactory(int id, {bool withNested = true}) {
    final stationId = ((id - 1) % 10) + 1;
    final cabinId = ((id - 1) % 20) + 1;

    return CabinTemperatureDetailDTO(
      id: id,
      station: withNested ? StationDTO.mockFactory(stationId, withNested: false) : null,
      cabin: withNested ? CabinDTO.mockFactory(cabinId, withNested: false) : null,
      bottomTemperatureInside: 20 + (id % 5),
      topTemperatureInside: 25 + (id % 5),
      bottomTemperatureOutside: 15 + (id % 5),
      topTemperatureOutside: 30 + (id % 5),
      bottomLimitHumidity: 30,
      topLimitHumidity: 60,
    );
  }
}
