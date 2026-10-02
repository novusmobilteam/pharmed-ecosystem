import 'package:pharmed_core/pharmed_core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Kamera şifreleri — flutter_secure_storage (Windows'ta DPAPI ile şifreli,
/// yalnızca aynı Windows kullanıcısı çözebilir). [SWREQ-CAM-052]
class SecureCameraSecretStore implements ICameraSecretStore {
  const SecureCameraSecretStore({FlutterSecureStorage storage = const FlutterSecureStorage()}) : _storage = storage;

  final FlutterSecureStorage _storage;

  static String _key(String cameraId) => 'pharmed.camera.$cameraId.password';

  @override
  Future<Result<String?>> readPassword(String cameraId) async {
    try {
      return Result.ok(await _storage.read(key: _key(cameraId)));
    } catch (e) {
      // e.toString() şifre içermez; yine de mesajı sabit tutuyoruz.
      return Result.error(CacheException(message: 'Kamera şifresi okunamadı', key: cameraId, cause: e.runtimeType));
    }
  }

  @override
  Future<Result<void>> writePassword(String cameraId, String password) async {
    try {
      await _storage.write(key: _key(cameraId), value: password);
      return const Result.ok(null);
    } catch (e) {
      return Result.error(CacheException(message: 'Kamera şifresi kaydedilemedi', key: cameraId, cause: e.runtimeType));
    }
  }

  @override
  Future<Result<void>> deletePassword(String cameraId) async {
    try {
      await _storage.delete(key: _key(cameraId));
      return const Result.ok(null);
    } catch (e) {
      return Result.error(CacheException(message: 'Kamera şifresi silinemedi', key: cameraId, cause: e.runtimeType));
    }
  }
}
