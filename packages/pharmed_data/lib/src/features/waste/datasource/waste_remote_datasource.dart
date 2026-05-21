import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class WasteRemoteDataSource extends BaseRemoteDataSource {
  WasteRemoteDataSource({required super.apiManager});

  static const _base = '/Prescription/detail';

  @override
  String get logSwreq => 'SWREQ-DATA-WASTE-001';

  @override
  String get logUnit => 'SW-UNIT-WASTE';

  Future<Result<List<PrescriptionItemDto>>> getMasterDisposables({required int hospitalizationId}) async {
    final res = await fetchRequest<List<PrescriptionItemDto>>(
      path: '$_base/getFireDestruction/$hospitalizationId',
      parser: BaseRemoteDataSource.listParser(PrescriptionItemDto.fromJson),
    );
    return res.when(ok: (data) => Result.ok(data ?? const <PrescriptionItemDto>[]), error: Result.error);
  }

  Future<Result<List<MedicineAssignmentDto>>> getMasterDisposableMaterials() async {
    final res = await fetchRequest<List<MedicineAssignmentDto>>(
      path: '/CabinDrawrQuantity/cabinInMaterialsDestroyable',
      parser: BaseRemoteDataSource.listParser(MedicineAssignmentDto.fromJson),
    );
    return res.when(ok: (data) => Result.ok(data ?? const <MedicineAssignmentDto>[]), error: Result.error);
  }

  Future<Result<void>> masterWastage(Map<String, dynamic> data) async {
    return await postRequest(path: '$_base/wastage', parser: BaseRemoteDataSource.voidParser(), body: data);
  }

  Future<Result<void>> masterDestruction(Map<String, dynamic> data) async {
    return await postRequest(path: '$_base/destruction', parser: BaseRemoteDataSource.voidParser(), body: data);
  }

  Future<Result<void>> masterDisposeMaterial(List<Map<String, dynamic>> data) async {
    return await postRequest(
      path: '/CabinDrawrStock/destruction',
      parser: BaseRemoteDataSource.voidParser(),
      body: data,
    );
  }

  Future<Result<List<PrescriptionItemDto>>> getMobileDisposables({required int hospitalizationId}) async {
    final res = await fetchRequest<List<PrescriptionItemDto>>(
      path: '$_base/getFireDestructionMobileCabin/$hospitalizationId',
      parser: BaseRemoteDataSource.listParser(PrescriptionItemDto.fromJson),
    );
    return res.when(ok: (data) => Result.ok(data ?? const <PrescriptionItemDto>[]), error: Result.error);
  }

  Future<Result<void>> mobileWastage(Map<String, dynamic> data) async {
    return await postRequest(path: '$_base/wastageMobile', parser: BaseRemoteDataSource.voidParser(), body: data);
  }

  Future<Result<void>> mobileDestruction(Map<String, dynamic> data) async {
    return await postRequest(path: '$_base/destructionMobile', parser: BaseRemoteDataSource.voidParser(), body: data);
  }
}
