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

  Future<Result<ApiResponse<List<InconsistencyDTO>>>> getInconsistencies({int? skip, int? take, String? search}) async {
    final res = await fetchRequest<ApiResponse<List<InconsistencyDTO>>>(
      path: _base,
      skip: skip,
      take: take,
      searchText: search,
      searchFields: ['drugName'],
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
