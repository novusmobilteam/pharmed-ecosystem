// lib/feature/auth/presentation/notifier/auth_notifier.dart
//
// [SWREQ-UI-AUTH-001] [HAZ-009]
// Oturum yönetimi.
// Giriş, çıkış, oturum zaman aşımı sayacı.
// Menü lock/unlock kararı buradan beslenir.
// Sınıf: Class B

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/logging/med_logger.dart';
import '../../../dashboard/domain/model/app_model.dart';

// ─────────────────────────────────────────────────────────────────
// AuthState
// ─────────────────────────────────────────────────────────────────

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

// ─────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────

final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

// ─────────────────────────────────────────────────────────────────
// AuthNotifier
// ─────────────────────────────────────────────────────────────────

class AuthNotifier extends Notifier<AuthState> {
  static const int _sessionMinutes = 30;
  static const int _warningSeconds = 60;

  Timer? _sessionTimer;
  Timer? _countdownTimer;
  int _countdown = 0;

  // Demo kullanıcılar — ileride AuthDataSource'a taşınacak
  static const _mockUsers = {
    'ayse.kara': (password: '123', name: 'Ayşe Kara', role: 'Sorumlu Hemşire'),
    'admin': (password: 'admin', name: 'Sistem Yöneticisi', role: 'Admin'),
    'dr.celik': (password: 'dr123', name: 'Dr. Ahmet Çelik', role: 'Hekim'),
  };

  @override
  AuthState build() => const AuthLoggedOut();

  // ── Login ────────────────────────────────────────────────────

  /// Dönüş: null → başarılı, String → hata mesajı
  String? login(String username, String password) {
    final u = username.trim().toLowerCase();
    final userData = _mockUsers[u];

    if (userData == null || userData.password != password) {
      MedLogger.warn(
        unit: 'SW-UNIT-AUTH',
        swreq: 'SWREQ-UI-AUTH-001',
        message: 'Başarısız giriş denemesi',
        context: {'username': u},
      );
      return 'Kullanıcı adı veya şifre hatalı.';
    }

    final user = AppUser(username: u, fullName: userData.name, role: userData.role);

    MedLogger.info(
      unit: 'SW-UNIT-AUTH',
      swreq: 'SWREQ-UI-AUTH-001',
      message: 'Giriş başarılı',
      context: {'username': u, 'role': userData.role},
    );

    state = AuthLoggedIn(
      user: user,
      sessionExpiresAt: DateTime.now().add(const Duration(minutes: _sessionMinutes)),
    );

    _startSessionTimer();
    return null; // başarılı
  }

  // ── Logout ───────────────────────────────────────────────────

  void logout() {
    MedLogger.info(unit: 'SW-UNIT-AUTH', swreq: 'SWREQ-UI-AUTH-001', message: 'Çıkış yapıldı');
    _cancelTimers();
    state = const AuthLoggedOut();
  }

  // ── Oturumu uzat ─────────────────────────────────────────────

  void extendSession() {
    final current = state;
    if (current is! AuthLoggedIn && current is! AuthSessionExpiring) return;

    final user = current is AuthLoggedIn ? current.user : (current as AuthSessionExpiring).user;

    MedLogger.info(unit: 'SW-UNIT-AUTH', swreq: 'SWREQ-UI-AUTH-001', message: 'Oturum uzatıldı');

    state = AuthLoggedIn(
      user: user,
      sessionExpiresAt: DateTime.now().add(const Duration(minutes: _sessionMinutes)),
    );

    _startSessionTimer();
  }

  // ── Kullanıcı aktivitesi — sayacı sıfırla ────────────────────

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

    // Uyarı başlamadan önce bekle
    final warnDelay = Duration(minutes: _sessionMinutes) - const Duration(seconds: _warningSeconds);

    _sessionTimer = Timer(warnDelay, _startCountdown);
  }

  void _startCountdown() {
    _countdown = _warningSeconds;
    final user = currentUser;
    if (user == null) return;

    state = AuthSessionExpiring(user: user, secondsRemaining: _countdown);

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      _countdown--;

      if (_countdown <= 0) {
        t.cancel();
        MedLogger.info(unit: 'SW-UNIT-AUTH', swreq: 'SWREQ-UI-AUTH-001', message: 'Oturum zaman aşımı');
        state = const AuthLoggedOut();
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
