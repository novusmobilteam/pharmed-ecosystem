enum CameraRecordingFailureReason {
  /// Geçersiz sessionId veya eksik kamera yapılandırması.
  invalidInput,

  /// Aktif bir kayıt varken yeni kayıt istendi.
  busy,

  /// Aktif kayıt yokken stop istendi.
  notRecording,

  /// ffmpeg çalıştırılabilir dosyası bulunamadı/başlatılamadı.
  ffmpegNotFound,

  /// Kamera kimlik bilgisini reddetti (RTSP 401).
  authenticationFailed,

  /// ffmpeg başlatma sırasında çıktı (ağ, port, kamera kapalı vb.).
  streamUnreachable,

  /// Akış belirlenen sürede dosyaya yazılmaya başlamadı.
  startupTimeout,

  /// Başlatma sürerken kayıt iptal edildi.
  aborted,

  /// Kayıt bitti ama dosya boş/yok.
  emptyOutput,

  unexpected,
}
