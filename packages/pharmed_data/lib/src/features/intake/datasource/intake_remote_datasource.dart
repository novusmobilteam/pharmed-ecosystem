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

  Future<Result<List<CabinTargetedPrescriptionItemDto>?>> getIntakeItems({
    required int hospitalizationId,
    required PatientFilterType type,
  }) async {
    return await fetchRequest(
      path: '/Prescription/detail/getCollect/$hospitalizationId',
      parser: BaseRemoteDataSource.listParser(CabinTargetedPrescriptionItemDto.fromJson),
      query: {'typeId': type.id},
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

  Future<Result<List<EquivalentMedicineDto>?>> getEquivalentMedicines({required int prescriptionDetailId}) async {
    return fetchRequest<List<EquivalentMedicineDto>>(
      path: '/Prescription/detail/equivalentCheck/$prescriptionDetailId',
      parser: BaseRemoteDataSource.listParser(EquivalentMedicineDto.fromJson),
    );
  }

  Future<Result<void>> checkEquivalentIntake(Map<String, dynamic> data) {
    return postRequest(
      path: '/Prescription/detail/equivalent/checkCollect',
      parser: BaseRemoteDataSource.voidParser(),
      body: data,
    );
  }

  Future<Result<void>> completeEquivalentIntake(Map<String, dynamic> data) {
    return postRequest(
      path: '/Prescription/detail/equivalent/collect',
      parser: BaseRemoteDataSource.voidParser(),
      body: data,
    );
  }

  Future<Result<List<OtherStationMedicineDTO>?>> getOtherStationMedicines({required int prescriptionDetailId}) async {
    return fetchRequest<List<OtherStationMedicineDTO>>(
      path: '/Prescription/referral/options/$prescriptionDetailId',
      parser: BaseRemoteDataSource.listParser(OtherStationMedicineDTO.fromJson),
    );
  }

  Future<Result<void>> redirectIntake(Map<String, dynamic> data) {
    return postRequest(path: '/Prescription/referral/create', parser: BaseRemoteDataSource.voidParser(), body: data);
  }

  Future<Result<List<RedirectedIntakeOrderDTO>?>> getRedirectedIntakeOrders(int hospitalizationId) async {
    return fetchRequest<List<RedirectedIntakeOrderDTO>>(
      path: '/Prescription/referral/pending/$hospitalizationId',
      parser: BaseRemoteDataSource.listParser(RedirectedIntakeOrderDTO.fromJson),
    );
  }

  Future<Result<void>> checkRedirectedIntake(int referralId) async {
    return await postRequest(
      path: '/Prescription/referral/check/$referralId',
      parser: BaseRemoteDataSource.voidParser(),
    );
  }

  Future<Result<void>> completeRedirectedIntake({required int referralId, double? censusQuantity}) async {
    return await postRequest(
      path: '/Prescription/referral/collect/$referralId',
      parser: BaseRemoteDataSource.voidParser(),
      query: {'censusQuantity': censusQuantity},
    );
  }
}
