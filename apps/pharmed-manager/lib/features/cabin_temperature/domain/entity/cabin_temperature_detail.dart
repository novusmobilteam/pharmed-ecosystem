import '../../../../core/core.dart';
import '../../data/model/cabin_temperature_detail_dto.dart';
import '../../../cabin/domain/entity/cabin.dart';
import '../../../station/domain/entity/station.dart';

class CabinTemperatureDetail implements TableData {
  final int? id;
  final Station? station;
  final Cabin? cabin;
  final int? bottomTemperatureInside;
  final int? topTemperatureInside;
  final int? bottomTemperatureOutside;
  final int? topTemperatureOutside;
  final int? bottomLimitHumidity;
  final int? topLimitHumidity;

  @override
  List get content => [
        cabin?.name,
        bottomTemperatureInside?.toCustomString(),
        topTemperatureInside?.toCustomString(),
        bottomTemperatureOutside?.toCustomString(),
        topTemperatureOutside?.toCustomString(),
        bottomLimitHumidity?.toCustomString(),
        topLimitHumidity?.toCustomString(),
      ];

  @override
  List get rawContent => [
        cabin?.name,
        bottomTemperatureInside,
        topTemperatureInside,
        bottomTemperatureOutside,
        topTemperatureOutside,
        bottomLimitHumidity,
        topLimitHumidity,
      ];

  @override
  List<String?> get titles => [
        'Kabin',
        'İç Alt Sıcaklık',
        'İç Üst Sıcaklık',
        'Dış Alt Sıcaklık',
        'Dış Üst Sıcaklık',
        'Nem Alt Sınır',
        'Nem Üst Sınır',
      ];

  CabinTemperatureDetail({
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

  CabinTemperatureDetail copyWith({
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
    return CabinTemperatureDetail(
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

  CabinTemperatureDetailDTO toDTO() {
    return CabinTemperatureDetailDTO(
      id: id,
      station: station?.toDTO(),
      cabin: cabin?.toDTO(),
      bottomTemperatureInside: bottomTemperatureInside,
      topTemperatureInside: topTemperatureInside,
      bottomTemperatureOutside: bottomTemperatureOutside,
      topTemperatureOutside: topTemperatureOutside,
      bottomLimitHumidity: bottomLimitHumidity,
      topLimitHumidity: topLimitHumidity,
    );
  }
}
