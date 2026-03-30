import '../../../../core/core.dart';
import '../../../prescription/data/model/prescription_item_dto.dart';
import 'medicine_management_datasource.dart';

class MedicineManagementRemoteDataSource extends BaseRemoteDataSource implements MedicineManagementDataSource {
  MedicineManagementRemoteDataSource({required super.apiManager});

  @override
  Future<Result<List<PrescriptionItemDTO>>> getDisposables({required int hospitalizationId}) async {
    final res = await fetchRequest<List<PrescriptionItemDTO>>(
      path: '/Prescription/detail/getFireDestruction/$hospitalizationId',
      parser: listParser(PrescriptionItemDTO.fromJson),
    );
    return res.when(ok: (data) => Result.ok(data ?? const <PrescriptionItemDTO>[]), error: Result.error);
  }

  @override
  Future<Result<List<CabinAssignmentDTO>>> getDisposableMaterials() async {
    final res = await fetchRequest<List<CabinAssignmentDTO>>(
      path: '/CabinDrawrQuantity/cabinInMaterialsDestroyable',
      parser: listParser(CabinAssignmentDTO.fromJson),
    );
    return res.when(ok: (data) => Result.ok(data ?? const <CabinAssignmentDTO>[]), error: Result.error);
  }

  @override
  Future<Result<void>> destruction(Map<String, dynamic> data) async {
    final res = await createRequest(path: '/Prescription/detail/destruction', parser: voidParser(), body: data);
    return res.when(ok: (data) => Result.ok(null), error: Result.error);
  }

  @override
  Future<Result<void>> wastage(Map<String, dynamic> data) async {
    final res = await createRequest(path: '/Prescription/detail/wastage', parser: voidParser(), body: data);
    return res.when(ok: (data) => Result.ok(null), error: Result.error);
  }

  @override
  Future<Result<void>> disposeMaterial(List<Map<String, dynamic>> data) async {
    final res = await createRequest(path: '/CabinDrawrStock/destruction', parser: voidParser(), body: data);
    return res.when(ok: (data) => Result.ok(null), error: Result.error);
  }
}
