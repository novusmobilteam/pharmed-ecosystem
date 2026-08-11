import 'package:pharmed_core/pharmed_core.dart';

import '../unload.dart';

class UnloadRepositoryImpl implements IUnloadRepository {
  final UnloadRemoteDataSource _dataSource;

  UnloadRepositoryImpl({required UnloadRemoteDataSource dataSource}) : _dataSource = dataSource;

  @override
  Future<Result<void>> masterUnload(List<Map<String, dynamic>> data) async {
    return _dataSource.masterUnload(data);
  }

  @override
  Future<Result<void>> mobileUnload(List<Map<String, dynamic>> data) async {
    return _dataSource.mobileUnload(data);
  }

  @override
  Future<Result<List<ReturnDrawerMedicine>?>> getReturnDrawerMedicines() async {
    final result = await _dataSource.getReturnDrawerMedicines();
    return result.when(
      ok: (dtos) => Result.ok(ReturnDrawerMedicineMapper().toEntityList(dtos ?? [])),
      error: Result.error,
    );
  }

  @override
  Future<Result<void>> unloadReturnDrawer(List<int> medicineIds) async {
    return _dataSource.unloadReturnDrawer(medicineIds);
  }

  @override
  Future<Result<List<ReturnDrawerMedicine>?>> getReturnBoxMedicines() async {
    final result = await _dataSource.getReturnBoxMedicines();
    return result.when(
      ok: (dtos) => Result.ok(ReturnDrawerMedicineMapper().toEntityList(dtos ?? [])),
      error: Result.error,
    );
  }

  @override
  Future<Result<void>> unloadReturnBox(List<int> medicineIds) async {
    return _dataSource.unloadReturnBox(medicineIds);
  }
}
