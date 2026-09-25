// [SWREQ-UI-AUTH-001] [HAZ-009]
// Oturum yönetimi.
// Giriş, çıkış, oturum zaman aşımı sayacı.
// Sınıf: Class B

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/core/cache/app_settings_cache.dart';
import 'package:pharmed_client/core/flavor/auth_config.dart';
import 'package:pharmed_client/core/providers/auth_providers.dart';
import 'package:pharmed_client/core/providers/network_providers.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';

import '../../service_selection/notifier/active_service_notifier.dart';
import 'auth_state.dart';
import 'session_countdown_notifier.dart';

final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

class AuthNotifier extends Notifier<AuthState> {
  AuthConfig get _config => ref.read(authConfigProvider);
  LoginUseCase get _loginUseCase => ref.read(loginUseCaseProvider);
  LoginWithBadgeUseCase get _loginWithBadge => ref.read(loginWithBadgeUseCaseProvider);
  LogoutUseCase get _logoutUseCase => ref.read(logoutUseCaseProvider);
  AuthCacheDataSource get _cache => ref.read(authCacheProvider);
  TokenHolder get _tokenHolder => ref.read(tokenHolderProvider);
  ActiveServiceNotifier get _activeServiceNotifier => ref.read(activeServiceNotifierProvider);
  SessionCountdownNotifier get _countdown => ref.read(sessionCountdownProvider.notifier);

  Timer? _sessionTimer;
  Timer? _countdownTimer;
  int _secondsRemaining = 0;

  // Activity throttle: AuthLoggedIn'deyken peş peşe gelen pointer event'leri
  // saniyede en fazla bir kez işle. AuthSessionExpiring'de throttle uygulanmaz.
  DateTime? _lastActivityAt;
  static const _activityThrottle = Duration(seconds: 1);

  // Pause/resume nested-safe counter. Birden fazla işlem üst üste pause
  // edebilir; her pause için karşılık gelen resume gerekir.
  int _pauseCount = 0;
  bool get _isPaused => _pauseCount > 0;

  /// Uyarı geri sayımı şu an aktif mi.
  bool get _isWarning => _countdownTimer != null;

  bool _hasAccessedDashboard = false;
  bool get hasAccessedDashboard => _hasAccessedDashboard;
  bool get isLoggedIn => state is AuthLoggedIn;

  AppUser? get currentUser => switch (state) {
    AuthLoggedIn(:final user) => user,
    _ => null,
  };

  /// Mevcut state kilitli dashboard bağlamında mı — login denemesi ve
  /// hatası boyunca bu bilgi korunur.
  bool get _isLockedContext => switch (state) {
    AuthLoggedOut(:final showLockedDashboard) => showLockedDashboard,
    AuthLoading(:final showLockedDashboard) => showLockedDashboard,
    AuthError(:final showLockedDashboard) => showLockedDashboard,
    _ => false,
  };

  @override
  AuthState build() {
    // Dispose sırasında başka bir provider'a yazılmaz.
    ref.onDispose(() => _cancelTimers(clearCountdown: false));
    _restoreSession();
    return const AuthLoggedOut();
  }

  Future<void> login({required String email, required String password, required ValueChanged<String> onError}) async {
    final locked = _isLockedContext;
    state = AuthLoading(showLockedDashboard: locked);

    final macAddress = await DeviceInfo.getMacAddress();
    final debugStationId = kDebugMode ? await ref.read(appSettingsCacheProvider).getCurrentStationId() : null;

    final result = await _loginUseCase(
      LoginParams(email: email, password: password, macAddress: macAddress, stationId: debugStationId),
    );

    result.when(
      ok: (authToken) {
        _tokenHolder.setToken(authToken.accessToken);
        _setLoggedIn(authToken.user);
        _markDashboardAccessed();
      },
      error: (failure) {
        final rawMsg = failure is ServiceException ? failure.message : null;
        final msg = rawMsg ?? contextlessL10n().auth_genericError;
        state = AuthError(message: msg, showLockedDashboard: locked);
        onError(msg);
      },
    );
  }

