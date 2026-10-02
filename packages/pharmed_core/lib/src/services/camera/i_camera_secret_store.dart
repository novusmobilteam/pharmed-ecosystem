import 'package:pharmed_core/pharmed_core.dart';

/// Kamera şifrelerinin işletim sistemi seviyesinde şifreli saklanması
/// (Windows: DPAPI). Şifre HİÇBİR ZAMAN log'a, Hive'a, sidecar'a veya
/// sunucuya yazılmaz. [SWREQ-CAM-052]
abstract interface class ICameraSecretStore {
  Future<Result<String?>> readPassword(String cameraId);
  Future<Result<void>> writePassword(String cameraId, String password);
  Future<Result<void>> deletePassword(String cameraId);
}
