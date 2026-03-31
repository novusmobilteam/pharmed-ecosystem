// pharmed_data/src/cabin/mapper/drawer_unit_mapper.dart

import 'package:pharmed_core/pharmed_core.dart';

import 'drawer_slot_mapper.dart';

/// DrawerUnit ↔ DrawerUnitDTO dönüşümleri.
class DrawerUnitMapper {
  const DrawerUnitMapper({this.drawerSlotMapper = const DrawerSlotMapper()});

  final DrawerSlotMapper drawerSlotMapper;

  DrawerUnit toEntity(DrawerUnitDTO dto) {
    return DrawerUnit(
      id: dto.id,
      drawerSlotId: dto.drawerSlotId,
      compartmentNo: dto.compartmentNo,
      orderNo: dto.orderNo,
      drawerSlot: drawerSlotMapper.toEntityOrNull(dto.drawerSlot),
    );
  }

  DrawerUnit? toEntityOrNull(DrawerUnitDTO? dto) => dto == null ? null : toEntity(dto);

  List<DrawerUnit> toEntityList(List<DrawerUnitDTO> dtos) => dtos.map(toEntity).toList();

  DrawerUnitDTO toDto(DrawerUnit entity) {
    return DrawerUnitDTO(
      id: entity.id,
      drawerSlotId: entity.drawerSlotId,
      compartmentNo: entity.compartmentNo,
      orderNo: entity.orderNo,
      drawerSlot: entity.drawerSlot != null ? drawerSlotMapper.toDto(entity.drawerSlot!) : null,
    );
  }

  DrawerUnitDTO? toDtoOrNull(DrawerUnit? entity) => entity == null ? null : toDto(entity);
}
