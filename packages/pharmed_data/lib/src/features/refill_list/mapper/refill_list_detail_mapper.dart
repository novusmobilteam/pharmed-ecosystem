import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class RefillListDetailMapper {
  const RefillListDetailMapper();

  RefillListDetail toEntity(RefillListDetailDto dto) {
    return RefillListDetail(
      id: dto.id,
      fillingListId: dto.fillingListId,
      medicineId: dto.medicineId,
      medicine: dto.medicine != null ? MedicineMapper().toEntity(dto.medicine!) : null,
      cabinDrawer: dto.cabinDrawer != null ? DrawerUnitMapper().toEntity(dto.cabinDrawer!) : null,
      cabinAssignment: dto.cabinAssignment != null ? MedicineAssignmentMapper().toEntity(dto.cabinAssignment!) : null,
      quantity: dto.quantity,
      fillingQuantity: dto.fillingQuantity,
      fillingDate: dto.fillingDate,
      fillingUserId: dto.fillingUserId,
      fillingUser: dto.fillingUser != null ? UserMapper().toEntity(dto.fillingUser!) : null,
      isEdit: dto.isEdit,
      cabinDrawerDetail: dto.cabinDrawerDetail?.map(DrawerCellMapper().toEntity).toList(),
      stocks: dto.stocks?.map(CabinStockMapper().toEntity).toList(),
    );
  }

  RefillListDetailDto toDto(RefillListDetail entity) {
    return RefillListDetailDto(
      id: entity.id,
      fillingListId: entity.fillingListId,
      medicineId: entity.medicineId,
      medicine: entity.medicine != null ? MedicineMapper().toDto(entity.medicine!) : null,
      cabinDrawer: entity.cabinDrawer != null ? DrawerUnitMapper().toDto(entity.cabinDrawer!) : null,
      cabinAssignment: entity.cabinAssignment != null
          ? MedicineAssignmentMapper().toDto(entity.cabinAssignment!)
          : null,
      quantity: entity.quantity,
      fillingQuantity: entity.fillingQuantity,
      fillingDate: entity.fillingDate,
      fillingUserId: entity.fillingUserId,
      fillingUser: entity.fillingUser != null ? UserMapper().toDto(entity.fillingUser!) : null,
      isEdit: entity.isEdit,
      cabinDrawerDetail: entity.cabinDrawerDetail?.map(DrawerCellMapper().toDto).toList(),
      stocks: entity.stocks?.map(CabinStockMapper().toDto).toList(),
    );
  }

  List<RefillListDetail> toEntityList(List<RefillListDetailDto> dtos) => dtos.map(toEntity).toList();
}
