import 'package:pharmed_core/pharmed_core.dart';

class RoleMenuAuthorizationMapper {
  const RoleMenuAuthorizationMapper();

  RoleMenuAuthorization toEntity(RoleMenuAuthorizationDto dto, {Role? role}) {
    final ids = (dto.menuIds ?? const <int>[]).toSet();

    return RoleMenuAuthorization(id: dto.id, role: role, menuIdsOriginal: ids, menuIdsPending: {...ids});
  }

  RoleMenuAuthorizationDto toDto(RoleMenuAuthorization entity) {
    return RoleMenuAuthorizationDto(id: entity.id, roleId: entity.role?.id, menuIds: entity.menuIdsPending.toList());
  }
}
