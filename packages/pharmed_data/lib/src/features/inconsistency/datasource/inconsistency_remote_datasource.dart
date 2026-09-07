// [SWREQ-DATA-INCONSISTENCY-001]
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class InconsistencyRemoteDataSource extends BaseRemoteDataSource {
  InconsistencyRemoteDataSource({required super.apiManager});

  static const String _base = '/CabinDrawrStock/allInconsistency';

  @override
  String get logSwreq => 'SWREQ-DATA-INCONSISTENCY-001';

  @override
  String get logUnit => 'SW-UNIT-INCONSISTENCY';

  Future<Result<ApiResponse<List<InconsistencyDTO>>>> getInconsistencies(
    int stationId, {
    PagedQueryParams? params,
  }) async {
    final res = await fetchRequest<ApiResponse<List<InconsistencyDTO>>>(
      path: _base,
      skip: params?.skip,
      take: params?.take,
      searchQuery: params?.searchQuery,
      searchFields: ['drugName'],
      query: {'stationId': stationId},
      envelope: ResponseEnvelope.raw,
      parser: BaseRemoteDataSource.apiResponseListParser(InconsistencyDTO.fromJson),
      successLog: 'Inconsistencies fetched',
      emptyLog: 'No inconsistencies',
    );

    return res.when(
      ok: (data) => Result.ok(data ?? const ApiResponse(data: [], totalCount: 0)),
      error: Result.error,
    );
  }

  Future<Result<void>> solveInconsistency(int inconsistencyId, {required String description}) async {
    return await putRequest(
      path: '/CabinDrawrStock/inconsistencySolve',
      parser: BaseRemoteDataSource.voidParser(),
      body: {'inconsistencyId': inconsistencyId, 'description': description},
    );
  }
}
