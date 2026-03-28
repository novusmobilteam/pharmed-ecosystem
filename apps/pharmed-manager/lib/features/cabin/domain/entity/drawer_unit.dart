import '../../../../core/core.dart';
import '../../data/model/drawer_unit_dto.dart';
import 'drawer_slot.dart';

class DrawerUnit {
  final int? id;
  final int? drawerSlotId; // Eski: cabinDesignId
  final int? compartmentNo; // Dikey sıradaki yeri
  final int? orderNo;
  final bool? isDeleted;
  final DateTime? createdDate;
  final DrawerSlot? drawerSlot; // İlişkili yuva bilgisi
  final CabinWorkingStatus workingStatus;

  String? get shownAddress {
    final address = drawerSlot?.address;
    return 'Adres: $address | Göz No: $compartmentNo - Sıra No: $orderNo';
  }

  DrawerUnit({
    this.id,
    this.drawerSlotId,
    this.compartmentNo,
    this.orderNo,
    this.drawerSlot,
    this.isDeleted,
    this.createdDate,
    this.workingStatus = CabinWorkingStatus.working,
  });

  DrawerUnitDTO toDTO() {
    return DrawerUnitDTO(
      id: id,
      drawerSlotId: drawerSlotId,
      compartmentNo: compartmentNo,
      orderNo: orderNo,
      drawerSlot: drawerSlot?.toDTO(),
      isDeleted: isDeleted,
      createdDate: createdDate,
    );
  }

  DrawerUnit copyWith({CabinWorkingStatus? workingStatus, DrawerSlot? drawerSlot}) {
    return DrawerUnit(
      id: id,
      drawerSlotId: drawerSlotId,
      compartmentNo: compartmentNo,
      orderNo: orderNo,
      drawerSlot: drawerSlot ?? this.drawerSlot,
      workingStatus: workingStatus ?? this.workingStatus,
      isDeleted: isDeleted,
      createdDate: createdDate,
    );
  }
}
