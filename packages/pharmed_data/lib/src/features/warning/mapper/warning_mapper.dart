import 'package:pharmed_core/pharmed_core.dart';

class WarningMapper {
  const WarningMapper();

  Warning toEntity(WarningDto dto) {
    return Warning(
      id: dto.id,
      subject: WarningSubject.fromId(dto.warningSubjectId),
      text: dto.text,
      isActive: dto.isActive,
    );
  }

  WarningDto toDto(Warning entity) {
    return WarningDto(
      id: entity.id,
      warningSubjectId: entity.subject?.id,
      text: entity.text,
      isActive: entity.isActive,
    );
  }

  Warning? toEntityOrNull(WarningDto? dto) => dto == null ? null : toEntity(dto);

  List<Warning> toEntityList(List<WarningDto> dtos) => dtos.map(toEntity).toList();

  WarningDto? toDtoOrNull(Warning? entity) => entity == null ? null : toDto(entity);

  List<WarningDto> toDtoList(List<Warning> entities) => entities.map(toDto).toList();
}
