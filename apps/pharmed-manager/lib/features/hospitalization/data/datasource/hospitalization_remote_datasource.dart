import '../../../../core/core.dart';
import '../model/hospitalization_dto.dart';
import 'hospitalization_datasource.dart';

/// Hasta Yatış işlemleri için uzak (API) veri kaynağı.
class HospitalizationRemoteDataSource extends BaseRemoteDataSource implements HospitalizationDataSource {
  HospitalizationRemoteDataSource({required super.apiManager});

  final String _basePath = '/Patient/hospitalization';

  @override
  // TODO: implement logSwreq
  String get logSwreq => throw UnimplementedError();

  @override
  // TODO: implement logUnit
  String get logUnit => throw UnimplementedError();

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
      searchFields: ['patientName'],
      envelope: ResponseEnvelope.raw,
      parser: BaseRemoteDataSource.apiResponseListParser(HospitalizationDTO.fromJson),
      successLog: 'PatientHospitalization list fetched',
      emptyLog: 'No patient hospitalizations',
    );

    return res.when(
      ok: (data) => Result.ok(data ?? const ApiResponse(data: [], totalCount: 0)),
      error: Result.error,
    );
  }

  @override
  Future<Result<HospitalizationDTO?>> createHospitalization(HospitalizationDTO dto) {
    return createRequest<HospitalizationDTO?>(
      path: _basePath,
      body: dto.toJson(),
      parser: BaseRemoteDataSource.singleParser(HospitalizationDTO.fromJson),
      successLog: 'PatientHospitalization created',
    );
  }

  @override
  Future<Result<void>> updateHospitalization(HospitalizationDTO dto) {
    if (dto.id == null) {
      return Future.value(Result.error(CustomException(message: 'updatePatientHospitalization: id is null')));
    }
    return updateRequest(
      path: '$_basePath/${dto.id}',
      body: dto.toJson(),
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'PatientHospitalization updated',
    );
  }

  @override
  Future<Result<void>> deleteHospitalization(int id) {
    return deleteRequest<void>(
      path: '$_basePath/$id',
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'PatientHospitalization deleted',
    );
  }

  @override
  Future<Result<List<HospitalizationDTO>>> getHospitalizationsWithPrescription() async {
    final res = await fetchRequest<List<HospitalizationDTO>>(
      path: '$_basePath/allDetails',
      parser: BaseRemoteDataSource.listParser(HospitalizationDTO.fromJson),
    );
    return res.when(ok: (data) => Result.ok(data ?? const <HospitalizationDTO>[]), error: Result.error);
  }

  @override
  Future<Result<List<HospitalizationDTO>>> getPatientsWithActivePrescription() async {
    final res = await fetchRequest<List<HospitalizationDTO>>(
      path: '$_basePath/materialCollect',
      parser: BaseRemoteDataSource.listParser(HospitalizationDTO.fromJson),
    );
    return res.when(ok: (data) => Result.ok(data ?? const <HospitalizationDTO>[]), error: Result.error);
  }

  @override
  Future<Result<List<HospitalizationDTO>>> getFilteredHospitalizations(PatientFilterType filter) async {
    final res = await fetchRequest<List<HospitalizationDTO>>(
      path: '/Patient/myHospitalization/${filter.id}',
      parser: BaseRemoteDataSource.listParser(HospitalizationDTO.fromJson),
    );
    return res.when(ok: (data) => Result.ok(data ?? const <HospitalizationDTO>[]), error: Result.error);
  }

  @override
  Future<Result<List<HospitalizationDTO>>> getHospitalizationsByService(int serviceId) async {
    final res = await fetchRequest<List<HospitalizationDTO>>(
      path: '$_basePath/service/$serviceId',
      parser: BaseRemoteDataSource.listParser(HospitalizationDTO.fromJson),
    );
    return res.when(ok: (data) => Result.ok(data ?? const <HospitalizationDTO>[]), error: Result.error);
  }
}
