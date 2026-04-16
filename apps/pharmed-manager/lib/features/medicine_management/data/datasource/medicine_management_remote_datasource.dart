import '../../../../core/core.dart';
import 'medicine_management_datasource.dart';

class MedicineManagementRemoteDataSource extends BaseRemoteDataSource implements MedicineManagementDataSource {
  MedicineManagementRemoteDataSource({required super.apiManager});

  @override
  Future<Result<List<PrescriptionItemDTO>>> getDisposables({required int hospitalizationId}) async {
    final res = await fetchRequest<List<PrescriptionItemDTO>>(
      path: '/Prescription/detail/getFireDestruction/$hospitalizationId',
      parser: BaseRemoteDataSource.listParser(PrescriptionItemDTO.fromJson),
    );
    return res.when(ok: (data) => Result.ok(data ?? const <PrescriptionItemDTO>[]), error: Result.error);
  }

  @override
  Future<Result<List<MedicineAssignmentDto>>> getDisposableMaterials() async {
    final res = await fetchRequest<List<MedicineAssignmentDto>>(
      path: '/CabinDrawrQuantity/cabinInMaterialsDestroyable',
      parser: BaseRemoteDataSource.listParser(MedicineAssignmentDto.fromJson),
    );
    return res.when(ok: (data) => Result.ok(data ?? const <MedicineAssignmentDto>[]), error: Result.error);
  }

  @override
  Future<Result<void>> destruction(Map<String, dynamic> data) async {
    final res = await createRequest(
      path: '/Prescription/detail/destruction',
      parser: BaseRemoteDataSource.voidParser(),
      body: data,
    );
    return res.when(ok: (data) => Result.ok(null), error: Result.error);
  }

  @override
  Future<Result<void>> wastage(Map<String, dynamic> data) async {
    final res = await createRequest(
      path: '/Prescription/detail/wastage',
      parser: BaseRemoteDataSource.voidParser(),
      body: data,
    );
    return res.when(ok: (data) => Result.ok(null), error: Result.error);
  }

  @override
  Future<Result<void>> disposeMaterial(List<Map<String, dynamic>> data) async {
    final res = await createRequest(
      path: '/CabinDrawrStock/destruction',
      parser: BaseRemoteDataSource.voidParser(),
      body: data,
    );
    return res.when(ok: (data) => Result.ok(null), error: Result.error);
  }

  @override
  // TODO: implement logSwreq
  String get logSwreq => throw UnimplementedError();

  @override
  // TODO: implement logUnit
  String get logUnit => throw UnimplementedError();
}
