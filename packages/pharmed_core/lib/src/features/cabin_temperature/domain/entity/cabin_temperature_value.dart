class CabinTemperatureValue {
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

  CabinTemperatureValue({
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
}
