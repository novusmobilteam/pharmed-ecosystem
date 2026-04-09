// [SWREQ-DATA-INGREDIENT-002]
// IActiveIngredientRepository implementasyonu.
// DTO → entity dönüşümü ActiveIngredientMapper üzerinden yapılır.
// Sınıf: Class B
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class ActiveIngredientRepositoryImpl implements IActiveIngredientRepository {
  ActiveIngredientRepositoryImpl({
    required ActiveIngredientRemoteDataSource dataSource,
    required ActiveIngredientMapper mapper,
  }) : _dataSource = dataSource,
       _mapper = mapper;

  final ActiveIngredientRemoteDataSource _dataSource;
  final ActiveIngredientMapper _mapper;

  @override
  Future<Result<ApiResponse<List<ActiveIngredient>>>> getActiveIngredients({
    int? skip,
    int? take,
    String? search,
  }) async {
    final result = await _dataSource.getActiveIngredients(skip: skip, take: take, search: search);
    return result.when(
      ok: (apiResponse) => Result.ok(
        ApiResponse<List<ActiveIngredient>>(
          data: apiResponse?.data != null ? _mapper.toEntityList(apiResponse!.data!) : null,
          isSuccess: apiResponse?.isSuccess ?? true,
          totalCount: apiResponse?.totalCount,
        ),
      ),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<void>> createActiveIngredient(ActiveIngredient entity) async {
    final result = await _dataSource.createActiveIngredient(_mapper.toDto(entity));
    return result.when(ok: (_) => const Result.ok(null), error: (e) => Result.error(e));
  }

  @override
  Future<Result<void>> updateActiveIngredient(ActiveIngredient entity) async {
    final result = await _dataSource.updateActiveIngredient(_mapper.toDto(entity));
    return result.when(ok: (_) => const Result.ok(null), error: (e) => Result.error(e));
  }

  @override
  Future<Result<void>> deleteActiveIngredient(ActiveIngredient entity) async {
    if (entity.id == null) {
      return Result.error(ValidationException(message: "Silinecek rolün id'si boş olamaz", field: 'id'));
    }
    final result = await _dataSource.deleteActiveIngredient(entity.id!);
    return result.when(ok: (_) => const Result.ok(null), error: (e) => Result.error(e));
  }
}
