import 'package:pharmed_manager/core/core.dart';

class InconsistencyMapper {
  final _medicineMapper = MedicineMapper();
  final _drawerCellMapper = DrawerCellMapper();

  Inconsistency toEntity(InconsistencyDTO dto) {
    return Inconsistency(
      id: dto.id,
      cabinDrawerDetail: dto.drawerCell != null ? _drawerCellMapper.toEntity(dto.drawerCell!) : null,
      medicine: dto.medicine != null ? _medicineMapper.toEntity(dto.medicine!) : null,
      quantity: dto.quantity,
      requiredQuantity: dto.requiredQuantity,
      miadDate: dto.miadDate,
      shelfNo: dto.shelfNo,
      corpartmentNo: dto.corpartmentNo,
      activeIngredients: dto.activeIngredients,
      user: UserMapper().toEntityOrNull(dto.user),
      isSolved: dto.isSolved,
    );
  }

  List<Inconsistency> toEntityList(List<InconsistencyDTO> dtos) => dtos.map(toEntity).toList();
}
