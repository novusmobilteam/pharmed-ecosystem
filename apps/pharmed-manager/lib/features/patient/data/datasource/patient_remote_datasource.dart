import 'package:flutter/material.dart';

import '../../../../core/core.dart';
import '../../../hospitalization/data/model/hospitalization_dto.dart';
import '../model/my_patient_dto.dart';
import '../model/patient_dto.dart';
import '../model/urgent_patient_dto.dart';
import 'patient_datasource.dart';

/// Hasta işlemleri için uzak (API) veri kaynağı.
class PatientRemoteDataSource extends BaseRemoteDataSource implements PatientDataSource {
  PatientRemoteDataSource({required super.apiManager});

  final String _basePath = '/Patient';

  @override
  // TODO: implement logSwreq
  String get logSwreq => throw UnimplementedError();

  @override
  // TODO: implement logUnit
  String get logUnit => throw UnimplementedError();

  @override
  Future<Result<ApiResponse<List<PatientDTO>>>> getPatients({int? skip, int? take, String? search}) async {
    final res = await fetchRequest<ApiResponse<List<PatientDTO>>>(
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

    return res.when(
      ok: (data) => Result.ok(data ?? const ApiResponse(data: [], totalCount: 0)),
      error: Result.error,
    );
  }

  @override
  Future<Result<PatientDTO?>> createPatient(PatientDTO dto) {
    return createRequest<PatientDTO?>(
      path: _basePath,
      body: dto.toJson(),
      parser: BaseRemoteDataSource.singleParser(PatientDTO.fromJson),
      successLog: 'Patient created',
    );
  }

  @override
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

  @override
  Future<Result<void>> deletePatient(int id) {
    return deleteRequest<void>(
      path: '$_basePath/$id',
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Patient deleted',
    );
  }

  @override
  Future<Result<void>> endEmergencyPatient({
    required int hospitalizationId,
    required int patientId,
    required List<int> prescriptionItemIds,
  }) async {
    final res = await createRequest(
      path: '$_basePath/merge',
      parser: BaseRemoteDataSource.voidParser(),
      body: {
        "UrgentPatientHospitalizationId": hospitalizationId.toString(),
        "PatientId": patientId,
        "PrescriptionDetailIds": prescriptionItemIds.toList(),
      },
    );
    return res.when(
      ok: (data) => Result.ok(null),
      error: (error) {
        debugPrint('Message:${error.message}');
        return Result.error(error);
      },
    );
  }

  @override
  Future<Result<void>> addPatient(int userId, int hospitalizationId) async {
    final res = await createRequest(
      path: '/MyPatient',
      parser: BaseRemoteDataSource.voidParser(),
      body: {"userId": userId, "patientHospitalizationId": hospitalizationId},
    );
    return res.when(ok: (data) => Result.ok(null), error: Result.error);
  }

  @override
  Future<Result<List<MyPatientDTO>>> getMyPatients() async {
    final res = await fetchRequest<List<MyPatientDTO>>(
      path: '/MyPatient',
      parser: BaseRemoteDataSource.listParser(MyPatientDTO.fromJson),
      successLog: 'My patients fetched',
      emptyLog: 'No patient',
    );
    return res.when(ok: (data) => Result.ok(data ?? const <MyPatientDTO>[]), error: Result.error);
  }

  @override
  Future<Result<void>> removePatient(int id) async {
    final res = await deleteRequest(path: '/MyPatient/$id', parser: BaseRemoteDataSource.voidParser());
    return res.when(ok: (data) => Result.ok(null), error: Result.error);
  }

  @override
  Future<Result<void>> addPatiens(List<Map<String, dynamic>> data) async {
    final res = await createRequest(path: '/MyPatient/bulk', parser: BaseRemoteDataSource.voidParser(), body: data);
    return res.when(ok: (data) => Result.ok(null), error: Result.error);
  }

  @override
  Future<Result<void>> removePatients(List<int> ids) async {
    final res = await deleteBulkRequest(path: '/MyPatient/bulk', body: ids);
    return res.when(ok: (data) => Result.ok(null), error: Result.error);
  }

  @override
  Future<Result<List<PatientDTO>>> getHospitalizedAndRecentExits() async {
    final res = await fetchRequest(
      path: '$_basePath/hospitalizationForExits',
      parser: BaseRemoteDataSource.listParser(PatientDTO.fromJson),
    );

    return res.when(ok: (data) => Result.ok(data ?? []), error: Result.error);
  }

  @override
  Future<Result<List<UrgentPatientDTO>>> getUrgentPatients() async {
    final res = await fetchRequest(
      path: '$_basePath/urgent',
      parser: BaseRemoteDataSource.listParser(UrgentPatientDTO.fromJson),
    );

    return res.when(ok: (data) => Result.ok(data ?? []), error: Result.error);
  }

  @override
  Future<Result<HospitalizationDTO?>> createUrgentPatient(int serviceId) async {
    final res = await createRequest<HospitalizationDTO>(
      path: '$_basePath/hospitalization/urgent',
      parser: BaseRemoteDataSource.singleParser(HospitalizationDTO.fromJson),
      body: {"serviceId": serviceId},
    );
    return res.when(ok: (data) => Result.ok(data), error: Result.error);
  }
}
