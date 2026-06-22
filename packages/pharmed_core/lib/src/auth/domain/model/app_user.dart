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
    required this.role,
    required this.roleId,
    this.isNotOrdered = false,
    this.isAdmin = false,
  });

  final int id;
  final String email;
  final String name;
  final String surname;
  final String fullName;
  final String role;
  final int roleId;
  final bool isNotOrdered;
  final bool isAdmin;

  String get initials {
    // Boşlukları temizle ve her ihtimale karşı null/empty kontrolü yap
    final n = name.trim();
    final s = surname.trim();

    final firstChar = n.isNotEmpty ? n[0] : '';
    final lastChar = s.isNotEmpty ? s[0] : '';

    return '$firstChar$lastChar'.toUpperCase();
  }

  @override
  List<Object?> get props => [id, email, fullName, role, isNotOrdered, isAdmin];

  User toUser() {
    return User(
      id: id,
      name: name,
      surname: surname,
      role: Role.fromIdAndName(id: roleId, name: role),
      isNotOrdered: isNotOrdered,
    );
  }
}
