import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class HospitalizationRepositoryImpl implements IHospitalizationRepository {
  HospitalizationRepositoryImpl({
    required HospitalizationRemoteDataSource dataSource,
    required HospitalizationMapper mapper,
  }) : _dataSource = dataSource,
       _mapper = mapper;

  final HospitalizationRemoteDataSource _dataSource;
  final HospitalizationMapper _mapper;

  @override
  Future<Result<ApiResponse<List<Hospitalization>>>> getHospitalizations({int? skip, int? take, String? search}) async {
    final result = await _dataSource.getHospitalizations(skip: skip, take: take, search: search);
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
      return Result.error(ValidationException(message: "Silinecek yatışın id'si boş olamaz", field: 'id'));
    }
    final result = await _dataSource.deleteHospitalization(entity.id!);
    return result.when(ok: (_) => const Result.ok(null), error: (e) => Result.error(e));
  }

  @override
  Future<Result<List<Hospitalization>>> getHospitalizationsWithPrescription() async {
    final r = await _dataSource.getHospitalizationsWithPrescription();
    return r.when(ok: (dtos) => Result.ok(_mapper.toEntityList(dtos)), error: (e) => Result.error(e));
  }

  @override
  Future<Result<List<Hospitalization>>> getPatientsWithActivePrescription() async {
    final r = await _dataSource.getPatientsWithActivePrescription();
    return r.when(ok: (dtos) => Result.ok(_mapper.toEntityList(dtos)), error: (e) => Result.error(e));
  }

  @override
  Future<Result<List<Hospitalization>>> getFilteredHospitalizations(PatientFilterType filter) async {
    final r = await _dataSource.getFilteredHospitalizations(filter);
    return r.when(ok: (dtos) => Result.ok(_mapper.toEntityList(dtos)), error: (e) => Result.error(e));
  }

  @override
  Future<Result<List<Hospitalization>>> getHospitalizationsByService(int serviceId) async {
    final r = await _dataSource.getHospitalizationsByService(serviceId);
    return r.when(ok: (dtos) => Result.ok(_mapper.toEntityList(dtos)), error: (e) => Result.error(e));
  }
}
