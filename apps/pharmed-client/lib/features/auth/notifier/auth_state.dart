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
  /// Giriş kilitli dashboard'daki modal'dan yapılıyorsa `true` — router
  /// bu sürede dashboard'u korur.
  const AuthLoading({this.showLockedDashboard = false});

  final bool showLockedDashboard;
}

/// Giriş başarılı, oturum aktif.
final class AuthLoggedIn extends AuthState {
  const AuthLoggedIn({required this.user});

  final AppUser user;
}

/// Login endpoint hatası — ekranda mesaj gösterilir.
final class AuthError extends AuthState {
  const AuthError({required this.message, this.showLockedDashboard = false});

  final String message;
  final bool showLockedDashboard;
}
