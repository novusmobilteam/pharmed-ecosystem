import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

/// Bed ↔ BedDto dönüşümleri.
class BedMapper {
  const BedMapper();

  Bed toEntity(BedDto dto) {
    return Bed(id: dto.id, roomId: dto.roomId, name: dto.name, room: RoomMapper().toEntityOrNull(dto.room));
  }

  Bed? toEntityOrNull(BedDto? dto) => dto == null ? null : toEntity(dto);

  List<Bed> toEntityList(List<BedDto> dtos) => dtos.map(toEntity).toList();

  BedDto toDto(Bed entity) {
    return BedDto(id: entity.id, name: entity.name, roomId: entity.roomId);
  }

  BedDto? toDtoOrNull(Bed? entity) => entity == null ? null : toDto(entity);

  List<BedDto>? toDtoList(List<Bed>? entities) => entities == null ? null : entities.map((e) => toDto(e)).toList();
}
