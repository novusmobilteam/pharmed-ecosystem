import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

/// Hasta işlemleri için uzak (API) veri kaynağı.
class PatientRemoteDataSource extends BaseRemoteDataSource {
  PatientRemoteDataSource({required super.apiManager});

  final String _basePath = '/Patient';

  // TODO: implement logSwreq
  String get logSwreq => throw UnimplementedError();

  // TODO: implement logUnit
  String get logUnit => throw UnimplementedError();

  Future<Result<ApiResponse<List<PatientDTO>>?>> getPatients({int? skip, int? take, String? search}) async {
    return fetchRequest(
      path: _basePath,
      skip: skip,
      take: take,
      searchText: search,
      searchFields: ['name'],
      envelope: ResponseEnvelope.raw,
      parser: BaseRemoteDataSource.apiResponseListParser(PatientDTO.fromJson),
      successLog: 'Patients fetched',
      emptyLog: 'No patients',
    );
  }

  Future<Result<PatientDTO?>> createPatient(PatientDTO dto) {
    return createRequest<PatientDTO?>(
      path: _basePath,
      body: dto.toJson(),
      parser: BaseRemoteDataSource.singleParser(PatientDTO.fromJson),
      successLog: 'Patient created',
    );
  }

  Future<Result<void>> updatePatient(PatientDTO dto) {
    if (dto.id == null) {
      return Future.value(Result.error(CustomException(message: 'updatePatient: id is null')));
    }
    return updateRequest(
      path: '$_basePath/${dto.id}',
      body: dto.toJson(),
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Patient updated',
    );
  }

  Future<Result<void>> deletePatient(int id) {
    return deleteRequest<void>(
      path: '$_basePath/$id',
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Patient deleted',
    );
  }

  Future<Result<void>> endEmergencyPatient({
    required int hospitalizationId,
    required int patientId,
    required List<int> prescriptionItemIds,
  }) async {
    return await createRequest(
      path: '$_basePath/merge',
      parser: BaseRemoteDataSource.voidParser(),
      body: {
        "UrgentPatientHospitalizationId": hospitalizationId.toString(),
        "PatientId": patientId,
        "PrescriptionDetailIds": prescriptionItemIds.toList(),
      },
    );
  }

  Future<Result<void>> addPatient(int userId, int hospitalizationId) async {
    return await createRequest(
      path: '/MyPatient',
      parser: BaseRemoteDataSource.voidParser(),
      body: {"userId": userId, "patientHospitalizationId": hospitalizationId},
    );
  }

  Future<Result<List<MyPatientDTO>?>> getMyPatients() async {
    return await fetchRequest(
      path: '/MyPatient',
      parser: BaseRemoteDataSource.listParser(MyPatientDTO.fromJson),
      successLog: 'My patients fetched',
      emptyLog: 'No patient',
    );
  }

  Future<Result<void>> removePatient(int id) async {
    final res = await deleteRequest(path: '/MyPatient/$id', parser: BaseRemoteDataSource.voidParser());
    return res.when(ok: (data) => Result.ok(null), error: Result.error);
  }

  Future<Result<void>> addPatiens(List<Map<String, dynamic>> data) async {
    final res = await createRequest(path: '/MyPatient/bulk', parser: BaseRemoteDataSource.voidParser(), body: data);
    return res.when(ok: (data) => Result.ok(null), error: Result.error);
  }

  Future<Result<void>> removePatients(List<int> ids) async {
    final res = await deleteBulkRequest(path: '/MyPatient/bulk', body: ids);
    return res.when(ok: (data) => Result.ok(null), error: Result.error);
  }

  Future<Result<List<PatientDTO>?>> getHospitalizedAndRecentExits() async {
    return await fetchRequest(
      path: '$_basePath/hospitalizationForExits',
      parser: BaseRemoteDataSource.listParser(PatientDTO.fromJson),
    );
  }

  Future<Result<List<UrgentPatientDTO>?>> getUrgentPatients() async {
    return await fetchRequest(
      path: '$_basePath/urgent',
      parser: BaseRemoteDataSource.listParser(UrgentPatientDTO.fromJson),
    );
  }

  Future<Result<HospitalizationDTO?>> createUrgentPatient(int serviceId) async {
    return await createRequest<HospitalizationDTO>(
      path: '$_basePath/hospitalization/urgent',
      parser: BaseRemoteDataSource.singleParser(HospitalizationDTO.fromJson),
      body: {"serviceId": serviceId},
    );
  }
}
