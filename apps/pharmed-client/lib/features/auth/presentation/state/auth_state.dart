import 'package:pharmed_core/pharmed_core.dart';

sealed class AuthState {
  const AuthState();
}

/// Kullanıcı giriş yapmamış veya oturum düşmüş.
final class AuthLoggedOut extends AuthState {
  const AuthLoggedOut();
}

/// Giriş işlemi devam ediyor.
final class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Giriş başarılı, oturum aktif.
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

/// Login endpoint hatası — ekranda mesaj gösterilir.
final class AuthError extends AuthState {
  const AuthError({required this.message});

  final String message;
}
