import '../../data/model/drawer_cell_dto.dart';
import 'drawer_unit.dart';

class DrawerCell {
  final int? id;
  final int? stepNo;
  final DrawerUnit? cabinDrawer;
  final bool? isDeleted;
  final DateTime? createdDate;

  DrawerCell({
    this.id,
    this.stepNo,
    this.cabinDrawer,
    this.isDeleted,
    this.createdDate,
  });

  DrawerCellDTO toDTO() {
    return DrawerCellDTO(
      id: id,
      stepNo: stepNo,
      drawerUnit: cabinDrawer?.toDTO(),
    );
  }
}
