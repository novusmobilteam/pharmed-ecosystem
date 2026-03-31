import 'package:pharmed_core/pharmed_core.dart';

/// Firm ↔ FirmDTO dönüşümleri.
class FirmMapper {
  const FirmMapper();

  Firm toEntity(FirmDTO dto) {
    return Firm(
      id: dto.id,
      name: dto.name,
      taxNo: dto.taxNo,
      taxOffice: dto.taxOffice,
      type: firmTypeFromId(dto.firmTypeId),
    );
  }

  Firm? toEntityOrNull(FirmDTO? dto) => dto == null ? null : toEntity(dto);

  List<Firm> toEntityList(List<FirmDTO> dtos) => dtos.map(toEntity).toList();

  FirmDTO toDto(Firm entity) {
    return FirmDTO(
      id: entity.id,
      name: entity.name,
      taxNo: entity.taxNo,
      taxOffice: entity.taxOffice,
      firmTypeId: entity.type?.id,
    );
  }

  FirmDTO? toDtoOrNull(Firm? entity) => entity == null ? null : toDto(entity);
}
