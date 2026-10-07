// [SWREQ-FP-002]
// Parmak izi okumasının sonucu. Donanımdan bağımsızdır; BioMini dışındaki bir
// okuyucuya geçilirse de aynı model kullanılır.
//
// KVKK: Şablon biyometrik veridir. Bu model diske yazılmaz ve loglanmaz;
// yalnızca bellekte tutulup servise gönderilir. `toString` içeriği bilerek gizler.
//
// Sınıf: Class B

import 'dart:typed_data';

/// Şablonun formatı. Sunucu tarafındaki eşleştirici bu formatı bilmek zorundadır.
enum FingerprintTemplateFormat {
  /// Suprema'ya özgü format — yalnızca Suprema eşleştiricileriyle çalışır.
  suprema('SUPREMA'),

  /// ISO/IEC 19794-2 — üreticiden bağımsız, varsayılan tercih.
  iso19794_2('ISO19794-2'),

  /// ANSI INCITS 378.
  ansi378('ANSI378');

  const FingerprintTemplateFormat(this.wireName);

  /// Servis sözleşmesinde gönderilecek değer.
  final String wireName;
}

/// Okunan parmak izinin ham görüntüsü (8 bit gri tonlama, satır satır).
///
/// Yalnızca kurulum/test ekranında kaliteyi gözle kontrol etmek içindir;
/// servise gönderilmez ve saklanmaz.
class FingerprintImage {
  const FingerprintImage({
    required this.width,
    required this.height,
    required this.resolutionDpi,
    required this.pixels,
  });

  final int width;
  final int height;
  final int resolutionDpi;

  /// `width * height` uzunluğunda, her bayt bir pikselin parlaklığı.
  final Uint8List pixels;

  @override
  String toString() => 'FingerprintImage(${width}x$height @${resolutionDpi}dpi)';
}

class FingerprintCapture {
  const FingerprintCapture({
    required this.template,
    required this.format,
    required this.quality,
    required this.capturedAt,
    this.lfdScore,
    this.image,
  });

  /// Çıkarılan şablon. Servise bu gönderilir (base64).
  final Uint8List template;

  final FingerprintTemplateFormat format;

  /// Şablon kalitesi, 1–100. Üretici önerisi: eşleştirme için ≥30, kayıt için ≥50.
  final int quality;

  /// Cihazın canlılık (LFD) skoru. LFD kapalıysa veya okuyucu desteklemiyorsa null.
  final int? lfdScore;

  final DateTime capturedAt;

  /// Yalnızca `includeImage: true` ile istendiğinde dolu.
  final FingerprintImage? image;

  int get templateSize => template.length;

  @override
  String toString() =>
      'FingerprintCapture(format: ${format.wireName}, quality: $quality, '
      'lfdScore: $lfdScore, templateSize: $templateSize)';
}

/// `open()` sonrası okuyucu hakkında bilgi. Loglama ve kurulum ekranı için.
class FingerprintScannerInfo {
  const FingerprintScannerInfo({
    required this.model,
    required this.scannerType,
    this.vendor = 'unknown',
    this.livenessActive = false,
    this.serial,
    this.sdkVersion,
  });

  /// Üretici: 'suprema', 'secugen', 'mock'. Servise gönderilen gövdede ve loglarda kullanılır.
  final String vendor;

  /// Canlılık (sahte parmak) kontrolü bu okuyucuda GERÇEKTEN etkin mi.
  /// false ise sahte parmak tespit edilmez — kullanıcı arayüzü ve loglar bunu belirtmeli.
  final bool livenessActive;

  /// İnsan tarafından okunabilir model adı, örn. "BioMini Slim 2S".
  final String model;

  /// Üreticinin sayısal tip kodu.
  final int scannerType;

  final String? serial;
  final String? sdkVersion;

  @override
  String toString() =>
      'FingerprintScannerInfo($vendor $model, type: $scannerType, liveness: $livenessActive, '
      'serial: $serial, sdk: $sdkVersion)';
}
