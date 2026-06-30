import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class CabinExpectedEpcMapper {
  const CabinExpectedEpcMapper();

  CabinExpectedEpc toEntity(CabinExpectedEpcDto dto) {
    return CabinExpectedEpc(
      id: dto.id,
      cabinId: dto.cabinId,
      cabinStockId: dto.cabinStockId,
      rfidTag: dto.rfidTag,
      isActive: dto.isActive,
      prescriptionItemId: dto.prescriptionItemId,
      cabinStock: CabinStockMapper().toEntityOrNull(dto.cabinStock),
      prescriptionItem: PrescriptionItemMapper().toEntityOrNull(dto.prescriptionItem),
    );
  }

  CabinExpectedEpcDto toDto(CabinExpectedEpc entity) {
    return CabinExpectedEpcDto(
      id: entity.id,
      cabinId: entity.cabinId,
      cabinStockId: entity.cabinStockId,
      rfidTag: entity.rfidTag,
      isActive: entity.isActive,
      prescriptionItemId: entity.prescriptionItemId,
      cabinStock: CabinStockMapper().toDtoOrNull(entity.cabinStock),
      prescriptionItem: PrescriptionItemMapper().toDtoOrNull(entity.prescriptionItem),
    );
  }

  List<CabinExpectedEpc> toEntityList(List<CabinExpectedEpcDto> dtos) => dtos.map(toEntity).toList();

  List<CabinExpectedEpcDto> toDtoList(List<CabinExpectedEpc> entities) => entities.map(toDto).toList();

  CabinExpectedEpc? toEntityOrNull(CabinExpectedEpcDto? dto) => dto == null ? null : toEntity(dto);

  CabinExpectedEpcDto? toDtoOrNull(CabinExpectedEpc? entity) => entity == null ? null : toDto(entity);
}
