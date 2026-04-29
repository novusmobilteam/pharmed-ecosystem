import 'package:pharmed_manager/core/core.dart';

class InconsistencyMapper {
  final _medicineMapper = MedicineMapper();
  final _drawerCellMapper = DrawerCellMapper();

  Inconsistency toEntity(InconsistencyDTO dto) {
    return Inconsistency(
      id: dto.id,
      cabinDrawerDetail: dto.cabinDrawerDetail != null ? _drawerCellMapper.toEntity(dto.cabinDrawerDetail!) : null,
      medicine: dto.medicine != null ? _medicineMapper.toEntity(dto.medicine!) : null,
      quantity: dto.quantity,
      stockEntryQuantity: dto.stockEntryQuantity,
      stockExitQuantity: dto.stockExitQuantity,
      requiredQuantity: dto.requiredQuantity,
      miadDate: dto.miadDate,
      shelfNo: dto.shelfNo,
      corpartmentNo: dto.corpartmentNo,
      activeIngredients: dto.activeIngredients,
    );
  }

  List<Inconsistency> toEntityList(List<InconsistencyDTO> dtos) => dtos.map(toEntity).toList();
}
