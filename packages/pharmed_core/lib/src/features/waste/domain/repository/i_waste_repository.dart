import 'package:pharmed_core/pharmed_core.dart';

abstract interface class IWasteRepository {
  // ─── Master Kabin ───────────────────────────────────────────────

  /// Seçili hastaya ait, master kabinde fire/imha edilebilir ilaçları getirir.
  Future<Result<List<PrescriptionItem>>> getMasterDisposables({required int hospitalizationId});

  /// Master kabinde bulunan, hasta bağımsız imha edilebilir ilaçları getirir.
  Future<Result<List<MedicineAssignment>>> getMasterDisposableMaterials();

  /// Master kabinde seçili ilaçları fire eder.
  Future<Result<void>> masterWastage(Map<String, dynamic> data);

  /// Master kabinde seçili ilaçları imha eder.
  Future<Result<void>> masterDestruction(Map<String, dynamic> data);

  /// Master kabinde imha edilebilir ilaçları imha eder.
  Future<Result<void>> masterDisposeMaterial(List<Map<String, dynamic>> data);

  // ─── Mobil Kabin ────────────────────────────────────────────────

  /// Seçili hastaya ait, mobil kabinde fire/imha edilebilir ilaçları getirir.
  Future<Result<List<PrescriptionItem>>> getMobileDisposables({required int hospitalizationId});

  /// Mobil kabinde seçili ilaçları fire eder.
  Future<Result<void>> mobileWastage(Map<String, dynamic> data);

  /// Mobil kabinde seçili ilaçları imha eder.
  Future<Result<void>> mobileDestruction(Map<String, dynamic> data);
}
