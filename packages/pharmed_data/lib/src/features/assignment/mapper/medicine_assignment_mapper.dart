import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

/// CabinAssignment ↔ CabinAssignmentDTO dönüşümleri.
class MedicineAssignmentMapper {
  const MedicineAssignmentMapper();

  MedicineAssignment toEntity(MedicineAssignmentDto dto) {
    return MedicineAssignment(
      id: dto.id,
      cabinDrawerId: dto.cabinDrawerId,
      minQuantity: dto.minQuantity,
      criticalQuantity: dto.criticalQuantity,
      maxQuantity: dto.maxQuantity,
      // Cabin, Medicine ve DrawerUnit için ilgili mapper'ları kullanıyoruz
      cabin: const CabinMapper().toEntityOrNull(dto.cabin),
      medicine: dto.medicine != null ? const MedicineMapper().toEntity(dto.medicine!) : null,
      drawerUnit: const DrawerUnitMapper().toEntityOrNull(dto.cabinDrawer),
      // Listelerin dönüşümü
      cabinDrawerDetail: dto.cabinDrawerDetail != null
          ? const DrawerCellMapper().toEntityList(dto.cabinDrawerDetail!)
          : null,
      stocks: dto.stocks != null ? const CabinStockMapper().toEntityList(dto.stocks!) : null,
    );
  }

  MedicineAssignmentDto toDto(MedicineAssignment entity) {
    return MedicineAssignmentDto(
      id: entity.id,
      cabinDrawerId: entity.cabinDrawerId,
      minQuantity: entity.minQuantity,
      criticalQuantity: entity.criticalQuantity,
      maxQuantity: entity.maxQuantity,
      cabin: const CabinMapper().toDtoOrNull(entity.cabin),
      medicine: const MedicineMapper().toDtoOrNull(entity.medicine),
      cabinDrawer: const DrawerUnitMapper().toDtoOrNull(entity.drawerUnit),
      // Entity içindeki listeleri DTO listesine çeviriyoruz
      cabinDrawerDetail: entity.cabinDrawerDetail != null
          ? const DrawerCellMapper().toDtoList(entity.cabinDrawerDetail!)
          : null,
      stocks: entity.stocks != null ? const CabinStockMapper().toDtoList(entity.stocks!) : null,
    );
  }

  List<MedicineAssignment> toEntityList(List<MedicineAssignmentDto> dtos) => dtos.map(toEntity).toList();

  List<MedicineAssignmentDto> toDtoList(List<MedicineAssignment> entities) => entities.map(toDto).toList();

  MedicineAssignment? toEntityOrNull(MedicineAssignmentDto? dto) => dto == null ? null : toEntity(dto);

  MedicineAssignmentDto? toDtoOrNull(MedicineAssignment? entity) => entity == null ? null : toDto(entity);
}
