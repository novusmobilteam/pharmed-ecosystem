abstract interface class AuthTokenProvider {
  String? get accessToken;
  void onUnauthorized();
}

class TokenHolder implements AuthTokenProvider {
  String? _token;

  void setToken(String? token) => _token = token;

  @override
  String? get accessToken => _token;

  @override
  void onUnauthorized() {
    // AuthNotifier ref olmadan çağrılamaz — callback ile çözülür
    _onUnauthorized?.call();
  }

  void Function()? _onUnauthorized;

  void setOnUnauthorized(void Function() callback) {
    _onUnauthorized = callback;
  }
}
