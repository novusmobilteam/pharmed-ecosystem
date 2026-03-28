import '../../../../core/core.dart';
import '../../domain/entity/directed_order.dart';
import '../datasource/directed_order_datasource.dart';
import 'directed_order_repository.dart';

class DirectedOrderRepository implements IDirectedOrderRepository {
  final DirectedOrderDataSource _ds;

  DirectedOrderRepository._(this._ds);

  /// Production: remote data source
  factory DirectedOrderRepository.prod({required DirectedOrderDataSource remote}) => DirectedOrderRepository._(remote);

  /// Development: local data source
  factory DirectedOrderRepository.dev({required DirectedOrderDataSource local}) => DirectedOrderRepository._(local);

  @override
  Future<Result<ApiResponse<List<DirectedOrder>>>> getDirectedOrders({
    int? skip,
    int? take,
    String? search,
  }) async {
    final res = await _ds.getDirectedOrders(
      skip: skip,
      take: take,
      search: search,
    );
    return res.when(
      ok: (response) {
        List<DirectedOrder> entities = [];
        if (response.data != null) {
          entities = response.data!.map((d) => d.toEntity()).toList();
        }
        return Result.ok(ApiResponse<List<DirectedOrder>>(
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
}
