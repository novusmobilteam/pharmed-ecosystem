import 'package:pharmed_manager/core/core.dart';

import '../../data/model/cabin_temperature_dto.dart';

class CabinTemperature {
  final int? id;
  final Station? station;

  CabinTemperature({this.id, this.station});

  CabinTemperature copyWith({int? id, Station? station}) {
    return CabinTemperature(id: id ?? this.id, station: station ?? this.station);
  }

  CabinTemperatureDTO toDTO() {
    return CabinTemperatureDTO(id: id, stationId: station?.id, station: StationMapper().toDtoOrNull(station));
  }
}
