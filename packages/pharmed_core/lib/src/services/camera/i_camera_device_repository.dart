import 'package:pharmed_core/pharmed_core.dart';

/// İstasyonun kamera tanımları. Şimdilik lokal (Hive); kamera API'si gelirse
/// sunucu implementasyonu eklenir — kullanan taraflar değişmez.
abstract interface class ICameraDeviceRepository {
  Future<Result<List<CameraDevice>>> getAll();

  /// Ekler veya günceller (id'ye göre).
  Future<Result<void>> save(CameraDevice device);

  Future<Result<void>> delete(String id);

  /// Tanımlar değiştiğinde yayılır (kaydedici havuzu eski bağlantıyı bırakır).
  Stream<void> get changes;
}
