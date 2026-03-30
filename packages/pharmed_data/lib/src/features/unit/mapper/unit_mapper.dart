import 'package:pharmed_core/pharmed_core.dart';

/// Unit ↔ Unit dönüşümleri.
class UnitMapper {
  const UnitMapper();

  Unit toEntity(UnitDTO dto) {
    return Unit(id: dto.id, name: dto.name, status: statusFromBool(dto.isActive ?? false));
  }

  Unit? toEntityOrNull(UnitDTO? dto) => dto == null ? null : toEntity(dto);

  List<Unit> toEntityList(List<UnitDTO> dtos) => dtos.map(toEntity).toList();

  UnitDTO toDto(Unit entity) {
    return UnitDTO(id: entity.id, name: entity.name, isActive: entity.status?.isActive);
  }

  UnitDTO? toDtoOrNull(Unit? entity) => entity == null ? null : toDto(entity);
}
