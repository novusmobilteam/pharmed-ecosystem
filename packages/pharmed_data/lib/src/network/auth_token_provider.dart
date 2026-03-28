abstract interface class AuthTokenProvider {
  String? get accessToken;
  void onUnauthorized();
}
