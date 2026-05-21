import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class HospitalizationRemoteDataSource extends BaseRemoteDataSource {
  HospitalizationRemoteDataSource({required super.apiManager});

  final String _basePath = '/Patient/hospitalization';

  @override
  String get logSwreq => 'SWREQ-DATA-HOSPITALIZATON-001';

  @override
  String get logUnit => 'SW-UNIT-HOSPITALIZATON';

  Future<Result<ApiResponse<List<HospitalizationDto>>?>> getHospitalizations({
    int? skip,
    int? take,
    String? search,
  }) async {
    final res = await fetchRequest<ApiResponse<List<HospitalizationDto>>>(
      path: _basePath,
      skip: skip,
      take: take,
      searchText: search,
      searchFields: ['patientName'],
      envelope: ResponseEnvelope.raw,
      parser: BaseRemoteDataSource.apiResponseListParser(HospitalizationDto.fromJson),
      successLog: 'PatientHospitalization list fetched',
      emptyLog: 'No patient hospitalizations',
    );

    return res.when(
      ok: (data) => Result.ok(data ?? const ApiResponse(data: [], totalCount: 0)),
      error: Result.error,
    );
  }

  Future<Result<HospitalizationDto?>> createHospitalization(HospitalizationDto dto) {
    print(dto.toJson().toString());
    return postRequest<HospitalizationDto?>(
      path: _basePath,
      body: dto.toJson(),
      parser: BaseRemoteDataSource.singleParser(HospitalizationDto.fromJson),
      successLog: 'PatientHospitalization created',
    );
  }

  Future<Result<void>> updateHospitalization(HospitalizationDto dto) {
    if (dto.id == null) {
      return Future.value(Result.error(CustomException(message: 'updatePatientHospitalization: id is null')));
    }
    return putRequest(
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

  Future<Result<List<HospitalizationDto>>> getHospitalizationsWithPrescription() async {
    final res = await fetchRequest<List<HospitalizationDto>>(
      path: '$_basePath/allDetails',
      parser: BaseRemoteDataSource.listParser(HospitalizationDto.fromJson),
    );
    return res.when(ok: (data) => Result.ok(data ?? const <HospitalizationDto>[]), error: Result.error);
  }

  Future<Result<List<HospitalizationDto>>> getPatientsWithActivePrescription() async {
    final res = await fetchRequest<List<HospitalizationDto>>(
      path: '$_basePath/materialCollect',
      parser: BaseRemoteDataSource.listParser(HospitalizationDto.fromJson),
    );
    return res.when(ok: (data) => Result.ok(data ?? const <HospitalizationDto>[]), error: Result.error);
  }

  Future<Result<List<HospitalizationDto>>> getFilteredHospitalizations(PatientFilterType filter) async {
    final res = await fetchRequest<List<HospitalizationDto>>(
      path: '/Patient/myHospitalization/${filter.id}',
      parser: BaseRemoteDataSource.listParser(HospitalizationDto.fromJson),
    );
    return res.when(ok: (data) => Result.ok(data ?? const <HospitalizationDto>[]), error: Result.error);
  }

  Future<Result<List<HospitalizationDto>>> getHospitalizationsByService(int serviceId) async {
    final res = await fetchRequest<List<HospitalizationDto>>(
      path: '$_basePath/service/$serviceId',
      parser: BaseRemoteDataSource.listParser(HospitalizationDto.fromJson),
    );
    return res.when(ok: (data) => Result.ok(data ?? const <HospitalizationDto>[]), error: Result.error);
  }
}
