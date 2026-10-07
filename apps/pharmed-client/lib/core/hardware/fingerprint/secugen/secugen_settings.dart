// pharmed-client/lib/core/hardware/fingerprint/secugen/secugen_settings.dart
//
// [SWREQ-FP-051]
// SecuGen okuyucu ayarları. Varsayılanlar SecuGen U10 (Hamster Pro 10) içindir.
//
// Geliştirmede --dart-define ile değiştirilebilir:
//   --dart-define=SECUGEN_AREA_QUALITY=0..100   (varsayılan: 50)
//   --dart-define=SECUGEN_LIVENESS=false        (varsayılan: true; yalnızca U20 ailesinde etkili)
//   --dart-define=SECUGEN_FAKE_LEVEL=1..9       (varsayılan: SDK varsayılanı)
//   --dart-define=SECUGEN_SMART_CAPTURE=false   (varsayılan: true)
//   --dart-define=SECUGEN_DLL_PATH=C:\...\sgfplib.dll
//
// Sınıf: Class B

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:pharmed_core/pharmed_core.dart';

class SecuGenSettings {
  const SecuGenSettings({
    this.templateFormat = FingerprintTemplateFormat.iso19794_2,
    this.captureAreaQuality = 50,
    this.liveness = true,
    this.fakeDetectionLevel,
    this.smartCapture = true,
  }) : assert(
         templateFormat != FingerprintTemplateFormat.suprema,
         'Suprema şablon formatı SecuGen SDK ile üretilemez',
       ),
       assert(captureAreaQuality >= 0 && captureAreaQuality <= 100),
       assert(fakeDetectionLevel == null || (fakeDetectionLevel >= 1 && fakeDetectionLevel <= 9));

  factory SecuGenSettings.fromEnvironment() {
    const area = int.fromEnvironment('SECUGEN_AREA_QUALITY', defaultValue: 50);
    const liveness = bool.fromEnvironment('SECUGEN_LIVENESS', defaultValue: true);
    const fake = int.fromEnvironment('SECUGEN_FAKE_LEVEL', defaultValue: 0);
    const smart = bool.fromEnvironment('SECUGEN_SMART_CAPTURE', defaultValue: true);
    return SecuGenSettings(
      captureAreaQuality: area.clamp(0, 100),
      liveness: liveness,
      fakeDetectionLevel: fake >= 1 && fake <= 9 ? fake : null,
      smartCapture: smart,
    );
  }

  /// Sunucudaki eşleştiricinin beklediği format.
  final FingerprintTemplateFormat templateFormat;

  /// SGFPM_GetImageEx kabul eşiği. Kılavuza göre bu değer yalnızca parmağın sensörü
  /// kaplama oranıdır (sırt kalitesi değil). Asıl kalite SGFPM_GetImageQuality ile ölçülür
  /// ve minQuality ile karşılaştırılır.
  final int captureAreaQuality;

  /// Sahte parmak kontrolünü açmayı dene. Kılavuza göre yalnızca U20 ailesi destekler;
  /// U10'da açılamaz ve okuyucu bilgisinde `livenessActive: false` görünür.
  final bool liveness;

  /// SGFPM_SetFakeDetectionLevel. null → SDK varsayılanı.
  final int? fakeDetectionLevel;

  /// SGFPM_EnableSmartCapture — ıslak/kuru parmakta görüntüyü otomatik iyileştirir
  /// (desteklemeyen cihazda yok sayılır).
  final bool smartCapture;

  @override
  String toString() =>
      'SecuGenSettings(format: ${templateFormat.wireName}, areaQuality: $captureAreaQuality, '
      'liveness: $liveness, fakeLevel: $fakeDetectionLevel, smartCapture: $smartCapture)';
}

/// Uygulamanın yanında paketlenmiş sgfplib.dll varsa onu, yoksa Windows'un DLL arama
/// yolunu kullanır. sgfplib.dll, sgfpamx.dll ve sgwsqlib.dll'i kendi klasöründen yükler;
/// üçü de exe'nin yanında olmalıdır.
String resolveSecuGenDllPath() {
  const override = String.fromEnvironment('SECUGEN_DLL_PATH');
  if (override.isNotEmpty) return override;

  final bundled = p.join(p.dirname(Platform.resolvedExecutable), 'sgfplib.dll');
  return File(bundled).existsSync() ? bundled : 'sgfplib.dll';
}
