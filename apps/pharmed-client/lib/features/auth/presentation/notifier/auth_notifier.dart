// lib/feature/auth/presentation/notifier/auth_notifier.dart
//
// [SWREQ-UI-AUTH-001] [HAZ-009]
// Oturum yönetimi.
// Giriş, çıkış, oturum zaman aşımı sayacı.
// Menü lock/unlock kararı buradan beslenir.
// Sınıf: Class B

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/core/config/auth_config.dart';
import 'package:pharmed_core/pharmed_core.dart';
import '../state/auth_state.dart';

final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

class AuthNotifier extends Notifier<AuthState> {
  late AuthConfig _config;
  late LoginUseCase _loginUseCase;
  late LogoutUseCase _logoutUseCase;

  Timer? _sessionTimer;
  Timer? _countdownTimer;
  int _countdown = 0;

  /// DI tarafından çağrılır — provider oluşturulurken inject edilir.
  void initialize({
    required AuthConfig config,
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
  }) {
    _config = config;
    _loginUseCase = loginUseCase;
    _logoutUseCase = logoutUseCase;
  }

  @override
  AuthState build() => const AuthLoggedOut();

  // ── Login ─────────────────────────────────────────────────────────────────

  Future<void> login({required String email, required String password, String? macAddress}) async {
    state = const AuthLoading();

    final result = await _loginUseCase(LoginParams(email: email, password: password, macAddress: macAddress));

    result.when(
      ok: (authToken) {
        state = AuthLoggedIn(
          user: authToken.user,
          sessionExpiresAt: DateTime.now().add(Duration(minutes: _config.inactivityTimeoutMinutes)),
        );
        _startSessionTimer();
      },
      error: (failure) {
        state = AuthError(message: failure is ServiceException ? failure.message : 'Bir hata oluştu');
      },
    );
  }

  // ── Logout ───────────────────────────────────────────────────

  Future<void> logout() async {
    _cancelTimers();
    await _logoutUseCase();
    state = const AuthLoggedOut();
  }

  /// AuthInterceptor 401 aldığında çağırır.
  /// async logout'u beklemez — UI hemen güncellenir.
  void onUnauthorized() {
    _cancelTimers();
    _logoutUseCase(); // fire-and-forget: cache temizlenir
    state = const AuthLoggedOut();
  }

  // ── Oturumu uzat ─────────────────────────────────────────────

  void extendSession() {
    final user = currentUser;
    if (user == null) return;

    state = AuthLoggedIn(
      user: user,
      sessionExpiresAt: DateTime.now().add(Duration(minutes: _config.inactivityTimeoutMinutes)),
    );
    _startSessionTimer();
  }

  // ── Kullanıcı aktivitesi — sayacı sıfırla ────────────────────

  /// Her ekranın GestureDetector.onTap'inde çağrılır.
  void onUserActivity() {
    if (state is AuthLoggedIn) {
      _startSessionTimer();
    }
  }

  // ── Getter'lar ────────────────────────────────────────────────

  bool get isLoggedIn => state is AuthLoggedIn || state is AuthSessionExpiring;

  AppUser? get currentUser => switch (state) {
    AuthLoggedIn(:final user) => user,
    AuthSessionExpiring(:final user) => user,
    _ => null,
  };

  // ── İç timer yönetimi ─────────────────────────────────────────

  void _startSessionTimer() {
    _cancelTimers();

    final warnDelay = Duration(minutes: _config.inactivityTimeoutMinutes) - Duration(seconds: _config.warningSeconds);

    _sessionTimer = Timer(warnDelay, _startCountdown);
  }

  void _startCountdown() {
    _countdown = _config.warningSeconds;
    final user = currentUser;
    if (user == null) return;

    state = AuthSessionExpiring(user: user, secondsRemaining: _countdown);

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      _countdown--;

      if (_countdown <= 0) {
        t.cancel();
        logout();
        return;
      }

      final u = currentUser;
      if (u != null) {
        state = AuthSessionExpiring(user: u, secondsRemaining: _countdown);
      }
    });
  }

  void _cancelTimers() {
    _sessionTimer?.cancel();
    _countdownTimer?.cancel();
    _sessionTimer = null;
    _countdownTimer = null;
  }

  void dispose() {
    _cancelTimers();
  }
}
