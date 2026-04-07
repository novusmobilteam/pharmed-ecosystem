class AuthConfig {
  const AuthConfig({required this.inactivityTimeoutMinutes, this.warningSeconds = 60});

  /// Ekrana dokunulmadan geçen süre (dakika).
  /// pharmed_client  → 10
  /// pharmed_manager → 30
  final int inactivityTimeoutMinutes;

  /// Timeout'tan kaç saniye önce uyarı gösterilir.
  final int warningSeconds;
}
