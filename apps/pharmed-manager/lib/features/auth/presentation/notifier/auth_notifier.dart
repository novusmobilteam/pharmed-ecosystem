// [SWREQ-UI-AUTH-001] [HAZ-009]
// Oturum yönetimi.
// Giriş, çıkış, oturum zaman aşımı sayacı.
// Sınıf: Class B

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';
import 'package:pharmed_manager/core/config/auth_config.dart';

import '../state/auth_state.dart';

class AuthNotifier extends ChangeNotifier {
  Timer? _sessionTimer;
  Timer? _countdownTimer;
  int _countdown = 0;
  bool _hasAccessedDashboard = false;

  final AuthConfig _config;
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final AuthCacheDataSource _cache;
  final TokenHolder _tokenHolder;

  AuthNotifier({
    required AuthConfig config,
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
    required AuthCacheDataSource cache,
    required TokenHolder tokenHolder,
  }) : _config = config,
       _loginUseCase = loginUseCase,
       _logoutUseCase = logoutUseCase,
       _cache = cache,
       _tokenHolder = tokenHolder {
    _restoreSession();
    _tokenHolder.setOnUnauthorized(onUnauthorized);
  }

  AuthState _state = const AuthLoggedOut();
  AuthState get state => _state;

  bool get hasAccessedDashboard => _hasAccessedDashboard;
  bool get isLoggedIn => _state is AuthLoggedIn || _state is AuthSessionExpiring;

  AppUser? get currentUser => switch (_state) {
    AuthLoggedIn(:final user) => user,
    AuthSessionExpiring(:final user) => user,
    _ => null,
  };

  void _setState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> _restoreSession() async {
    final token = await _cache.readToken();
    final user = await _cache.readUser();

    if (token != null && user != null) {
      _tokenHolder.setToken(token);
      _setState(
        AuthLoggedIn(
          user: user,
          sessionExpiresAt: DateTime.now().add(Duration(minutes: _config.inactivityTimeoutMinutes)),
        ),
      );
      _startSessionTimer();
    }
  }

  Future<String?> login({required String email, required String password, String? macAddress}) async {
    _setState(const AuthLoading());

    final result = await _loginUseCase(LoginParams(email: email, password: password, macAddress: macAddress));

    String? errorMsg;

    result.when(
      ok: (authToken) {
        _tokenHolder.setToken(authToken.accessToken);
        _setState(
          AuthLoggedIn(
            user: authToken.user,
            sessionExpiresAt: DateTime.now().add(Duration(minutes: _config.inactivityTimeoutMinutes)),
          ),
        );
        _startSessionTimer();
        _markDashboardAccessed();
      },
      error: (failure) {
        errorMsg = failure is ServiceException ? failure.message : 'Bir hata oluştu';
        _setState(AuthError(message: errorMsg!));
      },
    );

    return errorMsg;
  }

  Future<void> logout() async {
    _cancelTimers();
    _tokenHolder.setToken(null);
    await _cache.clear();
    _setState(const AuthLoggedOut());
  }

  void onUnauthorized() {
    _cancelTimers();
    _tokenHolder.setToken(null);
    _logoutUseCase();
    _setState(const AuthLoggedOut());
  }

  void extendSession() {
    final user = currentUser;
    if (user == null) return;

    _setState(
      AuthLoggedIn(
        user: user,
        sessionExpiresAt: DateTime.now().add(Duration(minutes: _config.inactivityTimeoutMinutes)),
      ),
    );
    _startSessionTimer();
  }

  void onUserActivity() {
    if (_state is AuthLoggedIn) {
      _startSessionTimer();
    }
  }

  void _startSessionTimer() {
    _cancelTimers();

    final warnDelay = Duration(minutes: _config.inactivityTimeoutMinutes) - Duration(seconds: _config.warningSeconds);

    _sessionTimer = Timer(warnDelay, _startCountdown);
  }

  void _startCountdown() {
    _countdown = _config.warningSeconds;
    final user = currentUser;
    if (user == null) return;

    _setState(AuthSessionExpiring(user: user, secondsRemaining: _countdown));

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      _countdown--;

      if (_countdown <= 0) {
        t.cancel();
        logout();
        return;
      }

      final u = currentUser;
      if (u != null) {
        _setState(AuthSessionExpiring(user: u, secondsRemaining: _countdown));
      }
    });
  }

  void _cancelTimers() {
    _sessionTimer?.cancel();
    _countdownTimer?.cancel();
    _sessionTimer = null;
    _countdownTimer = null;
  }

  void _markDashboardAccessed() {
    _hasAccessedDashboard = true;
  }

  @override
  void dispose() {
    _cancelTimers();
    super.dispose();
  }
}
