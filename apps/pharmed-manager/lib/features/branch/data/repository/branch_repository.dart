import '../../../../core/core.dart';
import '../../domain/entity/branch.dart';
import '../../domain/repository/i_branch_repository.dart';
import '../datasource/branch_datasource.dart';

class BranchRepository implements IBranchRepository {
  final BranchDataSource _ds;

  BranchRepository(this._ds);

  @override
  Future<Result<ApiResponse<List<Branch>>>> getBranches({
    int? skip,
    int? take,
    String? search,
  }) async {
    final res = await _ds.getBranches(
      skip: skip,
      take: take,
      search: search,
    );
    return res.when(
      ok: (response) {
        List<Branch> entities = [];
        if (response.data != null) {
          entities = response.data!.map((e) => e.toEntity()).toList();
        }

        return Result.ok(ApiResponse<List<Branch>>(
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
  Future<Result<void>> createBranch(Branch entity) async {
    final dto = entity.toDTO();
    final res = await _ds.createBranch(dto);

    return res.when(
      ok: (_) {
        return Result.ok(null);
      },
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<void>> updateBranch(Branch entity) async {
    final dto = entity.toDTO();
    final res = await _ds.updateBranch(dto);

    return res.when(
      ok: (_) {
        return Result.ok(null);
      },
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<void>> deleteBranch(int id) async {
    final res = await _ds.deleteBranch(id);
    return res.when(
      ok: (_) {
        return Result.ok(null);
      },
      error: (e) => Result.error(e),
    );
  }
}
