import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

// [SWREQ-DATA-MATERIALTYPE-002]
// IMaterialTypeRepository implementasyonu.
// DTO → entity dönüşümü BranchMapper üzerinden yapılır.
// Sınıf: Class B
class MaterialTypeRepositoryImpl implements IMaterialTypeRepository {
  const MaterialTypeRepositoryImpl({
    required MaterialTypeRemoteDataSource dataSource,
    required MaterialTypeMapper mapper,
  }) : _dataSource = dataSource,
       _mapper = mapper;

  final MaterialTypeRemoteDataSource _dataSource;
  final MaterialTypeMapper _mapper;

  @override
  Future<Result<ApiResponse<List<MaterialType>>>> getMaterialTypes({int? skip, int? take, String? search}) async {
    final result = await _dataSource.getMaterialTypes(skip: skip, take: take, search: search);
    return result.when(
      ok: (apiResponse) => Result.ok(
        ApiResponse<List<MaterialType>>(
          data: apiResponse?.data != null ? _mapper.toEntityList(apiResponse!.data!) : null,
          isSuccess: apiResponse?.isSuccess ?? true,
          totalCount: apiResponse?.totalCount,
        ),
      ),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<void>> createMaterialType(MaterialType entity) async {
    final result = await _dataSource.createMaterialType(_mapper.toDto(entity));
    return result.when(ok: (_) => const Result.ok(null), error: (e) => Result.error(e));
  }

  @override
  Future<Result<void>> updateMaterialType(MaterialType entity) async {
    final result = await _dataSource.updateMaterialType(_mapper.toDto(entity));
    return result.when(ok: (_) => const Result.ok(null), error: (e) => Result.error(e));
  }

  @override
  Future<Result<void>> deleteMaterialType(MaterialType entity) async {
    if (entity.id == null) {
      return Result.error(ValidationException(message: "Silinecek tipin id'si boş olamaz", field: 'id'));
    }
    final result = await _dataSource.deleteMaterialType(entity.id!);
    return result.when(ok: (_) => const Result.ok(null), error: (e) => Result.error(e));
  }
}
