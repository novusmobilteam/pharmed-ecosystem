// pharmed_data/src/cabin/mapper/drawer_slot_mapper.dart

import 'package:pharmed_core/pharmed_core.dart';
import 'drawer_config_mapper.dart';

/// DrawerSlot ↔ DrawerSlotDTO dönüşümleri.
class DrawerSlotMapper {
  const DrawerSlotMapper({this.drawerConfigMapper = const DrawerConfigMapper()});

  final DrawerConfigMapper drawerConfigMapper;

  DrawerSlot toEntity(DrawerSlotDTO dto) {
    return DrawerSlot(
      id: dto.id,
      drawerConfigId: dto.drawerConfigId,
      cabinId: dto.cabinId,
      orderNumber: dto.orderNumber,
      address: dto.address,
      compartmentNo: dto.compartmentNo,
      drawerOrderNumber: dto.drawerOrderNumber,
      drawerConfig: drawerConfigMapper.toEntityOrNull(dto.drawerConfig),
    );
  }

  DrawerSlot? toEntityOrNull(DrawerSlotDTO? dto) => dto == null ? null : toEntity(dto);

  List<DrawerSlot> toEntityList(List<DrawerSlotDTO> dtos) => dtos.map(toEntity).toList();

  DrawerSlotDTO toDto(DrawerSlot entity) {
    return DrawerSlotDTO(
      id: entity.id,
      drawerConfigId: entity.drawerConfigId,
      cabinId: entity.cabinId,
      orderNumber: entity.orderNumber,
      address: entity.address,
      compartmentNo: entity.compartmentNo,
      drawerOrderNumber: entity.drawerOrderNumber,
      drawerConfig: entity.drawerConfig != null ? drawerConfigMapper.toDto(entity.drawerConfig!) : null,
    );
  }

  List<DrawerSlotDTO> toDtoList(List<DrawerSlot> entities) => entities.map(toDto).toList();
}
