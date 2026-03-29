// packages/pharmed_data/lib/src/role/mapper/role_mapper.dart
//
// [SWREQ-DATA-ROLE-MAP-001]
// RoleDTO ↔ Role dönüşümleri tek yer.
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class RoleMapper {
  const RoleMapper();

  Role toEntity(RoleDTO dto) => Role(id: dto.id, name: dto.name, isActive: dto.isActive);

  Role? toEntityOrNull(RoleDTO? dto) => dto == null ? null : toEntity(dto);

  List<Role> toEntityList(List<RoleDTO> dtos) => dtos.map(toEntity).toList();

  RoleDTO toDto(Role entity) => RoleDTO(id: entity.id, name: entity.name, isActive: entity.isActive);
}
