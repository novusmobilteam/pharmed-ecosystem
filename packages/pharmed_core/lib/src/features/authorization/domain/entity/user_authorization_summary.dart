import 'package:pharmed_core/pharmed_core.dart';

class UserAuthorizationSummary {
  int? userId;
  String? userFullName;
  int? roleId;
  String? roleName;
  bool? isActive;
  String? date;
  bool? encryptedLogin;
  bool? isDeleted;
  int? extraAuthorizationCount;
  bool? hasExtraAuthorization;

  UserAuthorizationSummary({
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
}

class UserAuthorizationDetail {
  final User? user;
  final List<MenuItem>? roleAuthorizations;
  final List<MenuItem>? extraAuthorizations;

  UserAuthorizationDetail({this.user, this.roleAuthorizations, this.extraAuthorizations});
}
