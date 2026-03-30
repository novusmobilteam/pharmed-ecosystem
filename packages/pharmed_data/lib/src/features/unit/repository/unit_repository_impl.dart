import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

// [SWREQ-DATA-UNIT-002]
// IUnitRepository implementasyonu.
// DTO → entity dönüşümü UnitMapper üzerinden yapılır.
// Sınıf: Class B
class UnitRepositoryImpl implements IUnitRepository {
  UnitRepositoryImpl({required UnitRemoteDataSource dataSource, required UnitMapper mapper})
    : _dataSource = dataSource,
      _mapper = mapper;

  final UnitRemoteDataSource _dataSource;
  final UnitMapper _mapper;

  @override
  Future<Result<ApiResponse<List<Unit>>>> getUnits({int? skip, int? take, String? search}) async {
    final result = await _dataSource.getUnits(skip: skip, take: take, search: search);
    return result.when(
      ok: (apiResponse) => Result.ok(
        ApiResponse<List<Unit>>(
          data: apiResponse?.data != null ? _mapper.toEntityList(apiResponse!.data!) : null,
          isSuccess: apiResponse?.isSuccess ?? true,
          totalCount: apiResponse?.totalCount,
        ),
      ),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<void>> createUnit(Unit entity) async {
    final result = await _dataSource.createUnit(_mapper.toDto(entity));
    return result.when(ok: (_) => const Result.ok(null), error: (e) => Result.error(e));
  }

  @override
  Future<Result<void>> updateUnit(Unit entity) async {
    final result = await _dataSource.updateUnit(_mapper.toDto(entity));
    return result.when(ok: (_) => const Result.ok(null), error: (e) => Result.error(e));
  }

  @override
  Future<Result<void>> deleteUnit(Unit entity) async {
    if (entity.id == null) {
      return Result.error(ValidationException(message: "Silinecek birimin id'si boş olamaz", field: 'id'));
    }
    final result = await _dataSource.deleteUnit(entity.id!);
    return result.when(ok: (_) => const Result.ok(null), error: (e) => Result.error(e));
  }
}
