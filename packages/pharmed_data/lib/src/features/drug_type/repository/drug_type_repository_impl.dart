import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

// [SWREQ-DATA-DRUGTYPE-002]
// IDrugTypeRepository implementasyonu.
// DTO → entity dönüşümü DrugTypeMapper üzerinden yapılır.
// Sınıf: Class B
class DrugTypeRepositoryImpl implements IDrugTypeRepository {
  const DrugTypeRepositoryImpl({required DrugTypeRemoteDataSource dataSource, required DrugTypeMapper mapper})
    : _dataSource = dataSource,
      _mapper = mapper;

  final DrugTypeRemoteDataSource _dataSource;
  final DrugTypeMapper _mapper;

  @override
  Future<Result<ApiResponse<List<DrugType>>>> getDrugTypes({int? skip, int? take, String? search}) async {
    final result = await _dataSource.getDrugTypes(skip: skip, take: take, search: search);
    return result.when(
      ok: (apiResponse) => Result.ok(
        ApiResponse<List<DrugType>>(
          data: apiResponse?.data != null ? _mapper.toEntityList(apiResponse!.data!) : null,
          isSuccess: apiResponse?.isSuccess ?? true,
          totalCount: apiResponse?.totalCount,
        ),
      ),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<void>> createDrugType(DrugType entity) async {
    final result = await _dataSource.createDrugType(_mapper.toDto(entity));
    return result.when(ok: (_) => const Result.ok(null), error: (e) => Result.error(e));
  }

  @override
  Future<Result<void>> updateDrugType(DrugType entity) async {
    final result = await _dataSource.updateDrugType(_mapper.toDto(entity));
    return result.when(ok: (_) => const Result.ok(null), error: (e) => Result.error(e));
  }

  @override
  Future<Result<void>> deleteDrugType(DrugType entity) async {
    if (entity.id == null) {
      return Result.error(ValidationException(message: "Silinecek tipin id'si boş olamaz", field: 'id'));
    }
    final result = await _dataSource.deleteDrugType(entity.id!);
    return result.when(ok: (_) => const Result.ok(null), error: (e) => Result.error(e));
  }
}
