import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/src/features/service/mapper/bed_mapper.dart';

/// Room ↔ RoomDto dönüşümleri.
class RoomMapper {
  const RoomMapper();

  Room toEntity(RoomDto dto) {
    return Room(id: dto.id, serviceId: dto.serviceId, name: dto.name, beds: BedMapper().toEntityList(dto.beds ?? []));
  }

  Room? toEntityOrNull(RoomDto? dto) => dto == null ? null : toEntity(dto);

  List<Room> toEntityList(List<RoomDto> dtos) => dtos.map(toEntity).toList();

  RoomDto toDto(Room entity) {
    return RoomDto(
      id: entity.id,
      name: entity.name,
      serviceId: entity.serviceId,
      beds: BedMapper().toDtoList(entity.beds),
    );
  }

  RoomDto? toDtoOrNull(Room? entity) => entity == null ? null : toDto(entity);

  List<RoomDto>? toDtoList(List<Room>? entities) => entities == null ? null : entities.map((e) => toDto(e)).toList();
}
