import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

// [SWREQ-DATA-DRUGCLASS-002]
// IDrugClassRepository implementasyonu.
// DTO → entity dönüşümü DrugClassMapper üzerinden yapılır.
// Sınıf: Class B
class DrugClassRepositoryImpl implements IDrugClassRepository {
  const DrugClassRepositoryImpl({required DrugClassRemoteDataSource dataSource, required DrugClassMapper mapper})
    : _dataSource = dataSource,
      _mapper = mapper;

  final DrugClassRemoteDataSource _dataSource;
  final DrugClassMapper _mapper;

  @override
  Future<Result<ApiResponse<List<DrugClass>>>> getDrugClasses({int? skip, int? take, String? search}) async {
    final result = await _dataSource.getDrugClasses(skip: skip, take: take, search: search);
    return result.when(
      ok: (apiResponse) => Result.ok(
        ApiResponse<List<DrugClass>>(
          data: apiResponse?.data != null ? _mapper.toEntityList(apiResponse!.data!) : null,
          isSuccess: apiResponse?.isSuccess ?? true,
          totalCount: apiResponse?.totalCount,
        ),
      ),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<void>> createDrugClass(DrugClass entity) async {
    final result = await _dataSource.createDrugClass(_mapper.toDto(entity));
    return result.when(ok: (_) => const Result.ok(null), error: (e) => Result.error(e));
  }

  @override
  Future<Result<void>> updateDrugClass(DrugClass entity) async {
    final result = await _dataSource.updateDrugClass(_mapper.toDto(entity));
    return result.when(ok: (_) => const Result.ok(null), error: (e) => Result.error(e));
  }

  @override
  Future<Result<void>> deleteDrugClass(DrugClass entity) async {
    if (entity.id == null) {
      return Result.error(ValidationException(message: "Silinecek sınıfın id'si boş olamaz", field: 'id'));
    }
    final result = await _dataSource.deleteDrugClass(entity.id!);
    return result.when(ok: (_) => const Result.ok(null), error: (e) => Result.error(e));
  }
}
