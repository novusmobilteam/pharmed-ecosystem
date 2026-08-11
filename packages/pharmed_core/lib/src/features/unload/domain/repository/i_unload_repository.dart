import 'package:pharmed_core/pharmed_core.dart';

abstract interface class IUnloadRepository {
  /// Master kabin ilaç boşaltma servisi
  Future<Result<void>> masterUnload(List<Map<String, dynamic>> data);

  /// Mobil kabin ilaç boşaltma servisi
  Future<Result<void>> mobileUnload(List<Map<String, dynamic>> data);

  Future<Result<List<ReturnDrawerMedicine>?>> getReturnDrawerMedicines();

  Future<Result<List<ReturnDrawerMedicine>?>> getReturnBoxMedicines();

  Future<Result<void>> unloadReturnDrawer(List<int> medicineIds);

  Future<Result<void>> unloadReturnBox(List<int> medicineIds);
}
