import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

import '../data/repository/directed_order_repository_impl.dart';
import '../domain/entity/directed_order.dart';

class DirectedOrdersDetailViewModel extends ChangeNotifier with SearchMixin<DirectedOrder>, ApiRequestMixin {
  final DirectedOrderRepository _orderRepository;

  DirectedOrdersDetailViewModel({required DirectedOrderRepository orderRepository})
    : _orderRepository = orderRepository;

  // Operation Keys
  static const fetch = OperationKey.fetch();

  // Getters
  bool get isFetching => isLoading(fetch);

  // Functions
  Future<void> fetchOrders() async {
    await execute(
      fetch,
      operation: () => _orderRepository.getDirectedOrders(),
      onData: (response) => allItems = response.data ?? [],
      loadingMessage: 'Hastalar yükleniyor...',
    );
  }
}
