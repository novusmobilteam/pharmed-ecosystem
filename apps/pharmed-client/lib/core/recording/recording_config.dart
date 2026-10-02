import 'package:pharmed_client/core/providers/camera_providers.dart' show recordingRootPath;

/// Lokal kayıt arşivi ve saklama politikası.
///
/// Boyut tahmini (ana akış, ~1-2 Mbps → dakikada 8-15 MB):
///   günde 1000 operasyon × ~1 dk ≈ 8-15 GB/gün → 7 gün ≈ 55-105 GB.
/// Bu yüzden saklama süresi tek başına yeterli değil; kota ve boş disk
/// alanı korumaları süreden ÖNCE devreye girer. Kamerada bitrate düşürmek
/// (ör. 720p / 768 kbps) en etkili tasarruftur.
class RecordingStorageConfig {
  const RecordingStorageConfig({
    required this.rootPath,
    this.maxAge = const Duration(days: 7),
    this.maxTotalBytes = 50 * _gb,
    this.minFreeDiskBytes = 10 * _gb,
    this.sweepInterval = const Duration(hours: 1),
  });

  factory RecordingStorageConfig.defaults() => RecordingStorageConfig(rootPath: recordingRootPath());

  static const _gb = 1024 * 1024 * 1024;

  final String rootPath;

  /// Sunucuya yüklenip doğrulanmış kayıtlar bu süre sonunda silinir.
  /// Yüklenmemiş kayıtlar süre dolunca SİLİNMEZ (bkz. retention sweeper).
  final Duration maxAge;

  /// Arşivdeki toplam video boyutu üst sınırı.
  final int maxTotalBytes;

  /// Diskte en az bu kadar boş alan kalmalı.
  final int minFreeDiskBytes;

  final Duration sweepInterval;
}

class RecordingUploadConfig {
  const RecordingUploadConfig({
    required this.enabled,
    this.chunkSize = 5 * 1024 * 1024,
    this.pollInterval = const Duration(minutes: 1),
    this.baseBackoff = const Duration(seconds: 30),
    this.maxBackoff = const Duration(hours: 1),
    this.maxHashMismatches = 3,
  });

  /// Varsayılan açık. API yokken bile güvenli (bkz. RecordingUploadApi).
  factory RecordingUploadConfig.fromEnvironment() =>
      const RecordingUploadConfig(enabled: bool.fromEnvironment('RECORDING_UPLOAD_ENABLED', defaultValue: true));

  final bool enabled;

  /// Parça boyutu. Bellekte aynı anda yalnızca bir parça tutulur.
  final int chunkSize;

  final Duration pollInterval;
  final Duration baseBackoff;
  final Duration maxBackoff;

  /// Sunucu hash'i bu kadar kez reddederse kayıt `rejected` olur.
  final int maxHashMismatches;
}
