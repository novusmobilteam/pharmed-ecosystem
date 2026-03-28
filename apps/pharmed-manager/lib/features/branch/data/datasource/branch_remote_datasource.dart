import '../../../../../core/core.dart';
import '../model/branch_dto.dart';
import 'branch_datasource.dart';

/// Branş işlemleri için uzak (API) veri kaynağı.
class BranchRemoteDataSource extends BaseRemoteDataSource implements BranchDataSource {
  final String _basePath = '/Branch';

  BranchRemoteDataSource({required super.apiManager});

  @override
  Future<Result<ApiResponse<List<BranchDTO>>>> getBranches({
    int? skip,
    int? take,
    String? search,
  }) async {
    final res = await fetchRequest<ApiResponse<List<BranchDTO>>>(
      path: _basePath,
      skip: skip,
      take: take,
      searchText: search,
      searchField: 'name',
      envelope: ResponseEnvelope.raw,
      parser: apiResponseListParser(BranchDTO.fromJson),
      successLog: 'Branches fetched successfully',
      emptyLog: 'No branches found',
    );

    return res.when(
      ok: (data) => Result.ok(data ?? const ApiResponse(data: [], totalCount: 0)),
      error: Result.error,
    );
  }

  @override
  Future<Result<BranchDTO?>> createBranch(BranchDTO dto) {
    return createRequest<BranchDTO>(
      path: _basePath,
      body: dto.toJson(),
      parser: singleParser(BranchDTO.fromJson),
      successLog: 'Branch created successfully',
    );
  }

  @override
  Future<Result<BranchDTO?>> updateBranch(BranchDTO dto) {
    return updateRequest<BranchDTO>(
      path: '$_basePath/${dto.id}',
      body: dto.toJson(),
      parser: singleParser(BranchDTO.fromJson),
      successLog: 'Branch updated successfully',
    );
  }

  @override
  Future<Result<void>> deleteBranch(int id) {
    return deleteRequest<void>(
      path: '$_basePath/$id',
      parser: voidParser(),
      successLog: 'Branch deleted successfully',
    );
  }
}
