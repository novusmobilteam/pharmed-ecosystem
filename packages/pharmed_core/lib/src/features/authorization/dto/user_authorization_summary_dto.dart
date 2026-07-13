import 'package:pharmed_core/pharmed_core.dart';

class UserAuthorizationSummaryDto {
  final int? userId;
  final String? userFullName;
  final int? roleId;
  final String? roleName;
  final bool? isActive;
  final String? date;
  final bool? encryptedLogin;
  final bool? isDeleted;
  final int? extraAuthorizationCount;
  final bool? hasExtraAuthorization;

  UserAuthorizationSummaryDto({
    this.userId,
    this.userFullName,
    this.roleId,
    this.roleName,
    this.isActive,
    this.date,
    this.encryptedLogin,
    this.isDeleted,
    this.extraAuthorizationCount,
    this.hasExtraAuthorization,
  });

  factory UserAuthorizationSummaryDto.fromJson(Map<String, dynamic> json) {
    return UserAuthorizationSummaryDto(
      userId: json['userId'],
      userFullName: json['userFullName'],
      roleId: json['roleId'],
      roleName: json['roleName'],
      isActive: json['isActive'],
      date: json['date'],
      encryptedLogin: json['encryptedLogin'],
      isDeleted: json['isDeleted'],
      extraAuthorizationCount: json['extraAuthorizationCount'],
      hasExtraAuthorization: json['hasExtraAuthorization'],
    );
  }
}

class UserAuthorizationDetailDto {
  final UserDto? user;
  final List<MenuDTO>? roleAuthorizations;
  final List<MenuDTO>? extraAuthorizations;

  UserAuthorizationDetailDto({this.user, this.roleAuthorizations, this.extraAuthorizations});

  factory UserAuthorizationDetailDto.fromJson(Map<String, dynamic> json) {
    return UserAuthorizationDetailDto(
      user: json['user'] == null ? null : UserDto.fromJson(json['user'] as Map<String, dynamic>),
      roleAuthorizations: (json['roleAuthorizations'] as List<dynamic>?)
          ?.map((e) => MenuDTO.fromJson(e as Map<String, dynamic>))
          .toList(),
      extraAuthorizations: (json['extraAuthorizations'] as List<dynamic>?)
          ?.map((e) => MenuDTO.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
