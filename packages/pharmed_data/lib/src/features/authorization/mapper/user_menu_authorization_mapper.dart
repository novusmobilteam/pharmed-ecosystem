import 'package:pharmed_core/pharmed_core.dart';

class UserMenuAuthorizationMapper {
  const UserMenuAuthorizationMapper();

  UserMenuAuthorization toEntity(UserMenuAuthorizationDto? dto, {required User user}) {
    final ids = (dto?.menuIds ?? const <int>[]).toSet();

    return UserMenuAuthorization(id: dto?.id, user: user, menuIdsOriginal: ids, menuIdsPending: {...ids});
  }

  UserMenuAuthorizationDto toDto(UserMenuAuthorization entity) {
    return UserMenuAuthorizationDto(id: entity.id, userId: entity.user?.id, menuIds: entity.menuIdsPending.toList());
  }
}
