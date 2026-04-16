import '../../../../core/core.dart';

abstract class IMedicineManagementRepository {
  // Fire/İmha Ekranı
  // Reçete ID'sine göre fire/imha edilebilecekleri getirir
  Future<Result<List<PrescriptionItem>>> getDisposables({required int hospitalizationId});
  // İmha Edilebilir ilaçları getiren servis
  Future<Result<List<MedicineAssignment>>> getDisposableMaterials();

  // 6.Fire/İmha Etme İşlemi
  Future<Result<void>> wastage(Map<String, dynamic> data);
  Future<Result<void>> destruction(Map<String, dynamic> data);
  Future<Result<void>> disposeMaterial(List<Map<String, dynamic>> data);
}
