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
  const AppUser({required this.id, required this.email, required this.fullName, required this.role});

  final int id;
  final String email;
  final String fullName; // name + surname birleşimi
  final String role; // role string — "Eczacı", "Hemşire" vb.

  @override
  List<Object?> get props => [id, email, fullName, role];
}