  Future<void> loginWithBadge({required String cardData, required ValueChanged<String> onError}) async {
    final locked = _isLockedContext;
    state = AuthLoading(showLockedDashboard: locked);
    final macAddress = await DeviceInfo.getMacAddress();

    final result = await _loginWithBadge.call(cardData: cardData, macAddress: macAddress);

    result.when(
      ok: (authToken) {
        _tokenHolder.setToken(authToken.accessToken);
        _setLoggedIn(authToken.user);
        _markDashboardAccessed();
      },
      error: (failure) {
        final rawMsg = failure is ServiceException ? failure.message : null;
        final msg = rawMsg ?? contextlessL10n().auth_genericError;
        state = AuthError(message: msg, showLockedDashboard: locked);
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
    _activeServiceNotifier.reset();
    state = AuthLoggedOut(showLockedDashboard: locked);
  }

  void onUnauthorized() {
    _cancelTimers();
    _pauseCount = 0;
    _lastActivityAt = null;
    _tokenHolder.setToken(null);
    _logoutUseCase();
    state = const AuthLoggedOut(showLockedDashboard: true);
  }

  /// UI'da herhangi bir etkileşim. State'e hiç dokunulmaz — sadece timer
  /// sıfırlanır; uyarı aktifse geri sayım da iptal edilir (banner kaybolur).
  void onUserActivity() {
    if (_isPaused || state is! AuthLoggedIn) return;

    // Uyarı aktifken throttle BYPASS — son anda dokunuş hemen işlenmeli.
    if (!_isWarning) {
      final now = DateTime.now();
      if (_lastActivityAt != null && now.difference(_lastActivityAt!) < _activityThrottle) return;
      _lastActivityAt = now;
    }

    _startSessionTimer();
  }

  /// Çekmece açık / RFID tarama gibi uzun süren ve pointer event üretmeyen
  /// işlemler sırasında çağrılır. Nested-safe; her [pauseInactivityTimer]
  /// için bir [resumeInactivityTimer] çağrılmalıdır.
  void pauseInactivityTimer() {
    _pauseCount++;
    if (_pauseCount == 1) _cancelTimers();
  }

  /// Uzun işlem bittiğinde oturum tam süreyle yeniden başlar. Pause sırasında
  /// uyarı aktif idiyse, _cancelTimers onu zaten temizlemişti — state hep
  /// AuthLoggedIn olduğu için "donmuş geri sayım" durumu artık oluşamaz.
  void resumeInactivityTimer() {
    if (_pauseCount == 0) return;
    _pauseCount--;
    if (_pauseCount == 0 && state is AuthLoggedIn) _startSessionTimer();
  }

  /// Eski isim — yeni kod [onUserActivity] kullanmalı.
  @Deprecated('Use onUserActivity()')
  void extendSession() => onUserActivity();

  // ───────────────────────────── Internal

  Future<void> _restoreSession() async {
    final token = await _cache.readToken();
    final user = await _cache.readUser();

    if (token != null && user != null) {
      _tokenHolder.setToken(token);
      _setLoggedIn(user);
    }
  }

  void _setLoggedIn(AppUser user) {
    state = AuthLoggedIn(user: user);
    _startSessionTimer();
  }

  void _startSessionTimer() {
    _cancelTimers();
    if (_isPaused) return;
    final warnDelay = Duration(minutes: _config.inactivityTimeoutMinutes) - Duration(seconds: _config.warningSeconds);
    _sessionTimer = Timer(warnDelay, _startCountdown);
  }

  void _startCountdown() {
    if (state is! AuthLoggedIn) return;

    _secondsRemaining = _config.warningSeconds;
    _countdown.set(_secondsRemaining);

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _secondsRemaining--;
      if (_secondsRemaining <= 0) {
        logout(locked: true); // _cancelTimers timer'ı ve banner'ı temizler
        return;
      }
      _countdown.set(_secondsRemaining);
    });
  }

  void _cancelTimers({bool clearCountdown = true}) {
    _sessionTimer?.cancel();
    _sessionTimer = null;

    final wasWarning = _countdownTimer != null;
    _countdownTimer?.cancel();
    _countdownTimer = null;

    if (clearCountdown && wasWarning) _countdown.set(null);
  }

  void _markDashboardAccessed() {
    _hasAccessedDashboard = true;
  }
}
