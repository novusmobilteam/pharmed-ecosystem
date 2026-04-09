import 'package:pharmed_core/pharmed_core.dart';

class ActiveIngredientMapper {
  const ActiveIngredientMapper();

  ActiveIngredient toEntity(ActiveIngredientDTO dto) {
    return ActiveIngredient(id: dto.id, name: dto.name, isActive: dto.isActive);
  }

  ActiveIngredientDTO toDto(ActiveIngredient entity) {
    return ActiveIngredientDTO(id: entity.id, name: entity.name, isActive: entity.isActive);
  }

  /// Null güvenli Entity dönüşümü
  ActiveIngredient? toEntityOrNull(ActiveIngredientDTO? dto) => dto == null ? null : toEntity(dto);

  /// Liste halinde Entity dönüşümü
  List<ActiveIngredient> toEntityList(List<ActiveIngredientDTO> dtos) => dtos.map(toEntity).toList();

  /// Null güvenli DTO dönüşümü
  ActiveIngredientDTO? toDtoOrNull(ActiveIngredient? entity) => entity == null ? null : toDto(entity);

  /// Liste halinde DTO dönüşümü
  List<ActiveIngredientDTO> toDtoList(List<ActiveIngredient> entities) => entities.map(toDto).toList();
}
