import '../../../../core/core.dart';
import '../model/directed_order_dto.dart';

/// Yönlendirilmiş Sipariş (Directed Order) işlemleri için veri kaynağı arayüzü.
///
/// Bu arayüz, yönlendirilmiş siparişlerin listelenmesi işlemlerini tanımlar.
abstract class DirectedOrderDataSource {
  /// Yönlendirilmiş siparişleri sayfalı bir şekilde listeler.
  ///
  /// [skip]: Atlanacak kayıt sayısı (Pagination).
  /// [take]: Alınacak kayıt sayısı (Pagination).
  /// [search]: Arama metni.
  Future<Result<ApiResponse<List<DirectedOrderDTO>>>> getDirectedOrders({
    int? skip,
    int? take,
    String? search,
  });
}
