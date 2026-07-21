import 'package:pharmed_core/pharmed_core.dart';

class CabinTemperature {
  final int? id;
  final Station? station;
  final Cabin? cabin;
  final int? bottomTemperatureInside;
  final int? topTemperatureInside;
  final int? bottomTemperatureOutside;
  final int? topTemperatureOutside;
  final int? bottomLimitHumidity;
  final int? topLimitHumidity;

  CabinTemperature({
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

  CabinTemperature copyWith({
    int? id,
    Station? station,
    Cabin? cabin,
    int? bottomTemperatureInside,
    int? topTemperatureInside,
    int? bottomTemperatureOutside,
    int? topTemperatureOutside,
    int? bottomLimitHumidity,
    int? topLimitHumidity,
  }) {
    return CabinTemperature(
      id: id ?? this.id,
      station: station ?? this.station,
      cabin: cabin ?? this.cabin,
      bottomTemperatureInside: bottomTemperatureInside ?? this.bottomTemperatureInside,
      topTemperatureInside: topTemperatureInside ?? this.topTemperatureInside,
      bottomTemperatureOutside: bottomTemperatureOutside ?? this.bottomTemperatureOutside,
      topTemperatureOutside: topTemperatureOutside ?? this.topTemperatureOutside,
      bottomLimitHumidity: bottomLimitHumidity ?? this.bottomLimitHumidity,
      topLimitHumidity: topLimitHumidity ?? this.topLimitHumidity,
    );
  }
}
