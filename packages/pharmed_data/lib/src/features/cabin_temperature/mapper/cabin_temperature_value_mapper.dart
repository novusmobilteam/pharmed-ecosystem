import 'package:pharmed_core/pharmed_core.dart';

/// CabinTemperatureValue ↔ CabinTemperatureValueDto dönüşümleri.
class CabinTemperatureValueMapper {
  const CabinTemperatureValueMapper();

  CabinTemperatureValue toEntity(CabinTemperatureValueDto dto) {
    return CabinTemperatureValue(
      id: dto.id,
      stationId: dto.stationId,
      createdDate: dto.createdDate,
      stationName: dto.stationName,
      cabinId: dto.cabinId,
      cabinName: dto.cabinName,
      bottomTemperatureInside: dto.bottomTemperatureInside,
      topTemperatureInside: dto.topTemperatureInside,
      bottomTemperatureOutside: dto.bottomTemperatureOutside,
      topTemperatureOutside: dto.topTemperatureOutside,
      bottomLimitHumidity: dto.bottomLimitHumidity,
      topLimitHumidity: dto.topLimitHumidity,
      isInsideTemperatureOutOfRange: dto.isInsideTemperatureOutOfRange,
      isOutsideTemperatureOutOfRange: dto.isOutsideTemperatureOutOfRange,
      isHumidityOutOfRange: dto.isHumidityOutOfRange,
      isOutOfRange: dto.isOutOfRange,
      humidity: dto.humidity,
      insideTemperature: dto.insideTemperature,
      outsideTemperature: dto.outsideTemperature,
    );
  }

  CabinTemperatureValueDto toDto(CabinTemperatureValue entity) {
    return CabinTemperatureValueDto(
      id: entity.id,
      stationId: entity.stationId,
      stationName: entity.stationName,
      cabinId: entity.cabinId,
      cabinName: entity.cabinName,
      bottomTemperatureInside: entity.bottomTemperatureInside,
      topTemperatureInside: entity.topTemperatureInside,
      bottomTemperatureOutside: entity.bottomTemperatureOutside,
      topTemperatureOutside: entity.topTemperatureOutside,
      bottomLimitHumidity: entity.bottomLimitHumidity,
      topLimitHumidity: entity.topLimitHumidity,
      isInsideTemperatureOutOfRange: entity.isInsideTemperatureOutOfRange,
      isOutsideTemperatureOutOfRange: entity.isOutsideTemperatureOutOfRange,
      isHumidityOutOfRange: entity.isHumidityOutOfRange,
      isOutOfRange: entity.isOutOfRange,
    );
  }

  List<CabinTemperatureValue> toEntityList(List<CabinTemperatureValueDto> dtos) => dtos.map(toEntity).toList();

  List<CabinTemperatureValueDto> toDtoList(List<CabinTemperatureValue> entities) => entities.map(toDto).toList();

  CabinTemperatureValue? toEntityOrNull(CabinTemperatureValueDto? dto) => dto == null ? null : toEntity(dto);

  CabinTemperatureValueDto? toDtoOrNull(CabinTemperatureValue? entity) => entity == null ? null : toDto(entity);
}
