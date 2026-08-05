import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

/// CabinStock ↔ CabinStockDTO dönüşümleri.
class CabinStockMapper {
  const CabinStockMapper();

  CabinStock toEntity(CabinStockDTO dto) {
    final cell = dto.cabinDrawerDetail != null ? const DrawerCellMapper().toEntity(dto.cabinDrawerDetail!) : null;
    final medicine = dto.medicine != null ? const MedicineMapper().toEntity(dto.medicine!) : null;

    // Gerçek bir assignment (cabinDrawerQuantity) varsa onu kullan — bazı
    // servisler bunu dolu döndürüyor olabilir. Yoksa cabinDrawrDetail
    // zincirinden SENTETİK bir MedicineAssignment kur (equivalentCheck ve
    // redirected-order yanıtları gibi, yalnızca DrawerCell zinciri veren
    // servisler için). min/max/critical gibi atama-seviyesi alanlar bu
    // durumda bilinmez, null bırakılır — yalnızca kuyruk kurulumu
    // (cabinDrawerId, drawerUnit, cabinDrawerDetail) için yeterli.
    final assignment = dto.cabinDrawerQuantity != null
        ? const MedicineAssignmentMapper().toEntity(dto.cabinDrawerQuantity!)
        : (cell == null
              ? null
              : MedicineAssignment(
                  cabinDrawerId: cell.drawerUnit?.id,
                  medicine: medicine,
                  drawerUnit: cell.drawerUnit,
                  cabinDrawerDetail: [cell],
                ));

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
      assignment: assignment,
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
