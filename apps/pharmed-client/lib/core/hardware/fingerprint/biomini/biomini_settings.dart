// pharmed-client/lib/core/hardware/fingerprint/biomini/biomini_settings.dart
//
// [SWREQ-FP-011]
// BioMini okuyucu ayarları. Varsayılanlar BioMini Slim 2S içindir.
//
// Geliştirmede --dart-define ile değiştirilebilir:
//   --dart-define=BIOMINI_CAPTURE_MODE=host     (varsayılan: device)
//   --dart-define=BIOMINI_LFD_LEVEL=0..5        (varsayılan: 3; 0 = kapalı)
//   --dart-define=BIOMINI_SECURITY_LEVEL=1..7   (varsayılan: SDK varsayılanı)
//   --dart-define=BIOMINI_DLL_PATH=C:\...\UFScanner.dll
//
// Sınıf: Class B

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:pharmed_core/pharmed_core.dart';

/// Görüntünün yakalanıp şablonun nerede çıkarılacağı.
enum BioMiniCaptureMode {
  /// Yakalama + canlılık kontrolü + şablon çıkarma okuyucunun kendi işlemcisinde.
  /// Slim 2S'te canlılık kontrolü (LFD) YALNIZCA bu modda çalışır
  /// (UFS_PARAM_LFD_LEVEL_DEV). Varsayılan budur.
  device,

  /// Görüntü PC'ye alınır, şablon PC'de çıkarılır. Slim 2S'te LFD çalışmaz
  /// (UFS_PARAM_DETECT_FAKE yalnızca eski BioMini Slim'i destekler).
  /// Sadece teşhis/karşılaştırma için.
  host,
}

class BioMiniSettings {
  const BioMiniSettings({
    this.captureMode = BioMiniCaptureMode.device,
    this.templateFormat = FingerprintTemplateFormat.iso19794_2,
    this.lfdLevel = 3,
    this.securityLevel,
  }) : assert(lfdLevel >= 0 && lfdLevel <= 5),
       assert(securityLevel == null || (securityLevel >= 1 && securityLevel <= 7));

  factory BioMiniSettings.fromEnvironment() {
    const mode = String.fromEnvironment('BIOMINI_CAPTURE_MODE', defaultValue: 'device');
    const lfd = int.fromEnvironment('BIOMINI_LFD_LEVEL', defaultValue: 3);
    const security = int.fromEnvironment('BIOMINI_SECURITY_LEVEL', defaultValue: 0);
    return BioMiniSettings(
      captureMode: mode == 'host' ? BioMiniCaptureMode.host : BioMiniCaptureMode.device,
      lfdLevel: lfd.clamp(0, 5),
      securityLevel: security >= 1 && security <= 7 ? security : null,
    );
  }

  final BioMiniCaptureMode captureMode;

  /// Sunucudaki eşleştiricinin beklediği format. ISO 19794-2 üreticiden bağımsızdır.
  final FingerprintTemplateFormat templateFormat;

  /// Cihaz üstü canlılık kontrolü eşiği, 0–5. Yüksek değer sahte parmağa karşı
  /// daha katıdır ama gerçek parmağı reddetme ihtimali de artar; sahada ayarlanmalı.
  /// Yalnızca [BioMiniCaptureMode.device] modunda etkilidir.
  final int lfdLevel;

  /// Cihaz güvenlik seviyesi (1–7). null → SDK/cihaz varsayılanı korunur.
  final int? securityLevel;

  bool get lfdActive => captureMode == BioMiniCaptureMode.device && lfdLevel > 0;

  @override
  String toString() =>
      'BioMiniSettings(mode: ${captureMode.name}, format: ${templateFormat.wireName}, '
      'lfdLevel: $lfdLevel, securityLevel: $securityLevel)';
}

/// Uygulamanın yanında paketlenmiş UFScanner.dll varsa onu, yoksa Windows'un
/// DLL arama yolunu kullanır (SDK kurulu geliştirme makinesi).
String resolveBioMiniDllPath() {
  const override = String.fromEnvironment('BIOMINI_DLL_PATH');
  if (override.isNotEmpty) return override;

  final bundled = p.join(p.dirname(Platform.resolvedExecutable), 'UFScanner.dll');
  return File(bundled).existsSync() ? bundled : 'UFScanner.dll';
}
