import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

// [SWREQ-DATA-WAREHOUSE-002]
// IWarehouseRepository implementasyonu.
// DTO → entity dönüşümü ServiceMapper üzerinden yapılır.
// Sınıf: Class B
class WarehouseRepositoryImpl implements IWarehouseRepository {
  const WarehouseRepositoryImpl({required WarehouseRemoteDataSource dataSource, required WarehouseMapper mapper})
    : _dataSource = dataSource,
      _mapper = mapper;

  final WarehouseRemoteDataSource _dataSource;
  final WarehouseMapper _mapper;

  @override
  Future<Result<ApiResponse<List<Warehouse>>>> getWarehouses({int? skip, int? take, String? search}) async {
    final result = await _dataSource.getWarehouses(skip: skip, take: take, search: search);
    return result.when(
      ok: (apiResponse) => Result.ok(
        ApiResponse<List<Warehouse>>(
          data: apiResponse?.data != null ? _mapper.toEntityList(apiResponse!.data!) : null,
          isSuccess: apiResponse?.isSuccess ?? true,
          totalCount: apiResponse?.totalCount,
        ),
      ),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<void>> createWarehouse(Warehouse entity) async {
    final result = await _dataSource.createWarehouse(_mapper.toDto(entity));
    return result.when(ok: (_) => const Result.ok(null), error: (e) => Result.error(e));
  }

  @override
  Future<Result<void>> updateWarehouse(Warehouse entity) async {
    final result = await _dataSource.updateWarehouse(_mapper.toDto(entity));
    return result.when(ok: (_) => const Result.ok(null), error: (e) => Result.error(e));
  }

  @override
  Future<Result<void>> deleteWarehouse(Warehouse entity) async {
    if (entity.id == null) {
      return Result.error(ValidationException(message: "Silinecek deponun id'si boş olamaz", field: 'id'));
    }
    final result = await _dataSource.deleteWarehouse(entity.id!);
    return result.when(ok: (_) => const Result.ok(null), error: (e) => Result.error(e));
  }
}
