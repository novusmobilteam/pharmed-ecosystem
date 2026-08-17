import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

class HospitalizationRepositoryImpl implements IHospitalizationRepository {
  HospitalizationRepositoryImpl({
    required HospitalizationRemoteDataSource dataSource,
    required HospitalizationMapper mapper,
  }) : _dataSource = dataSource,
       _mapper = mapper;

  final HospitalizationRemoteDataSource _dataSource;
  final HospitalizationMapper _mapper;

  @override
  Future<Result<ApiResponse<List<Hospitalization>>>> getHospitalizations(PagedQueryParams params) async {
    final result = await _dataSource.getHospitalizations(params);
    return result.when(
      ok: (apiResponse) => Result.ok(
        ApiResponse<List<Hospitalization>>(
          data: apiResponse?.data != null ? _mapper.toEntityList(apiResponse!.data!) : null,
          isSuccess: apiResponse?.isSuccess ?? true,
          totalCount: apiResponse?.totalCount,
        ),
      ),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<ApiResponse<List<Hospitalization>>>> getActiveHospitalizations(PagedQueryParams params) async {
    final result = await _dataSource.getActiveHospitalizations(params);
    return result.when(
      ok: (apiResponse) => Result.ok(
        ApiResponse<List<Hospitalization>>(
          data: apiResponse?.data != null ? _mapper.toEntityList(apiResponse!.data!) : null,
          isSuccess: apiResponse?.isSuccess ?? true,
          totalCount: apiResponse?.totalCount,
        ),
      ),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<ApiResponse<List<Hospitalization>>>> getHospitalizationsByService(
    PagedQueryParams params, {
    required int serviceId,
    required PatientFilterType filter,
    bool myPatients = false,
  }) async {
    final result = await _dataSource.getHospitalizationsByService(
      params,
      filter: filter,
      serviceId: serviceId,
      myPatients: myPatients,
    );
    return result.when(
      ok: (apiResponse) => Result.ok(
        ApiResponse<List<Hospitalization>>(
          data: apiResponse?.data != null ? _mapper.toEntityList(apiResponse!.data!) : null,
          isSuccess: apiResponse?.isSuccess ?? true,
          totalCount: apiResponse?.totalCount,
        ),
      ),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<void>> createHospitalization(Hospitalization entity) async {
    final result = await _dataSource.createHospitalization(_mapper.toDto(entity));
    return result.when(ok: (_) => const Result.ok(null), error: (e) => Result.error(e));
  }

  @override
  Future<Result<void>> updateHospitalization(Hospitalization entity) async {
    final result = await _dataSource.updateHospitalization(_mapper.toDto(entity));
    return result.when(ok: (_) => const Result.ok(null), error: (e) => Result.error(e));
  }

  @override
  Future<Result<void>> deleteHospitalization(Hospitalization entity) async {
    if (entity.id == null) {
      return Result.error(
        ValidationException(message: contextlessL10n().dataGuard_deleteHospitalizationIdEmpty, field: 'id'),
      );
    }
    final result = await _dataSource.deleteHospitalization(entity.id!);
    return result.when(ok: (_) => const Result.ok(null), error: (e) => Result.error(e));
  }

  @override
  Future<Result<List<Hospitalization>>> getPatientsWithActivePrescription() async {
    final r = await _dataSource.getPatientsWithActivePrescription();
    return r.when(ok: (dtos) => Result.ok(_mapper.toEntityList(dtos)), error: (e) => Result.error(e));
  }

  @override
  Future<Result<void>> discharge(int hospitalizationId) async {
    final result = await _dataSource.discharge(hospitalizationId);
    return result.when(ok: (dtos) => Result.ok(null), error: (e) => Result.error(e));
  }
}
