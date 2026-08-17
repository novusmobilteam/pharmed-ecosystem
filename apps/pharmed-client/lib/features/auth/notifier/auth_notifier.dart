// [SWREQ-UI-AUTH-001] [HAZ-009]
// Oturum yönetimi.
// Giriş, çıkış, oturum zaman aşımı sayacı.
// Sınıf: Class B

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pharmed_client/core/cache/app_settings_cache.dart';
import 'package:pharmed_client/core/flavor/auth_config.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';

import 'auth_state.dart';

class AuthNotifier extends ChangeNotifier {
  AuthNotifier({
    required AuthConfig config,
    required LoginUseCase loginUseCase,
    required LoginWithBadgeUseCase loginWithBadge,
    required LogoutUseCase logoutUseCase,
    required AuthCacheDataSource cache,
    required TokenHolder tokenHolder,
    required AppSettingsCache appSettingsCache,
  }) : _config = config,
       _loginUseCase = loginUseCase,
       _loginWithBadge = loginWithBadge,
       _logoutUseCase = logoutUseCase,
       _cache = cache,
       _tokenHolder = tokenHolder,
       _appSettingsCache = appSettingsCache {
    unawaited(_restoreSession());
  }

  final AuthConfig _config;
  final LoginUseCase _loginUseCase;
  final LoginWithBadgeUseCase _loginWithBadge;
  final LogoutUseCase _logoutUseCase;
  final AuthCacheDataSource _cache;
  final TokenHolder _tokenHolder;
  final AppSettingsCache _appSettingsCache;

  bool _isDisposed = false;

