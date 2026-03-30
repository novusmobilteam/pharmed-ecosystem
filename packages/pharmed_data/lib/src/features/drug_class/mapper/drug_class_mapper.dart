import 'package:pharmed_core/pharmed_core.dart';

/// DrugClass ↔ DrugClassDTO dönüşümleri.
class DrugClassMapper {
  const DrugClassMapper();

  DrugClass toEntity(DrugClassDTO dto) {
    return DrugClass(id: dto.id, name: dto.name, isActive: dto.isActive ?? false);
  }

  DrugClass? toEntityOrNull(DrugClassDTO? dto) => dto == null ? null : toEntity(dto);

  List<DrugClass> toEntityList(List<DrugClassDTO> dtos) => dtos.map(toEntity).toList();

  DrugClassDTO toDto(DrugClass entity) {
    return DrugClassDTO(id: entity.id, name: entity.name, isActive: entity.isActive);
  }

  DrugClassDTO? toDtoOrNull(DrugClass? entity) => entity == null ? null : toDto(entity);
}
