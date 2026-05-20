// [SWREQ-UI-AUTH-001] [HAZ-009]
// Oturum yönetimi.
// Giriş, çıkış, oturum zaman aşımı sayacı.
// Sınıf: Class B

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/core/config/auth_config.dart';
import 'package:pharmed_client/core/providers/auth_providers.dart';
import 'package:pharmed_client/core/providers/network_providers.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';
import 'package:pharmed_utils/pharmed_utils.dart';

import 'auth_state.dart';

final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

class AuthNotifier extends Notifier<AuthState> {
  AuthConfig get _config => ref.read(authConfigProvider);
  LoginUseCase get _loginUseCase => ref.read(loginUseCaseProvider);
  LogoutUseCase get _logoutUseCase => ref.read(logoutUseCaseProvider);
  AuthCacheDataSource get _cache => ref.read(authCacheProvider);
  TokenHolder get _tokenHolder => ref.read(tokenHolderProvider);

  Timer? _sessionTimer;
  Timer? _countdownTimer;
  int _countdown = 0;

  bool _hasAccessedDashboard = false;
  bool get hasAccessedDashboard => _hasAccessedDashboard;
  bool get isLoggedIn => state is AuthLoggedIn || state is AuthSessionExpiring;

  AppUser? get currentUser => switch (state) {
    AuthLoggedIn(:final user) => user,
    AuthSessionExpiring(:final user) => user,
    _ => null,
  };

  @override
  AuthState build() {
    _restoreSession();
    return const AuthLoggedOut();
  }

  Future<void> login({required String email, required String password, required ValueChanged<String> onError}) async {
    state = const AuthLoading();
    final macAddress = await DeviceInfo.getMacAddress();

    final result = await _loginUseCase(LoginParams(email: email, password: password, macAddress: macAddress));

    result.when(
      ok: (authToken) {
        _tokenHolder.setToken(authToken.accessToken);
        state = AuthLoggedIn(
          user: authToken.user,
          sessionExpiresAt: DateTime.now().add(Duration(minutes: _config.inactivityTimeoutMinutes)),
        );
        _startSessionTimer();
        _markDashboardAccessed();
      },
      error: (failure) {
        final msg = failure is ServiceException ? failure.message : 'Bir hata oluştu';
        state = AuthError(message: msg);
        onError(msg);
      },
    );
  }

  Future<void> _restoreSession() async {
    final token = await _cache.readToken();
    final user = await _cache.readUser();

    if (token != null && user != null) {
      _tokenHolder.setToken(token);
      state = AuthLoggedIn(
        user: user,
        sessionExpiresAt: DateTime.now().add(Duration(minutes: _config.inactivityTimeoutMinutes)),
      );
      _startSessionTimer();
    }
  }

  Future<void> logout() async {
    _cancelTimers();
    _tokenHolder.setToken(null);
    await _cache.clear();
    state = const AuthLoggedOut();
  }

  void onUnauthorized() {
    _cancelTimers();
    _tokenHolder.setToken(null);
    _logoutUseCase();
    state = const AuthLoggedOut();
  }

  void extendSession() {
    final user = currentUser;
    if (user == null) return;

    state = AuthLoggedIn(
      user: user,
      sessionExpiresAt: DateTime.now().add(Duration(minutes: _config.inactivityTimeoutMinutes)),
    );
    _startSessionTimer();
  }

  void onUserActivity() {
    if (state is AuthLoggedIn) {
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

  void _markDashboardAccessed() {
    _hasAccessedDashboard = true;
  }
}
