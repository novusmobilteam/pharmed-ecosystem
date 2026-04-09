import 'package:pharmed_core/pharmed_core.dart';

class KitMapper {
  const KitMapper();

  Kit toEntity(KitDto dto) {
    return Kit(id: dto.id, name: dto.name, normalizedName: dto.normalizedName, isActive: dto.isActive);
  }

  KitDto toDto(Kit entity) {
    return KitDto(id: entity.id, name: entity.name, normalizedName: entity.normalizedName, isActive: entity.isActive);
  }

  Kit? toEntityOrNull(KitDto? dto) => dto == null ? null : toEntity(dto);

  List<Kit> toEntityList(List<KitDto> dtos) => dtos.map(toEntity).toList();

  KitDto? toDtoOrNull(Kit? entity) => entity == null ? null : toDto(entity);

  List<KitDto> toDtoList(List<Kit> entities) => entities.map(toDto).toList();
}
