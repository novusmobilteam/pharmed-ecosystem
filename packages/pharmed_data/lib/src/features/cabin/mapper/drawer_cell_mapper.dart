// pharmed_data/src/cabin/mapper/drawer_cell_mapper.dart

import 'package:pharmed_core/pharmed_core.dart';

import 'drawer_unit_mapper.dart';

/// DrawerCell ↔ DrawerCellDTO dönüşümleri.
class DrawerCellMapper {
  const DrawerCellMapper({this.drawerUnitMapper = const DrawerUnitMapper()});

  final DrawerUnitMapper drawerUnitMapper;

  DrawerCell toEntity(DrawerCellDTO dto) {
    return DrawerCell(id: dto.id, stepNo: dto.stepNo, drawerUnit: drawerUnitMapper.toEntityOrNull(dto.drawerUnit));
  }

  DrawerCell? toEntityOrNull(DrawerCellDTO? dto) => dto == null ? null : toEntity(dto);

  List<DrawerCell> toEntityList(List<DrawerCellDTO> dtos) => dtos.map(toEntity).toList();

  DrawerCellDTO toDto(DrawerCell entity) {
    return DrawerCellDTO(
      id: entity.id,
      stepNo: entity.stepNo,
      drawerUnit: entity.drawerUnit != null ? drawerUnitMapper.toDto(entity.drawerUnit!) : null,
    );
  }

  DrawerCellDTO? toDtoOrNull(DrawerCell? entity) => entity == null ? null : toDto(entity);
}
