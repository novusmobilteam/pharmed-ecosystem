import '../../../../core/core.dart';
import '../model/inconsistency_dto.dart';
import 'inconsistency_datasource.dart';

/// Tutarsızlık işlemleri için uzak (API) veri kaynağı.
class InconsistencyRemoteDataSource extends BaseRemoteDataSource implements InconsistencyDataSource {
  final String _basePath;

  InconsistencyRemoteDataSource({
    required super.apiManager,
    String basePath = '/CabinDrawrStock/allInconsistency',
  }) : _basePath = basePath;

  @override
  Future<Result<ApiResponse<List<InconsistencyDTO>>>> getInconsistencies({
    int? skip,
    int? take,
    String? search,
  }) async {
    final res = await fetchRequest<ApiResponse<List<InconsistencyDTO>>>(
      path: _basePath,
      skip: skip,
      take: take,
      searchText: search,
      searchField: 'drugName', // Tahmini search field, kontrol edilmeli
      envelope: ResponseEnvelope.raw,
      parser: apiResponseListParser(InconsistencyDTO.fromJson),
      successLog: 'Inconsistencies fetched',
      emptyLog: 'No inconsistencies',
    );

    return res.when(
      ok: (data) => Result.ok(data ?? const ApiResponse(data: [], totalCount: 0)),
      error: Result.error,
    );
  }

  // @override
  // Future<Result<InconsistencyDetailDTO?>> getInconsistencyDetail(int id) async {
  //   final res = await fetchRequest<InconsistencyDetailDTO>(
  //     path: '$_basePath/detail/$id',
  //     parser: singleParser(InconsistencyDetailDTO.fromJson),
  //     successLog: 'Inconsistency detail fetched',
  //     emptyLog: 'No detail',
  //   );

  //   return res.when(
  //     ok: (data) => Result.ok(data),
  //     error: Result.error,
  //   );
  // }
}
