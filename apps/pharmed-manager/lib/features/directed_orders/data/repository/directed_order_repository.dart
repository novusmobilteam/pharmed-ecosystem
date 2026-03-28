import '../../../../core/core.dart';
import '../../domain/entity/directed_order.dart';

abstract class IDirectedOrderRepository {
  Future<Result<ApiResponse<List<DirectedOrder>>>> getDirectedOrders({
    int? skip,
    int? take,
    String? search,
  });
}
