import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/src/features/branch/branch.dart';
import 'package:pharmed_data/src/models/api_response/api_response.dart';

// [SWREQ-DATA-BRANCH-002]
// IBranchRepository implementasyonu.
// DTO → entity dönüşümü BranchMapper üzerinden yapılır.
// Sınıf: Class B
class BranchRepositoryImpl implements IBranchRepository {
  const BranchRepositoryImpl({required BranchRemoteDataSource dataSource, required BranchMapper mapper})
    : _dataSource = dataSource,
      _mapper = mapper;

  final BranchRemoteDataSource _dataSource;
  final BranchMapper _mapper;

  @override
  Future<Result<ApiResponse<List<Branch>>>> getBranches({int? skip, int? take, String? search}) async {
    final result = await _dataSource.getBranches(skip: skip, take: take, search: search);
    return result.when(
      ok: (apiResponse) => Result.ok(
        ApiResponse<List<Branch>>(
          data: apiResponse?.data != null ? _mapper.toEntityList(apiResponse!.data!) : null,
          isSuccess: apiResponse?.isSuccess ?? true,
          totalCount: apiResponse?.totalCount,
        ),
      ),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<void>> createBranch(Branch entity) async {
    final result = await _dataSource.createBranch(_mapper.toDto(entity));
    return result.when(ok: (_) => const Result.ok(null), error: (e) => Result.error(e));
  }

  @override
  Future<Result<void>> updateBranch(Branch entity) async {
    final result = await _dataSource.updateBranch(_mapper.toDto(entity));
    return result.when(ok: (_) => const Result.ok(null), error: (e) => Result.error(e));
  }

  @override
  Future<Result<void>> deleteBranch(Branch entity) async {
    if (entity.id == null) {
      return Result.error(ValidationException(message: "Silinecek rolün id'si boş olamaz", field: 'id'));
    }
    final result = await _dataSource.deleteBranch(entity.id!);
    return result.when(ok: (_) => const Result.ok(null), error: (e) => Result.error(e));
  }
}
