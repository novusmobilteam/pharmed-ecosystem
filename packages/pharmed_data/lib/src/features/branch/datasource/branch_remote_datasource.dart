import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

// [SWREQ-DATA-BRANCH-001]
// Sınıf: Class B
class BranchRemoteDataSource extends BaseRemoteDataSource {
  BranchRemoteDataSource({required super.apiManager});

  static const _base = '/Branch';

  @override
  String get logSwreq => 'SWREQ-DATA-BRANCH-001';

  @override
  String get logUnit => 'SW-UNIT-BRANCH';

  Future<Result<ApiResponse<List<BranchDTO>>?>> getBranches({int? skip, int? take, String? search}) async {
    return fetchRequest(
      path: _base,
      skip: skip,
      take: take,
      searchText: search,
      searchFields: const ['name'],
      envelope: ResponseEnvelope.raw,
      parser: BaseRemoteDataSource.apiResponseListParser(BranchDTO.fromJson),
      successLog: 'Branşlar getirildi',
      emptyLog: 'Branş bulunamadı',
    );
  }

  Future<Result<void>> createBranch(BranchDTO dto) {
    return createRequest(
      path: _base,
      body: dto.toJson(),
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Branş oluşturuldu',
    );
  }

  Future<Result<void>> updateBranch(BranchDTO dto) {
    return updateRequest(
      path: _base,
      body: dto.toJson(),
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Branş güncellendi',
    );
  }

  Future<Result<void>> deleteBranch(int id) {
    return deleteRequest(path: '$_base/$id', parser: BaseRemoteDataSource.voidParser(), successLog: 'Branş silindi');
  }
}
