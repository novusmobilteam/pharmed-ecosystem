import 'package:pharmed_core/pharmed_core.dart';

// TODO : Localization
class UserAuthorizationSummary implements TableData {
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

  @override
  List<dynamic> get content => [
    userFullName,
    roleName,
    (encryptedLogin ?? false) ? 'Evet' : 'Hayır',
    (isDeleted ?? false) ? 'Evet' : 'Hayır',
    extraAuthorizationCount,
  ];

  @override
  List<dynamic> get rawContent => [
    userFullName,
    roleName,
    (encryptedLogin ?? false) ? 'Evet' : 'Hayır',
    (isDeleted ?? false) ? 'Evet' : 'Hayır',
    extraAuthorizationCount,
  ];

  @override
  List<String?> get titles => ['Kullanıcı', 'Rol', 'Şifreli Giriş', 'Silinmiş', 'Yetki Fazlası'];
}

class UserAuthorizationDetail {
  final User? user;
  final List<MenuItem>? roleAuthorizations;
  final List<MenuItem>? extraAuthorizations;

  UserAuthorizationDetail({this.user, this.roleAuthorizations, this.extraAuthorizations});
}
