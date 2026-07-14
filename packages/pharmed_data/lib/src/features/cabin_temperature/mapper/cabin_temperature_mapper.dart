import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

/// CabinTemperature ↔ CabinTemperatureDto dönüşümleri.
class CabinTemperatureMapper {
  const CabinTemperatureMapper();

  CabinTemperature toEntity(CabinTemperatureDto dto) {
    return CabinTemperature(
      id: dto.id,
      station: const StationMapper().toEntityOrNull(dto.station),
      cabin: const CabinMapper().toEntityOrNull(dto.cabin),
      bottomTemperatureInside: dto.bottomTemperatureInside,
      topTemperatureInside: dto.topTemperatureInside,
      bottomTemperatureOutside: dto.bottomTemperatureOutside,
      topTemperatureOutside: dto.topTemperatureOutside,
      bottomLimitHumidity: dto.bottomLimitHumidity,
      topLimitHumidity: dto.topLimitHumidity,
    );
  }

  CabinTemperatureDto toDto(CabinTemperature entity) {
    return CabinTemperatureDto(
      id: entity.id,
      station: const StationMapper().toDtoOrNull(entity.station),
      cabin: const CabinMapper().toDtoOrNull(entity.cabin),
      bottomTemperatureInside: entity.bottomTemperatureInside,
      topTemperatureInside: entity.topTemperatureInside,
      bottomTemperatureOutside: entity.bottomTemperatureOutside,
      topTemperatureOutside: entity.topTemperatureOutside,
      bottomLimitHumidity: entity.bottomLimitHumidity,
      topLimitHumidity: entity.topLimitHumidity,
    );
  }

  List<CabinTemperature> toEntityList(List<CabinTemperatureDto> dtos) => dtos.map(toEntity).toList();

  List<CabinTemperatureDto> toDtoList(List<CabinTemperature> entities) => entities.map(toDto).toList();

  CabinTemperature? toEntityOrNull(CabinTemperatureDto? dto) => dto == null ? null : toEntity(dto);

  CabinTemperatureDto? toDtoOrNull(CabinTemperature? entity) => entity == null ? null : toDto(entity);
}
