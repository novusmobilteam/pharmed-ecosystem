import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

import '../data/repository/directed_order_repository_impl.dart';
import '../domain/entity/directed_order.dart';

class DirectedOrdersDetailViewModel extends ChangeNotifier with ApiRequestMixin {
  final DirectedOrderRepository _orderRepository;
  // BuildContext'e erişimi olmayan bu ViewModel yerine, oluşturulduğu view
  // katmanından (l10n ile) çözülen mesajlar için enjekte edilir.
  final AppLocalizations _l10n;

  DirectedOrdersDetailViewModel({required DirectedOrderRepository orderRepository, required AppLocalizations l10n})
    : _orderRepository = orderRepository,
      _l10n = l10n;

  // Operation Keys
  static const fetch = OperationKey.fetch();

  // Getters
  bool get isFetching => isLoading(fetch);

  List<DirectedOrder> _items = [];
  List<DirectedOrder> get items => _items;

  // Functions
  Future<void> fetchOrders() async {
    await execute(
      fetch,
      operation: () => _orderRepository.getDirectedOrders(),
      onData: (response) => _items = response.data ?? [],
      loadingMessage: _l10n.directedOrders_patientsLoadingMessage,
    );
  }
}
