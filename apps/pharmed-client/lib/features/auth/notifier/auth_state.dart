import 'package:pharmed_core/pharmed_core.dart';

sealed class AuthState {
  const AuthState();
}

/// Kullanıcı giriş yapmamış veya oturum düşmüş.
final class AuthLoggedOut extends AuthState {
  /// `true` ise router LoginScreen yerine DashboardScreen (read-only) gösterir
  /// ve appbar'da "Giriş Yap" butonu çıkar. Inactivity timeout veya 401
  /// (`onUnauthorized`) sonrası logout'larda `true`. Kullanıcı manuel olarak
  /// çıkış yaptığında veya uygulama ilk açıldığında `false`.
  const AuthLoggedOut({this.showLockedDashboard = false});

  final bool showLockedDashboard;
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
