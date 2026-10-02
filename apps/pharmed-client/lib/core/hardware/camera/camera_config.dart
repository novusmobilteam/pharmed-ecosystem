import 'package:pharmed_core/pharmed_core.dart';

/// Hikvision IP kamera bağlantı ayarları.
///
/// Şimdilik `--dart-define` ile verilir; şifre kaynak koda girmez.
/// Üretimde kalıcı ayar/servis kaynağına taşınacak.
class CameraConfig {
  const CameraConfig({
    required this.host,
    required this.username,
    required this.password,
    this.rtspPort = 554,
    this.channel = 101,
    this.maxDuration = const Duration(minutes: 30),
    this.startupTimeout = const Duration(seconds: 10),
    this.stopTimeout = const Duration(seconds: 8),
    this.ioTimeout = const Duration(seconds: 5),
  });

  factory CameraConfig.fromEnvironment() => const CameraConfig(
    host: String.fromEnvironment('CAMERA_HOST'),
    username: String.fromEnvironment('CAMERA_USER', defaultValue: 'admin'),
    password: String.fromEnvironment('CAMERA_PASSWORD'),
    channel: int.fromEnvironment('CAMERA_CHANNEL', defaultValue: 101),
  );

  /// Kurulumda tanımlanan kamera + güvenli depodan okunan şifre. Canlı ortamın
  /// tek kaynağı budur; fromEnvironment yalnızca debug ekranı içindir.
  factory CameraConfig.fromDevice(CameraDevice device, String password) => CameraConfig(
    host: device.host.trim(),
    username: device.username,
    password: password,
    rtspPort: device.rtspPort,
    channel: device.channel,
  );

  final String host;
  final String username;
  final String password;
  final int rtspPort;

  /// 101 = ana akış, 102 = alt akış.
  final int channel;

  /// Kayıt bu süreyi aşamaz (ekran açık unutulursa güvenlik kapısı).
  final Duration maxDuration;

  /// `start()` bu süre içinde dosyaya ilk baytlar yazılmazsa başarısız sayılır.
  final Duration startupTimeout;

  /// `stop()`ta ffmpeg'in 'q' ile kapanması için beklenen süre; aşılırsa süreç öldürülür.
  final Duration stopTimeout;

  /// Kayıt sırasında akıştan bu süre veri gelmezse ffmpeg çıkar (akış kopması tespiti).
  final Duration ioTimeout;

  bool get isConfigured => host.isNotEmpty && password.isNotEmpty;

  String get rtspUrl =>
      'rtsp://${Uri.encodeComponent(username)}:'
      '${Uri.encodeComponent(password)}@$host:$rtspPort/Streaming/Channels/$channel';

  /// Loglarda kullanılacak, kimlik bilgisi içermeyen adres. [SWREQ-CAM-005]
  String get maskedRtspUrl => 'rtsp://***@$host:$rtspPort/Streaming/Channels/$channel';

  /// Metindeki şifreyi (ham ve URL-encoded hâliyle) maskeler. [SWREQ-CAM-005]
  String redact(String text) {
    if (password.isEmpty) return text;
    return text.replaceAll(Uri.encodeComponent(password), '***').replaceAll(password, '***');
  }
}
