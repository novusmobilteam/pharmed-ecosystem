import '../../../../core/core.dart';
import '../model/hospitalization_dto.dart';
import 'hospitalization_datasource.dart';

/// Hasta Yatış işlemleri için uzak (API) veri kaynağı.
class HospitalizationRemoteDataSource extends BaseRemoteDataSource implements HospitalizationDataSource {
  final String _basePath = '/Patient/hospitalization';

  HospitalizationRemoteDataSource({required super.apiManager});

  @override
  Future<Result<ApiResponse<List<HospitalizationDTO>>>> getHospitalizations({
    int? skip,
    int? take,
    String? search,
  }) async {
    final res = await fetchRequest<ApiResponse<List<HospitalizationDTO>>>(
      path: _basePath,
      skip: skip,
      take: take,
      searchText: search,
      searchField: 'patientName',
      envelope: ResponseEnvelope.raw,
      parser: apiResponseListParser(HospitalizationDTO.fromJson),
      successLog: 'PatientHospitalization list fetched',
      emptyLog: 'No patient hospitalizations',
    );

    return res.when(
      ok: (data) => Result.ok(data ?? const ApiResponse(data: [], totalCount: 0)),
      error: Result.error,
    );
  }

  @override
  Future<Result<HospitalizationDTO?>> createHospitalization(
    HospitalizationDTO dto,
  ) {
    return createRequest<HospitalizationDTO?>(
      path: _basePath,
      body: dto.toJson(),
      parser: singleParser(HospitalizationDTO.fromJson),
      successLog: 'PatientHospitalization created',
    );
  }

  @override
  Future<Result<void>> updateHospitalization(
    HospitalizationDTO dto,
  ) {
    if (dto.id == null) {
      return Future.value(Result.error(CustomException(message: 'updatePatientHospitalization: id is null')));
    }
    return updateRequest(
      path: '$_basePath/${dto.id}',
      body: dto.toJson(),
      parser: voidParser(),
      successLog: 'PatientHospitalization updated',
    );
  }

  @override
  Future<Result<void>> deleteHospitalization(int id) {
    return deleteRequest<void>(
      path: '$_basePath/$id',
      parser: voidParser(),
      successLog: 'PatientHospitalization deleted',
    );
  }

  @override
  Future<Result<List<HospitalizationDTO>>> getHospitalizationsWithPrescription() async {
    final res = await fetchRequest<List<HospitalizationDTO>>(
      path: '$_basePath/allDetails',
      parser: listParser(HospitalizationDTO.fromJson),
    );
    return res.when(
      ok: (data) => Result.ok(data ?? const <HospitalizationDTO>[]),
      error: Result.error,
    );
  }

  @override
  Future<Result<List<HospitalizationDTO>>> getPatientsWithActivePrescription() async {
    final res = await fetchRequest<List<HospitalizationDTO>>(
      path: '$_basePath/materialCollect',
      parser: listParser(HospitalizationDTO.fromJson),
    );
    return res.when(
      ok: (data) => Result.ok(data ?? const <HospitalizationDTO>[]),
      error: Result.error,
    );
  }

  @override
  Future<Result<List<HospitalizationDTO>>> getFilteredHospitalizations(PatientFilterType filter) async {
    final res = await fetchRequest<List<HospitalizationDTO>>(
      path: '/Patient/myHospitalization/${filter.id}',
      parser: listParser(HospitalizationDTO.fromJson),
    );
    return res.when(
      ok: (data) => Result.ok(data ?? const <HospitalizationDTO>[]),
      error: Result.error,
    );
  }

  @override
  Future<Result<List<HospitalizationDTO>>> getHospitalizationsByService(int serviceId) async {
    final res = await fetchRequest<List<HospitalizationDTO>>(
      path: '$_basePath/service/$serviceId',
      parser: listParser(HospitalizationDTO.fromJson),
    );
    return res.when(
      ok: (data) => Result.ok(data ?? const <HospitalizationDTO>[]),
      error: Result.error,
    );
  }
}
