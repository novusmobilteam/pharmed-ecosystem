import '../../../../core/core.dart';
import '../model/directed_order_dto.dart';
import 'directed_order_datasource.dart';

/// Yönlendirilmiş Sipariş işlemleri için uzak (API) veri kaynağı.
class DirectedOrderRemoteDataSource extends BaseRemoteDataSource implements DirectedOrderDataSource {
  DirectedOrderRemoteDataSource({required super.apiManager});

  final String _basePath = '/DirectedOrder';

  @override
  // TODO: implement logSwreq
  String get logSwreq => throw UnimplementedError();

  @override
  // TODO: implement logUnit
  String get logUnit => throw UnimplementedError();

  @override
  Future<Result<ApiResponse<List<DirectedOrderDTO>>>> getDirectedOrders({int? skip, int? take, String? search}) async {
    final res = await fetchRequest<ApiResponse<List<DirectedOrderDTO>>>(
      path: _basePath,
      skip: skip,
      take: take,
      searchText: search,
      searchFields: ['name'],
      envelope: ResponseEnvelope.raw,
      parser: BaseRemoteDataSource.apiResponseListParser(DirectedOrderDTO.fromJson),
      successLog: 'Directed orders fetched successfully',
      emptyLog: 'No directed orders found',
    );

    return res.when(
      ok: (data) => Result.ok(data ?? const ApiResponse(data: [], totalCount: 0)),
      error: Result.error,
    );
  }
}
