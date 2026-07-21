import 'package:pharmed_core/pharmed_core.dart';

class SystemParameterMapper {
  const SystemParameterMapper();

  SystemParameter toEntity(SystemParameterDTO dto) {
    return SystemParameter(
      id: dto.id,
      type: dto.type,
      category: dto.category,
      key: dto.key,
      value: dto.value,
      description: dto.description,
      isDeleted: dto.isDeleted,
    );
  }

  SystemParameterDTO toDto(SystemParameter entity) {
    return SystemParameterDTO(
      id: entity.id,
      type: entity.type,
      category: entity.category,
      key: entity.key,
      value: entity.value,
      description: entity.description,
      isDeleted: entity.isDeleted,
    );
  }

  SystemParameter? toEntityOrNull(SystemParameterDTO? dto) => dto == null ? null : toEntity(dto);

  List<SystemParameter> toEntityList(List<SystemParameterDTO> dtos) => dtos.map(toEntity).toList();

  SystemParameterDTO? toDtoOrNull(SystemParameter? entity) => entity == null ? null : toDto(entity);

  List<SystemParameterDTO> toDtoList(List<SystemParameter> entities) => entities.map(toDto).toList();
}
