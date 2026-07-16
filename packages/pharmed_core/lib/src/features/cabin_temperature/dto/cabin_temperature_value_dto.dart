class CabinTemperatureValueDto {
  final int? id;
  final DateTime? createdDate;
  final int? stationId;
  final String? stationName;
  final int? cabinId;
  final String? cabinName;
  final double? insideTemperature;
  final int? outsideTemperature;
  final double? humidity;
  final int? bottomTemperatureInside;
  final int? topTemperatureInside;
  final int? bottomTemperatureOutside;
  final int? topTemperatureOutside;
  final int? bottomLimitHumidity;
  final int? topLimitHumidity;
  final bool? isInsideTemperatureOutOfRange;
  final bool? isOutsideTemperatureOutOfRange;
  final bool? isHumidityOutOfRange;
  final bool? isOutOfRange;

  CabinTemperatureValueDto({
    this.id,
    this.createdDate,
    this.stationId,
    this.stationName,
    this.cabinId,
    this.cabinName,
    this.insideTemperature,
    this.outsideTemperature,
    this.humidity,
    this.bottomTemperatureInside,
    this.topTemperatureInside,
    this.bottomTemperatureOutside,
    this.topTemperatureOutside,
    this.bottomLimitHumidity,
    this.topLimitHumidity,
    this.isInsideTemperatureOutOfRange,
    this.isOutsideTemperatureOutOfRange,
    this.isHumidityOutOfRange,
    this.isOutOfRange,
  });

  factory CabinTemperatureValueDto.fromJson(Map<String, dynamic> json) {
    return CabinTemperatureValueDto(
      id: json["id"],
      createdDate: json['dateTime'] != null ? DateTime.tryParse(json['dateTime']) : null,
      stationId: json["stationId"],
      stationName: json["stationName"],
      cabinId: json["cabinId"],
      cabinName: json["cabinName"],
      insideTemperature: json["insideTemperature"],
      outsideTemperature: json["outsideTemperature"],
      humidity: json["humidity"],
      bottomTemperatureInside: json["bottomTemperatureInside"],
      topTemperatureInside: json["topTemperatureInside"],
      bottomTemperatureOutside: json["bottomTemperatureOutside"],
      topTemperatureOutside: json["topTemperatureOutside"],
      bottomLimitHumidity: json["bottomLimitHumidity"],
      topLimitHumidity: json["topLimitHumidity"],
      isInsideTemperatureOutOfRange: json["isInsideTemperatureOutOfRange"],
      isOutsideTemperatureOutOfRange: json["isOutsideTemperatureOutOfRange"],
      isHumidityOutOfRange: json["isHumidityOutOfRange"],
      isOutOfRange: json["isOutOfRange"],
    );
  }
}
