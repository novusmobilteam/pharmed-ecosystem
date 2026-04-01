import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class WithdrawRemoteDataSource extends BaseRemoteDataSource {
  WithdrawRemoteDataSource({required super.apiManager});

  @override
  // TODO: implement logSwreq
  String get logSwreq => throw UnimplementedError();

  @override
  // TODO: implement logUnit
  String get logUnit => throw UnimplementedError();

  Future<Result<void>> checkFreeWithdraw(Map<String, dynamic> data) async {
    return await createRequest(
      path: '/PatientIndependentMaterial/check',
      parser: BaseRemoteDataSource.voidParser(),
      body: data,
    );
  }

  Future<Result<void>> checkOrderedWithdraw(Map<String, dynamic> data) async {
    return await createRequest(
      path: '/Prescription/detail/checkCollect',
      parser: BaseRemoteDataSource.voidParser(),
      body: data,
    );
  }

  Future<Result<void>> checkOrderlessWithdraw(Map<String, dynamic> data) async {
    return await createRequest(
      path: '/Prescription/detail/OrderlessCollectCheck',
      parser: BaseRemoteDataSource.voidParser(),
      body: data,
    );
  }

  Future<Result<void>> completeFreeWithdraw(Map<String, dynamic> data) async {
    return await createRequest(
      path: '/PatientIndependentMaterial',
      parser: BaseRemoteDataSource.voidParser(),
      body: data,
    );
  }

  Future<Result<void>> completeOrderedWithdraw(Map<String, dynamic> data) async {
    return await createRequest(
      path: '/Prescription/detail/collect',
      parser: BaseRemoteDataSource.voidParser(),
      body: data,
    );
  }

  Future<Result<void>> completeOrderlessWithdraw(Map<String, dynamic> data) async {
    return await createRequest(
      path: '/Prescription/detail/OrderlessCollect',
      parser: BaseRemoteDataSource.voidParser(),
      body: data,
    );
  }

  Future<Result<void>> definePatientMedicine(Map<String, dynamic> data) async {
    return await createRequest(path: '/Patient/otherDrug', parser: BaseRemoteDataSource.voidParser(), body: data);
  }

  Future<Result<List<MedicineWithdrawItemDTO>?>> getWithdrawItems({required int hospitalizationId}) async {
    return await fetchRequest(
      path: '/Prescription/detail/getCollect/$hospitalizationId',
      parser: BaseRemoteDataSource.listParser(MedicineWithdrawItemDTO.fromJson),
    );
  }

  Future<Result<void>> withdrawPatientMedicine({required int id}) async {
    return await createRequest(path: '/Patient/otherDrugCollect/$id', parser: BaseRemoteDataSource.voidParser());
  }

  Future<Result<List<PatientMedicineWithdrawItemDTO>?>> getPatientMedicines({required int hospitalizationId}) async {
    return fetchRequest<List<PatientMedicineWithdrawItemDTO>>(
      path: '/Patient/otherDrug/$hospitalizationId',
      parser: BaseRemoteDataSource.listParser(PatientMedicineWithdrawItemDTO.fromJson),
    );
  }
}
