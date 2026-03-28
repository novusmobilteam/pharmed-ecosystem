import '../../../dashboard/domain/model/app_model.dart';

sealed class AuthState {
  const AuthState();
}

final class AuthLoggedOut extends AuthState {
  const AuthLoggedOut();
}

final class AuthLoggedIn extends AuthState {
  const AuthLoggedIn({required this.user, required this.sessionExpiresAt});
  final AppUser user;
  final DateTime sessionExpiresAt;
}

/// [HAZ-009] Oturum süresi bitiyor — kullanıcı uyarılmalı
final class AuthSessionExpiring extends AuthState {
  const AuthSessionExpiring({required this.user, required this.secondsRemaining});
  final AppUser user;
  final int secondsRemaining;
}
