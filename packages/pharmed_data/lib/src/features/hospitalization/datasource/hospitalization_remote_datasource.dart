import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class HospitalizationRemoteDataSource extends BaseRemoteDataSource {
  HospitalizationRemoteDataSource({required super.apiManager});

  final String _basePath = '/Patient/hospitalization';

  // TODO: implement logSwreq
  String get logSwreq => throw UnimplementedError();

  // TODO: implement logUnit
  String get logUnit => throw UnimplementedError();

  Future<Result<ApiResponse<List<HospitalizationDTO>>?>> getHospitalizations({
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

  Future<Result<HospitalizationDTO?>> createHospitalization(HospitalizationDTO dto) {
    return createRequest<HospitalizationDTO?>(
      path: _basePath,
      body: dto.toJson(),
      parser: BaseRemoteDataSource.singleParser(HospitalizationDTO.fromJson),
      successLog: 'PatientHospitalization created',
    );
  }

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

  Future<Result<void>> deleteHospitalization(int id) {
    return deleteRequest<void>(
      path: '$_basePath/$id',
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'PatientHospitalization deleted',
    );
  }

  Future<Result<List<HospitalizationDTO>>> getHospitalizationsWithPrescription() async {
    final res = await fetchRequest<List<HospitalizationDTO>>(
      path: '$_basePath/allDetails',
      parser: BaseRemoteDataSource.listParser(HospitalizationDTO.fromJson),
    );
    return res.when(ok: (data) => Result.ok(data ?? const <HospitalizationDTO>[]), error: Result.error);
  }

  Future<Result<List<HospitalizationDTO>>> getPatientsWithActivePrescription() async {
    final res = await fetchRequest<List<HospitalizationDTO>>(
      path: '$_basePath/materialCollect',
      parser: BaseRemoteDataSource.listParser(HospitalizationDTO.fromJson),
    );
    return res.when(ok: (data) => Result.ok(data ?? const <HospitalizationDTO>[]), error: Result.error);
  }

  Future<Result<List<HospitalizationDTO>>> getFilteredHospitalizations(PatientFilterType filter) async {
    final res = await fetchRequest<List<HospitalizationDTO>>(
      path: '/Patient/myHospitalization/${filter.id}',
      parser: BaseRemoteDataSource.listParser(HospitalizationDTO.fromJson),
    );
    return res.when(ok: (data) => Result.ok(data ?? const <HospitalizationDTO>[]), error: Result.error);
  }

  Future<Result<List<HospitalizationDTO>>> getHospitalizationsByService(int serviceId) async {
    final res = await fetchRequest<List<HospitalizationDTO>>(
      path: '$_basePath/service/$serviceId',
      parser: BaseRemoteDataSource.listParser(HospitalizationDTO.fromJson),
    );
    return res.when(ok: (data) => Result.ok(data ?? const <HospitalizationDTO>[]), error: Result.error);
  }
}
