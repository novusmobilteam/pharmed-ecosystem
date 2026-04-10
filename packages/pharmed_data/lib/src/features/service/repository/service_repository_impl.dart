import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/src/features/service/service.dart';
import 'package:pharmed_data/src/models/api_response/api_response.dart';

// [SWREQ-DATA-SERVICE-002]
// IServiceRepository implementasyonu.
// DTO → entity dönüşümü ServiceMapper üzerinden yapılır.
// Sınıf: Class B
class ServiceRepositoryImpl implements IServiceRepository {
  const ServiceRepositoryImpl({required ServiceRemoteDataSource dataSource, required ServiceMapper mapper})
    : _dataSource = dataSource,
      _mapper = mapper;

  final ServiceRemoteDataSource _dataSource;
  final ServiceMapper _mapper;

  @override
  Future<Result<ApiResponse<List<HospitalService>>>> getServices({int? skip, int? take, String? search}) async {
    final result = await _dataSource.getServices(skip: skip, take: take, search: search);
    return result.when(
      ok: (apiResponse) => Result.ok(
        ApiResponse<List<HospitalService>>(
          data: apiResponse?.data != null ? _mapper.toEntityList(apiResponse!.data!) : null,
          isSuccess: apiResponse?.isSuccess ?? true,
          totalCount: apiResponse?.totalCount,
        ),
      ),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<HospitalService?>> getService(int serviceId) async {
    final result = await _dataSource.getService(serviceId);
    return result.when(
      ok: (serviceDto) => Result.ok(_mapper.toEntityOrNull(serviceDto)),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<void>> createService(HospitalService entity) async {
    final result = await _dataSource.createService(_mapper.toDto(entity));
    return result.when(ok: (_) => const Result.ok(null), error: (e) => Result.error(e));
  }

  @override
  Future<Result<void>> updateService(HospitalService entity) async {
    final result = await _dataSource.updateService(_mapper.toDto(entity));
    return result.when(ok: (_) => const Result.ok(null), error: (e) => Result.error(e));
  }

  @override
  Future<Result<void>> deleteService(HospitalService entity) async {
    if (entity.id == null) {
      return Result.error(ValidationException(message: "Silinecek servisin id'si boş olamaz", field: 'id'));
    }
    final result = await _dataSource.deleteService(entity.id!);
    return result.when(ok: (_) => const Result.ok(null), error: (e) => Result.error(e));
  }

  @override
  Future<Result<void>> deleteBed(int bedId) async {
    final result = await _dataSource.deleteBed(bedId);
    return result.when(ok: (_) => const Result.ok(null), error: (e) => Result.error(e));
  }

  @override
  Future<Result<void>> deleteRoom(int roomId) async {
    final result = await _dataSource.deleteRoom(roomId);
    return result.when(ok: (_) => const Result.ok(null), error: (e) => Result.error(e));
  }
}
