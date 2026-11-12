// [SWREQ-NET-001] [SWREQ-DATA-AUTH-005]
// APIManager ile auth katmanı arasındaki köprü.
// Sınıf: Class B

abstract interface class AuthTokenProvider {
  String? get accessToken;
  void onUnauthorized();
  String get currentLocale;

  /// [SWREQ-DATA-AUTH-005] Access token'ı refresh token ile yeniler.
  /// Başarılıysa `true` — yeni token [accessToken]'dan okunabilir.
  /// Eşzamanlı çağrılar tek bir refresh isteğinde birleşir.
  Future<bool> refreshAccessToken();
}

class TokenHolder implements AuthTokenProvider {
  String? _token;
  String _locale = 'tr';

  void setToken(String? token) => _token = token;

  @override
  String? get accessToken => _token;

  @override
  String get currentLocale => _locale;

  @override
  void onUnauthorized() {
    // AuthNotifier ref olmadan çağrılamaz — callback ile çözülür
    _onUnauthorized?.call();
  }

  void Function()? _onUnauthorized;

  void setOnUnauthorized(void Function() callback) {
    _onUnauthorized = callback;
  }

  void setLocale(String locale) {
    _locale = locale;
  }

  // ── Refresh ─────────────────────────────────────────────────────

  Future<bool> Function()? _refreshHandler;
  Future<bool>? _inFlightRefresh;

  /// Composition root'ta bağlanır (RefreshSessionUseCase). Handler yeni
  /// token'ı [setToken] ile yazmaktan sorumludur (AuthRepositoryImpl yazar).
  void setRefreshHandler(Future<bool> Function()? handler) {
    _refreshHandler = handler;
  }

  /// Single-flight: aynı anda 401 alan N istek tek bir refresh çağrısını
  /// bekler. Handler yoksa veya hata fırlatırsa `false`.
  @override
  Future<bool> refreshAccessToken() {
    final existing = _inFlightRefresh;
    if (existing != null) return existing;

    final handler = _refreshHandler;
    if (handler == null) return Future.value(false);

    final future = _runRefresh(handler);
    _inFlightRefresh = future;
    future.whenComplete(() {
      if (identical(_inFlightRefresh, future)) _inFlightRefresh = null;
    });
    return future;
  }

  static Future<bool> _runRefresh(Future<bool> Function() handler) async {
    try {
      return await handler();
    } catch (_) {
      return false;
    }
  }
}
