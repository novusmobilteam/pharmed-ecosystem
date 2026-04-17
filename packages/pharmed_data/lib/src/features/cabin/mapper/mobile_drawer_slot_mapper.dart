// pharmed_data/src/cabin/mapper/mobile_drawer_slot_mapper.dart
//
// MobileDrawerSlotDTO → MobileDrawerSlot dönüşümü.
// 3 seviyeli nested yapıyı tek geçişte çözer.
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class MobileDrawerSlotMapper {
  const MobileDrawerSlotMapper();

  MobileDrawerSlot toEntity(MobileDrawerSlotDTO dto) {
    return MobileDrawerSlot(
      id: dto.id,
      orderNumber: dto.orderNumber,
      address: dto.address,
      cabinId: dto.cabinId,
      units: dto.cabinDrawrs.map(_unitToEntity).toList()..sort((a, b) => a.orderNo.compareTo(b.orderNo)),
    );
  }

  MobileDrawerSlot? toEntityOrNull(MobileDrawerSlotDTO? dto) => dto == null ? null : toEntity(dto);

  List<MobileDrawerSlot> toEntityList(List<MobileDrawerSlotDTO> dtos) => dtos.map(toEntity).toList();

  MobileDrawerUnit _unitToEntity(MobileDrawerUnitDTO dto) {
    return MobileDrawerUnit(
      id: dto.id,
      slotId: dto.cabinDesignId,
      orderNo: dto.orderNo,
      cells: dto.details.map(_cellToEntity).toList()..sort((a, b) => a.stepNo.compareTo(b.stepNo)),
    );
  }

  MobileDrawerCell _cellToEntity(MobileDrawerCellDto dto) {
    return MobileDrawerCell(id: dto.id, unitId: dto.cabinDrawrId, stepNo: dto.stepNo);
  }

  MobileDrawerCellDto toDto(MobileDrawerCell? entity) {
    return MobileDrawerCellDto(id: entity?.id ?? 0, cabinDrawrId: entity?.unitId ?? 0, stepNo: entity?.stepNo ?? 0);
  }
}
