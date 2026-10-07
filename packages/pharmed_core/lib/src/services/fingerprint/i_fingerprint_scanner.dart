// pharmed_core/lib/src/services/fingerprint/i_fingerprint_scanner.dart
//
// [SWREQ-FP-003] [IEC 62304 §5.5]
// Parmak izi okuyucu donanım servisi soyutlaması.
//
// Akış:
//   1. open()          → SDK başlatılır, bağlı okuyucu bulunur, parametreler uygulanır
//   2. capture()       → parmak beklenir, okunur, canlılık kontrolü yapılır,
//                        şablon çıkarılır
//      cancelCapture() → bekleyen capture() 'cancelled' ile döner
//   3. close()         → SDK serbest bırakılır
//
// Notlar:
//   - Aynı anda tek bir capture() aktif olabilir; ikincisi 'busy' döner.
//   - capture() sürerken isFingerOn() 'busy' döner (okuyucu meşgul).
//   - 'deviceDisconnected' hatasından sonra okuyucu kapalı sayılır;
//     tekrar kullanmadan önce open() çağrılmalıdır.
//   - Eşleştirme bu katmanda YAPILMAZ; şablon servise gönderilir ve
//     kimlik doğrulaması sunucuda yapılır.
//
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

abstract interface class IFingerprintScanner {
  /// `open()` başarılı olduysa ve o andan beri bağlantı kopmadıysa true.
  bool get isOpen;

  /// SDK'yı başlatır ve ilk bağlı okuyucuyu açar. Zaten açıksa mevcut bilgiyi döner.
  Future<Result<FingerprintScannerInfo>> open();

  /// Parmak okutulana kadar en fazla [timeout] bekler, ardından şablon çıkarır.
  ///
  /// Şablon kalitesi [minQuality] altındaysa 'lowQuality' döner.
  /// [includeImage] yalnızca test/kurulum ekranı içindir.
  Future<Result<FingerprintCapture>> capture({
    Duration timeout = const Duration(seconds: 10),
    int minQuality = 30,
    bool includeImage = false,
  });

  /// Bekleyen capture() çağrısını iptal eder. Aktif okuma yoksa bir şey yapmaz.
  Future<void> cancelCapture();

  /// Sensörde parmak olup olmadığını sorgular (örn. çıkıştan sonra
  /// parmağın kaldırılmasını beklemek için).
  Future<Result<bool>> isFingerOn();

  /// Okuyucuyu kapatır ve SDK'yı serbest bırakır.
  Future<void> close();
}
