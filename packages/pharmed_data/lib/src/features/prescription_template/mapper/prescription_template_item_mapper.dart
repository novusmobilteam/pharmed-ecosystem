import 'package:pharmed_core/pharmed_core.dart';

/// PrescriptionTemplateItem ↔ PrescriptionTemplateItemDTO dönüşümleri.
class PrescriptionTemplateItemMapper {
  const PrescriptionTemplateItemMapper();

  PrescriptionTemplateItem toEntity(PrescriptionTemplateItemDto dto) {
    return PrescriptionTemplateItem(
      id: dto.id,
      templateId: dto.templateId,
      medicineId: dto.medicineId,
      medicine: dto.medicine?.toEntity(),
      dosePiece: dto.dosePiece,
      times: dto.times,
      requestType: RequestType.fromId(dto.requestTypeId),
      firstDoseEmergency: dto.firstDoseEmergency,
      askDoctor: dto.askDoctor,
      inCaseOfNecessity: dto.inCaseOfNecessity,
      description: dto.description,
    );
  }

  PrescriptionTemplateItemDto toDto(PrescriptionTemplateItem entity) {
    print(entity.times);
    return PrescriptionTemplateItemDto(
      id: entity.id,
      templateId: entity.templateId,
      medicineId: entity.medicineId,
      dosePiece: entity.dosePiece,
      times: entity.times,
      requestTypeId: entity.requestType?.id,
      firstDoseEmergency: entity.firstDoseEmergency,
      askDoctor: entity.askDoctor,
      inCaseOfNecessity: entity.inCaseOfNecessity,
      description: entity.description,
    );
  }

  List<PrescriptionTemplateItem> toEntityList(List<PrescriptionTemplateItemDto> dtos) => dtos.map(toEntity).toList();

  List<PrescriptionTemplateItemDto> toDtoList(List<PrescriptionTemplateItem> entities) => entities.map(toDto).toList();

  PrescriptionTemplateItem? toEntityOrNull(PrescriptionTemplateItemDto? dto) => dto == null ? null : toEntity(dto);

  PrescriptionTemplateItemDto? toDtoOrNull(PrescriptionTemplateItem? entity) => entity == null ? null : toDto(entity);
}
