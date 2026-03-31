// [SWREQ-CORE-AUTH-001]
// Login akışının sonucunu taşır: token + kullanıcı.
// Cache'e yazılan ve AuthNotifier'ın state'ine konan model budur.
// Sınıf: Class B

import 'package:equatable/equatable.dart';
import 'package:pharmed_core/src/auth/domain/model/app_user.dart';

class AuthToken extends Equatable {
  const AuthToken({required this.accessToken, required this.user});

  final String accessToken;
  final AppUser user;

  @override
  List<Object?> get props => [accessToken, user];
}
