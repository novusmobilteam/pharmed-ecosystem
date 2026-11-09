// [SWREQ-NET-007] Log gönderim ayarları.
//
// Backend endpoint'i (POST /api/DeviceLog/batch) hazır olana kadar gönderim
// KAPALI: kapalıyken kuyruğa da yazılmaz (disk dolmasın). Açmak için:
//   flutter build windows --dart-define=LOG_UPLOAD_ENABLED=true \
//     --dart-define=LOG_DEVICE_KEY=<istasyon anahtarı>

class LogShippingConfig {
  const LogShippingConfig({
    required this.enabled,
    this.deviceKey,
    this.appVersion = 'dev',
    this.batchSize = 200,
    this.maxBatchBytes = 1500 * 1024,
    this.flushInterval = const Duration(seconds: 30),
    this.heartbeatInterval = const Duration(minutes: 5),
    this.maxOutboxBytes = 50 * 1024 * 1024,
    this.baseBackoff = const Duration(seconds: 30),
    this.maxBackoff = const Duration(hours: 1),
  });

  factory LogShippingConfig.fromEnvironment() {
    const key = String.fromEnvironment('LOG_DEVICE_KEY');
    return const LogShippingConfig(
      enabled: bool.fromEnvironment('LOG_UPLOAD_ENABLED'),
      deviceKey: key == '' ? null : key,
      appVersion: String.fromEnvironment('APP_VERSION', defaultValue: 'dev'),
    );
  }

  final bool enabled;

  /// `X-Device-Key` — istasyon başına manager'dan üretilecek anahtar.
  final String? deviceKey;

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
