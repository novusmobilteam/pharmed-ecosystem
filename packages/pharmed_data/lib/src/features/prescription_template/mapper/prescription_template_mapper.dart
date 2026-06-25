import 'package:pharmed_core/pharmed_core.dart';

/// PrescriptionTemplate ↔ PrescriptionTemplateDTO dönüşümleri.
class PrescriptionTemplateMapper {
  const PrescriptionTemplateMapper();

  PrescriptionTemplate toEntity(PrescriptionTemplateDto dto) {
    return PrescriptionTemplate(
      id: dto.id,
      name: dto.name,
      createdUserId: dto.createdUserId,
      createdDate: dto.createdDate,
    );
  }

  PrescriptionTemplateDto toDto(PrescriptionTemplate entity) {
    return PrescriptionTemplateDto(
      id: entity.id,
      name: entity.name,
      createdUserId: entity.createdUserId,
      createdDate: entity.createdDate,
    );
  }

  List<PrescriptionTemplate> toEntityList(List<PrescriptionTemplateDto> dtos) => dtos.map(toEntity).toList();

  List<PrescriptionTemplateDto> toDtoList(List<PrescriptionTemplate> entities) => entities.map(toDto).toList();

  PrescriptionTemplate? toEntityOrNull(PrescriptionTemplateDto? dto) => dto == null ? null : toEntity(dto);

  PrescriptionTemplateDto? toDtoOrNull(PrescriptionTemplate? entity) => entity == null ? null : toDto(entity);
}
