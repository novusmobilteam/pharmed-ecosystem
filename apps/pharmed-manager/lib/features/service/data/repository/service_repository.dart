import '../../../../core/core.dart';
import '../../domain/entity/service.dart';
import '../../domain/repository/i_service_repository.dart';
import '../datasource/service_data_source.dart';

class ServiceRepository implements IServiceRepository {
  final ServiceDataSource _ds;

  ServiceRepository(this._ds);

  @override
  Future<Result<ApiResponse<List<HospitalService>>>> getServices({
    int? skip,
    int? take,
    String? search,
  }) async {
    final r = await _ds.getServices(
      skip: skip,
      take: take,
      search: search,
    );
    return r.when(
      ok: (response) {
        List<HospitalService> entities = [];
        if (response.data != null) {
          entities = response.data!.map((e) => e.toEntity()).toList();
        }
        return Result.ok(ApiResponse<List<HospitalService>>(
          data: entities,
          statusCode: response.statusCode,
          isSuccess: response.isSuccess,
          totalCount: response.totalCount,
          groupCount: response.groupCount,
        ));
      },
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<void>> createService(HospitalService entity) async {
    final dto = entity.toDTO();
    final r = await _ds.createService(dto);

    return r.when(
      ok: (_) {
        return Result.ok(null);
      },
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<void>> updateService(HospitalService entity) async {
    if (entity.id == null) {
      return Result.error(CustomException(message: 'updateCabinTemperature: id is null'));
    }

    final dto = entity.toDTO();
    final res = await _ds.updateService(dto);

    return res.when(
      ok: (_) {
        return Result.ok(null);
      },
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<void>> deleteService(HospitalService service) async {
    final id = service.id;
    if (id == null) return Result.error(CustomException(message: 'deleteService: id is null'));

    final r = await _ds.deleteService(id);
    return r.when(
      ok: (_) => Result.ok(null),
      error: Result.error,
    );
  }
}
