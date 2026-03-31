import 'package:pharmed_core/pharmed_core.dart';

/// DosageForm ↔ DosageFormDTO dönüşümleri.
class DosageFormMapper {
  const DosageFormMapper();

  DosageForm toEntity(DosageFormDTO dto) {
    return DosageForm(id: dto.id, name: dto.name, isActive: dto.isActive);
  }

  DosageForm? toEntityOrNull(DosageFormDTO? dto) => dto == null ? null : toEntity(dto);

  List<DosageForm> toEntityList(List<DosageFormDTO> dtos) => dtos.map(toEntity).toList();

  DosageFormDTO toDto(DosageForm entity) {
    return DosageFormDTO(id: entity.id, name: entity.name, isActive: entity.isActive);
  }

  DosageFormDTO? toDtoOrNull(DosageForm? entity) => entity == null ? null : toDto(entity);
}
