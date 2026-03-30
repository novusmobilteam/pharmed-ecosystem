// pharmed_data/src/cabin/mapper/drawer_config_mapper.dart

import 'package:pharmed_core/pharmed_core.dart';
import 'drawer_type_mapper.dart';

/// DrawerConfig ↔ DrawerConfigDTO dönüşümleri.
class DrawerConfigMapper {
  const DrawerConfigMapper({this.drawerTypeMapper = const DrawerTypeMapper()});

  final DrawerTypeMapper drawerTypeMapper;

  DrawerConfig toEntity(DrawerConfigDTO dto) {
    return DrawerConfig(
      id: dto.id,
      drawerTypeId: dto.drawerId ?? 0,
      numberOfSteps: dto.numberOfSteps ?? 0,
      deviceTypeNo: dto.no,
      stepMultiplier: dto.stepMultiplier ?? 1,
      drawerType: drawerTypeMapper.toEntityOrNull(dto.drawerType),
    );
  }

  DrawerConfig? toEntityOrNull(DrawerConfigDTO? dto) => dto == null ? null : toEntity(dto);

  List<DrawerConfig> toEntityList(List<DrawerConfigDTO> dtos) => dtos.map(toEntity).toList();

  DrawerConfigDTO toDto(DrawerConfig entity) {
    return DrawerConfigDTO(
      id: entity.id,
      drawerId: entity.drawerTypeId,
      numberOfSteps: entity.numberOfSteps,
      no: entity.deviceTypeNo,
      stepMultiplier: entity.stepMultiplier,
      drawerType: entity.drawerType != null ? drawerTypeMapper.toDto(entity.drawerType!) : null,
    );
  }
}
