import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

/// CabinStock ↔ CabinStockDTO dönüşümleri.
class CabinStockMapper {
  const CabinStockMapper();

  CabinStock toEntity(CabinStockDTO dto) {
    return CabinStock(
      id: dto.id,
      cabinId: dto.cabinId,
      cabinDrawerId: dto.cabinDrawerId,
      cabinDrawerDetailId: dto.cabinDrawerDetailId,
      corpartmentNo: dto.corpartmentNo,
      shelfNo: dto.shelfNo,
      quantity: dto.quantity,
      miadDate: dto.miadDate,
      // Alt modeller için ilgili mapper'lar
      medicine: dto.medicine != null ? const MedicineMapper().toEntity(dto.medicine!) : null,
      assignment: dto.cabinDrawerQuantity != null
          ? const MedicineAssignmentMapper().toEntity(dto.cabinDrawerQuantity!)
          : null,
      cabinDrawerDetail: dto.cabinDrawerDetail != null
          ? const DrawerCellMapper().toEntity(dto.cabinDrawerDetail!)
          : null,
    );
  }

  CabinStockDTO toDto(CabinStock entity) {
    return CabinStockDTO(
      id: entity.id,
      cabinId: entity.cabinId,
      cabinDrawerId: entity.cabinDrawerId,
      cabinDrawerDetailId: entity.cabinDrawerDetailId,
      corpartmentNo: entity.corpartmentNo,
      shelfNo: entity.shelfNo,
      quantity: entity.quantity,
      miadDate: entity.miadDate,
      medicine: const MedicineMapper().toDtoOrNull(entity.medicine),
      cabinDrawerQuantity: const MedicineAssignmentMapper().toDtoOrNull(entity.assignment),
      cabinDrawerDetail: const DrawerCellMapper().toDtoOrNull(entity.cabinDrawerDetail),
    );
  }

  List<CabinStock> toEntityList(List<CabinStockDTO> dtos) => dtos.map(toEntity).toList();

  List<CabinStockDTO> toDtoList(List<CabinStock> entities) => entities.map(toDto).toList();

  CabinStock? toEntityOrNull(CabinStockDTO? dto) => dto == null ? null : toEntity(dto);

  CabinStockDTO? toDtoOrNull(CabinStock? entity) => entity == null ? null : toDto(entity);
}
