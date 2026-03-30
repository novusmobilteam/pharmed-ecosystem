import '../../../../core/core.dart';
import '../../../prescription/data/model/prescription_item_dto.dart';

// Hasta İlaç İşlemleri ekranı altında yapılan Alım, Fire/İmha vb. gibi
// işlemlerin yürütüldüğü katman.
abstract class MedicineManagementDataSource {
  // Fire/İmha Ekranı
  // Reçete ID'sine göre fire/imha edilebilecekleri getirir
  Future<Result<List<PrescriptionItemDTO>>> getDisposables({required int hospitalizationId});

  // İmha Edilebilir ilaçları getiren servis
  Future<Result<List<CabinAssignmentDTO>>> getDisposableMaterials();

  // Fire/İmha Etme İşlemi
  Future<Result<void>> wastage(Map<String, dynamic> data);
  Future<Result<void>> destruction(Map<String, dynamic> data);
  Future<Result<void>> disposeMaterial(List<Map<String, dynamic>> data);
}
