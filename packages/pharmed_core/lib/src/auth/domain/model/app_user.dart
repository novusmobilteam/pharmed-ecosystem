// ─────────────────────────────────────────────────────────────────────────────
// packages/pharmed_core/lib/src/auth/domain/model/app_user.dart
//
// [SWREQ-CORE-AUTH-001]
// Oturum açmış kullanıcının slim temsili.
// Ekranlarda role kontrolü, TopBar gösterimi ve cache için yeterlidir.
// Sınıf: Class B
// ─────────────────────────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  const AppUser({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.isNotOrdered = false,
    this.isAdmin = false,
  });

  final int id;
  final String email;
  final String fullName;
  final String role;
  final bool isNotOrdered;
  final bool isAdmin;

  @override
  List<Object?> get props => [id, email, fullName, role, isNotOrdered, isAdmin];
}
