// [SWREQ-NET-007] Log gönderim ayarları.
//
// Backend: POST /api/FrontendLog/batch. Varsayılan AÇIK; kapatmak için
//   --dart-define=LOG_UPLOAD_ENABLED=false
// Kapalıyken kuyruğa da yazılmaz (disk dolmasın).

class LogShippingConfig {
  const LogShippingConfig({
    required this.enabled,
    this.application = 'pharmed-client',
    this.appVersion = 'dev',
    this.batchSize = 200,
    this.maxBatchBytes = 1500 * 1024,
    this.flushInterval = const Duration(seconds: 30),
    this.heartbeatInterval = const Duration(minutes: 5),
    this.maxOutboxBytes = 50 * 1024 * 1024,
    this.baseBackoff = const Duration(seconds: 30),
    this.maxBackoff = const Duration(hours: 1),
  });

  factory LogShippingConfig.fromEnvironment() => const LogShippingConfig(
    enabled: bool.fromEnvironment('LOG_UPLOAD_ENABLED', defaultValue: true),
    appVersion: String.fromEnvironment('APP_VERSION', defaultValue: 'dev'),
  );

  final bool enabled;

  /// Backend'de logu üreten uygulamayı ayırt eder (device.application, ≤ 32).
  final String application;

  /// Build sırasında `--dart-define=APP_VERSION=…` ile verilir.
  final String appVersion;

  /// Toplu gönderim başına en fazla kayıt (sözleşme sınırı 500).
  final int batchSize;

  /// Toplu gönderim gövdesi üst sınırı (sözleşme sınırı 2 MB).
  final int maxBatchBytes;

  final Duration flushInterval;

  /// Bu süre boyunca hiçbir şey gönderilmediyse boş toplu gönderim yapılır
  /// (panelde kiosk "çevrimiçi" görünsün).
  final Duration heartbeatInterval;

  /// Kuyruk bu boyutu aşarsa en eski kayıtlar düşürülür (uzun ağ kesintisi).
  final int maxOutboxBytes;

  final Duration baseBackoff;
  final Duration maxBackoff;
}
