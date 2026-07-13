import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class UserAuthorizationSummaryMapper {
  const UserAuthorizationSummaryMapper();

  UserAuthorizationSummary toEntity(UserAuthorizationSummaryDto? dto) {
    return UserAuthorizationSummary(
      userId: dto?.userId,
      userFullName: dto?.userFullName,
      roleId: dto?.roleId,
      roleName: dto?.roleName,
      isActive: dto?.isActive,
      date: dto?.date,
      encryptedLogin: dto?.encryptedLogin,
      isDeleted: dto?.isDeleted,
      extraAuthorizationCount: dto?.extraAuthorizationCount,
      hasExtraAuthorization: dto?.hasExtraAuthorization,
    );
  }

  List<UserAuthorizationSummary> toEntityList(List<UserAuthorizationSummaryDto> dtos) => dtos.map(toEntity).toList();
  UserAuthorizationSummary? toEntityOrNull(UserAuthorizationSummaryDto? dto) => dto == null ? null : toEntity(dto);
}

class UserAuthorizationDetailMapper {
  const UserAuthorizationDetailMapper();

  UserAuthorizationDetail toEntity(UserAuthorizationDetailDto dto) {
    print(dto.roleAuthorizations);
    print(dto.extraAuthorizations);
    return UserAuthorizationDetail(
      user: UserMapper().toEntityOrNull(dto.user),
      roleAuthorizations: MenuTreeMapper().toTreeList(dto.roleAuthorizations ?? []),
      extraAuthorizations: MenuTreeMapper().toTreeList(dto.extraAuthorizations ?? []),
    );
  }

  UserAuthorizationDetail? toEntityOrNull(UserAuthorizationDetailDto? dto) => dto == null ? null : toEntity(dto);
}