  void _notify() {
    if (_isDisposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _cancelTimers();
    super.dispose();
  }

  AuthState _state = const AuthLoggedOut();
  AuthState get state => _state;

  void _setState(AuthState next) {
    _state = next;
    _notify();
  }

  // Activity throttle: AuthLoggedIn'deyken peş peşe gelen pointer event'leri
  // saniyede en fazla bir kez işle. AuthSessionExpiring'de throttle uygulanmaz.
  DateTime? _lastActivityAt;
  static const _activityThrottle = Duration(seconds: 1);

  // Pause/resume nested-safe counter. Birden fazla işlem üst üste pause
  // edebilir; her pause için karşılık gelen resume gerekir.
  int _pauseCount = 0;
  bool get _isPaused => _pauseCount > 0;

  bool _hasAccessedDashboard = false;
  bool get hasAccessedDashboard => _hasAccessedDashboard;
  bool get isLoggedIn => _state is AuthLoggedIn || _state is AuthSessionExpiring;

  AppUser? get currentUser => switch (_state) {
    AuthLoggedIn(:final user) => user,
    AuthSessionExpiring(:final user) => user,
    _ => null,
  };

  Timer? _sessionTimer;
  Timer? _countdownTimer;
  int _countdown = 0;

  Future<void> login({required String email, required String password, required ValueChanged<String> onError}) async {
    _setState(const AuthLoading());
    final macAddress = await DeviceInfo.getMacAddress();
    if (_isDisposed) return;
    final debugStationId = kDebugMode ? await _appSettingsCache.getCurrentStationId() : null;
    if (_isDisposed) return;

    final result = await _loginUseCase(
      LoginParams(email: email, password: password, macAddress: macAddress, stationId: debugStationId),
    );
    if (_isDisposed) return;

    result.when(
      ok: (authToken) {
        _tokenHolder.setToken(authToken.accessToken);
        _setLoggedIn(authToken.user);
        _markDashboardAccessed();
      },
      error: (failure) {
        final rawMsg = failure is ServiceException ? failure.message : null;
        final msg = rawMsg ?? contextlessL10n().auth_genericError;
        _setState(AuthError(message: msg));
        onError(msg);
      },
    );
  }

  Future<void> loginWithBadge({required String cardData, required ValueChanged<String> onError}) async {
    _setState(const AuthLoading());
    final macAddress = await DeviceInfo.getMacAddress();
    if (_isDisposed) return;

    final result = await _loginWithBadge.call(cardData: cardData, macAddress: macAddress);
    if (_isDisposed) return;

    result.when(
      ok: (authToken) {
        _tokenHolder.setToken(authToken.accessToken);
        _setLoggedIn(authToken.user);
        _markDashboardAccessed();
      },
      error: (failure) {
        final rawMsg = failure is ServiceException ? failure.message : null;
        final msg = rawMsg ?? contextlessL10n().auth_genericError;
        _setState(AuthError(message: msg));
        onError(msg);
      },
    );
  }

  Future<void> logout({bool locked = false}) async {
    _cancelTimers();
    _pauseCount = 0;
    _lastActivityAt = null;
    _tokenHolder.setToken(null);
    await _cache.clear();
    if (_isDisposed) return;
    _setState(AuthLoggedOut(showLockedDashboard: locked));
  }

  void onUnauthorized() {
    _cancelTimers();
    _pauseCount = 0;
    _lastActivityAt = null;
    _tokenHolder.setToken(null);
    unawaited(_logoutUseCase());
    _setState(const AuthLoggedOut(showLockedDashboard: true));
  }

  /// UI'da herhangi bir etkileşim. Dashboard'daki kök [Listener] tarafından
  /// çağrılır. `AuthLoggedIn`'deyken state DEĞİŞTİRİLMEZ (UI rebuild olmaz),
  /// sadece sayaç sessizce yenilenir. `AuthSessionExpiring`'deyken kullanıcı
  /// son anda dokunmuş demektir → oturum tekrar uzatılır.
  void onUserActivity() {
    if (_isPaused) return;

    final isExpiring = _state is AuthSessionExpiring;

    if (!isExpiring) {
      final now = DateTime.now();
      if (_lastActivityAt != null && now.difference(_lastActivityAt!) < _activityThrottle) {
        return;
      }
      _lastActivityAt = now;
    }

    switch (_state) {
      case AuthLoggedIn():
        // Sessiz yenile: state'e dokunma, sadece timer'ı sıfırla.
        _startSessionTimer();
        break;
      case AuthSessionExpiring(:final user):
        _setLoggedIn(user);
        break;
      default:
        break;
    }
  }

  /// Çekmece açık / RFID tarama gibi uzun süren ve pointer event üretmeyen
  /// işlemler sırasında çağrılır. Nested-safe; her [pauseInactivityTimer]
  /// için bir [resumeInactivityTimer] çağrılmalıdır.
  void pauseInactivityTimer() {
    _pauseCount++;
    if (_pauseCount == 1) {
      _cancelTimers();
    }
  }

  void resumeInactivityTimer() {
    if (_pauseCount == 0) return;
    _pauseCount--;
    if (_pauseCount == 0 && _state is AuthLoggedIn) {
      _startSessionTimer();
    }
  }

  Future<void> _restoreSession() async {
    final token = await _cache.readToken();
    final user = await _cache.readUser();
    if (_isDisposed) return;

    if (token != null && user != null) {
      _tokenHolder.setToken(token);
      _setLoggedIn(user);
    }
  }

  void _setLoggedIn(AppUser user) {
    _setState(
      AuthLoggedIn(
        user: user,
        sessionExpiresAt: DateTime.now().add(Duration(minutes: _config.inactivityTimeoutMinutes)),
      ),
    );
    _startSessionTimer();
  }

  void _startSessionTimer() {
    _cancelTimers();
    if (_isPaused) return;
    final warnDelay = Duration(minutes: _config.inactivityTimeoutMinutes) - Duration(seconds: _config.warningSeconds);
    _sessionTimer = Timer(warnDelay, _startCountdown);
  }

  void _startCountdown() {
    final user = currentUser;
    if (user == null) return;

    _countdown = _config.warningSeconds;
    _setState(AuthSessionExpiring(user: user, secondsRemaining: _countdown));

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      _countdown--;

      if (_countdown <= 0) {
        t.cancel();
        unawaited(logout(locked: true));
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
}
