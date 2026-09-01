// [SWREQ-CORE-AUTH-001]
// Oturum açmış kullanıcının slim temsili.
// Ekranlarda role kontrolü, TopBar gösterimi ve cache için yeterlidir.
// Sınıf: Class B

import 'package:equatable/equatable.dart';

import '../../../../pharmed_core.dart';

class AppUser extends Equatable {
  const AppUser({
    required this.id,
    required this.email,
    required this.name,
    required this.surname,
    required this.fullName,
    required this.roleName,
    required this.roleId,
    this.isNotOrdered = false,
    this.isAdmin = false,
    this.canCreateEmergencyPatient = false,
  });

  final int id;
  final String email;
  final String name;
  final String surname;
  final String fullName;
  final String roleName;
  final int roleId;
  final bool isNotOrdered;
  final bool isAdmin;
  final bool canCreateEmergencyPatient;

  String get initials {
    // Boşlukları temizle ve her ihtimale karşı null/empty kontrolü yap
    final n = name.trim();
    final s = surname.trim();

    final firstChar = n.isNotEmpty ? n[0] : '';
    final lastChar = s.isNotEmpty ? s[0] : '';

    return '$firstChar$lastChar'.toUpperCase();
  }

  @override
  List<Object?> get props => [id, email, fullName, roleName, isNotOrdered, isAdmin];

  /// Sistem rolü. Custom rol için null — UI tarafı "yetkisiz" varsayar.
  RoleType? get roleType => RoleType.fromId(roleId);

  Role get role => Role(id: roleId, name: roleName);

  User toUser() {
    return User(
      id: id,
      name: name,
      surname: surname,
      role: Role.fromIdAndName(id: roleId, name: roleName),
      isNotOrdered: isNotOrdered,
    );
  }
}
