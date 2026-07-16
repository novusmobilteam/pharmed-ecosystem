import 'package:pharmed_manager/core/core.dart';

class CabinTemperatureDto {
  final int? id;
  final StationDTO? station;
  final CabinDTO? cabin;
  final int? bottomTemperatureInside;
  final int? topTemperatureInside;
  final int? bottomTemperatureOutside;
  final int? topTemperatureOutside;
  final int? bottomLimitHumidity;
  final int? topLimitHumidity;

  CabinTemperatureDto({
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

  factory CabinTemperatureDto.fromJson(Map<String, dynamic> json) {
    return CabinTemperatureDto(
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
      "stationId": station?.id,
      "cabinId": cabin?.id,
      "bottomTemperatureInside": bottomTemperatureInside,
      "topTemperatureInside": topTemperatureInside,
      "bottomTemperatureOutside": bottomTemperatureOutside,
      "topTemperatureOutside": topTemperatureOutside,
      "bottomLimitHumidity": bottomLimitHumidity,
      "topLimitHumidity": topLimitHumidity,
    };
  }
}
