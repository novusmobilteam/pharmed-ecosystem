import '../../../../core/core.dart';
import '../model/directed_order_dto.dart';
import 'directed_order_datasource.dart';

class _DirectedOrderStore extends BaseLocalDataSource<DirectedOrderDTO, int> {
  _DirectedOrderStore({required super.filePath})
      : super(
          fromJson: (m) => DirectedOrderDTO.fromJson(m),
          toJson: (d) => d.toJson(),
          getId: (d) => d.id ?? -1,
          assignId: (d, id) => d.copyWith(id: id),
        );
}

/// Yönlendirilmiş Sipariş işlemleri için yerel (Mock) veri kaynağı.
class DirectedOrderLocalDataSource implements DirectedOrderDataSource {
  final _DirectedOrderStore _store;

  DirectedOrderLocalDataSource({required String assetPath})
      : _store = _DirectedOrderStore(filePath: assetPath);

  @override
  Future<Result<ApiResponse<List<DirectedOrderDTO>>>> getDirectedOrders({
    int? skip,
    int? take,
    String? search,
  }) {
    return _store.fetchRequest(
      skip: skip,
      take: take,
      searchText: search,
      searchField: 'name',
    );
  }
}
