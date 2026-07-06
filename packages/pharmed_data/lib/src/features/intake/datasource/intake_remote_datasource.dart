import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class IntakeRemoteDataSource extends BaseRemoteDataSource {
  IntakeRemoteDataSource({required super.apiManager});

  @override
  String get logSwreq => 'SWREQ-DATA-INTAKE-001';

  @override
  String get logUnit => 'SW-UNIT-INTAKE';

  Future<Result<void>> checkMobileIntake(List<Map<String, dynamic>> data) async {
    return await postRequest(
      path: '/Prescription/detail/checkCollectMobile',
      parser: BaseRemoteDataSource.voidParser(),
      body: data,
    );
  }

  Future<Result<void>> completeMobileIntake(List<Map<String, dynamic>> data) async {
    return await postRequest(
      path: '/Prescription/detail/collectMobile',
      parser: BaseRemoteDataSource.voidParser(),
      body: data,
    );
  }

  Future<Result<void>> checkFreeIntake(Map<String, dynamic> data) async {
    return await postRequest(
      path: '/PatientIndependentMaterial/check',
      parser: BaseRemoteDataSource.voidParser(),
      body: data,
    );
  }

  Future<Result<void>> checkOrderedIntake(Map<String, dynamic> data) async {
    return await postRequest(
      path: '/Prescription/detail/checkCollect',
      parser: BaseRemoteDataSource.voidParser(),
      body: data,
    );
  }

  Future<Result<void>> checkOrderlessIntake(Map<String, dynamic> data) async {
    return await postRequest(
      path: '/Prescription/detail/OrderlessCollectCheck',
      parser: BaseRemoteDataSource.voidParser(),
      body: data,
    );
  }

  Future<Result<void>> completeFreeIntake(Map<String, dynamic> data) async {
    return await postRequest(
      path: '/PatientIndependentMaterial',
      parser: BaseRemoteDataSource.voidParser(),
      body: data,
    );
  }

  Future<Result<void>> completeOrderedIntake(Map<String, dynamic> data) async {
    return await postRequest(
      path: '/Prescription/detail/collect',
      parser: BaseRemoteDataSource.voidParser(),
      body: data,
    );
  }

  Future<Result<void>> completeOrderlessIntake(Map<String, dynamic> data) async {
    return await postRequest(
      path: '/Prescription/detail/OrderlessCollect',
      parser: BaseRemoteDataSource.voidParser(),
      body: data,
    );
  }

  Future<Result<void>> definePatientMedicine(Map<String, dynamic> data) async {
    return await postRequest(path: '/Patient/otherDrug', parser: BaseRemoteDataSource.voidParser(), body: data);
  }

  Future<Result<List<MedicineIntakeItemDto>?>> getIntakeItems({required int hospitalizationId}) async {
    return await fetchRequest(
      path: '/Prescription/detail/getCollect/$hospitalizationId',
      parser: BaseRemoteDataSource.listParser(MedicineIntakeItemDto.fromJson),
    );
  }

  Future<Result<void>> intakePatientMedicine({required int id}) async {
    return await postRequest(path: '/Patient/otherDrugCollect/$id', parser: BaseRemoteDataSource.voidParser());
  }

  Future<Result<List<PatientMedicineIntakeItemDto>?>> getPatientMedicines({required int hospitalizationId}) async {
    return fetchRequest<List<PatientMedicineIntakeItemDto>>(
      path: '/Patient/otherDrug/$hospitalizationId',
      parser: BaseRemoteDataSource.listParser(PatientMedicineIntakeItemDto.fromJson),
    );
  }
}
