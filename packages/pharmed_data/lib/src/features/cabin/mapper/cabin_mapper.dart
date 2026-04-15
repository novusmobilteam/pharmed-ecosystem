import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/src/features/station/mapper/station_mapper.dart';

/// Cabin ↔ CabinDTO dönüşümleri.
class CabinMapper {
  const CabinMapper();

  Cabin toEntity(CabinDTO dto) {
    return Cabin(
      id: dto.id,
      name: dto.name,
      stationId: dto.stationId,
      station: StationMapper().toEntityOrNull(dto.station),
      comPort: ComPort.fromId(dto.comPortsId),
      dvrIp: dto.dvrIp,
      isRfidEnabled: dto.isRfidEnabled,
      rfidIp: dto.rfidIp,
      rfidPort: dto.rfidPort,
      bedIds: dto.bedIds,
      type: CabinType.fromId(dto.type),
    );
  }

  Cabin? toEntityOrNull(CabinDTO? dto) => dto == null ? null : toEntity(dto);

  List<Cabin> toEntityList(List<CabinDTO> dtos) => dtos.map(toEntity).toList();

  CabinDTO toDto(Cabin entity) {
    return CabinDTO(
      id: entity.id,
      name: entity.name,
      type: entity.type?.id,
      stationId: entity.stationId,
      station: StationMapper().toDtoOrNull(entity.station),
      comPortsId: entity.comPort?.id,
      dvrIp: entity.dvrIp,
      isActive: entity.status?.isActive,
      isRfidEnabled: entity.isRfidEnabled,
      rfidIp: entity.rfidIp,
      rfidPort: entity.rfidPort,
      bedIds: entity.bedIds,
    );
  }

  CabinDTO? toDtoOrNull(Cabin? entity) => entity == null ? null : toDto(entity);

  List<CabinDTO> toDtoList(List<Cabin> entities) => entities.map(toDto).toList();
}
