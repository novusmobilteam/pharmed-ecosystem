import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

class HospitalizationRemoteDataSource extends BaseRemoteDataSource {
  HospitalizationRemoteDataSource({required super.apiManager});

  final String _basePath = '/Patient/hospitalization';

  @override
  String get logSwreq => 'SWREQ-DATA-HOSPITALIZATON-001';

  @override
  String get logUnit => 'SW-UNIT-HOSPITALIZATON';

  Future<Result<ApiResponse<List<HospitalizationDto>>?>> getHospitalizations(PagedQueryParams params) async {
    final res = await fetchRequest<ApiResponse<List<HospitalizationDto>>>(
      path: '$_basePath/all',
      skip: params.skip,
      take: params.take,
      searchQuery: params.searchQuery,
      startDate: params.startDate,
      endDate: params.endDate,
      dateField: 'admissionDate',
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

  Future<Result<ApiResponse<List<HospitalizationDto>>?>> getActiveHospitalizations(PagedQueryParams params) async {
    final res = await fetchRequest<ApiResponse<List<HospitalizationDto>>>(
      path: '$_basePath/currentAll',
      skip: params.skip,
      take: params.take,
      searchQuery: params.searchQuery,
      startDate: params.startDate,
      endDate: params.endDate,
      searchFields: ['patientName'],
      dateField: 'admissionDate',

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

  Future<Result<ApiResponse<List<HospitalizationDto>>?>> getHospitalizationsByService(
    PagedQueryParams params, {
    required int serviceId,
    required PatientFilterType filter,
    bool myPatients = false,
  }) async {
    final res = await fetchRequest<ApiResponse<List<HospitalizationDto>>>(
      path: '$_basePath/service/$serviceId',
      query: {'typeId': filter.id, 'myPatient': myPatients},
      skip: params.skip,
      take: params.take,
      searchQuery: params.searchQuery,
      startDate: params.startDate,
      endDate: params.endDate,
      searchFields: ['patientName'],
      dateField: 'admissionDate',

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
      return Future.value(
        Result.error(CustomException(message: contextlessL10n().dataGuard_updateHospitalizationIdEmpty)),
      );
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

  Future<Result<List<HospitalizationDto>>> getPatientsWithActivePrescription() async {
    final res = await fetchRequest<List<HospitalizationDto>>(
      path: '$_basePath/materialCollect',
      parser: BaseRemoteDataSource.listParser(HospitalizationDto.fromJson),
    );
    return res.when(ok: (data) => Result.ok(data ?? const <HospitalizationDto>[]), error: Result.error);
  }

  Future<Result<void>> discharge(int hospitalizationId) async {
    final res = await putRequest(
      path: '/Patient/hospitalizationExit/$hospitalizationId',
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'PatientHospitalization discharged',
    );

    return res.when(ok: (_) => Result.ok(null), error: (error) => Result.error(error));
  }
}
