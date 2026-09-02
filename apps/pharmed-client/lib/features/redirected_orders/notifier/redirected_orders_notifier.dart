import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/core/mixins/api_request_mixin.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../../core/providers/providers.dart';

final redirectedOrdersNotifierProvider = ChangeNotifierProvider<RedirectedOrdersNotifier>((ref) {
  return RedirectedOrdersNotifier(
    getOrders: ref.read(getRedirectedOrdersUseCaseProvider),
    cancelOrder: ref.read(cancelRedirectedOrderUseCaseProvider),
  );
});

class RedirectedOrdersNotifier extends ChangeNotifier with ApiRequestMixin {
  RedirectedOrdersNotifier({
    required GetRedirectedOrdersUseCase getOrders,
    required CancelRedirectedOrderUseCase cancelOrder,
  }) : _getOrders = getOrders,
       _cancelOrder = cancelOrder {
    fetchOrders();
  }

  final GetRedirectedOrdersUseCase _getOrders;
  final CancelRedirectedOrderUseCase _cancelOrder;

  final OperationKey _getOrdersKey = const OperationKey.custom('fetch-orders');
  final OperationKey _cancelOrderKey = const OperationKey.custom('cancel-order');

  List<RedirectedOrder> _orders = [];
  List<RedirectedOrder> get orders => _orders;

  bool get isFetchingOrders => isLoading(_getOrdersKey);
  bool get isCancellingOrder => isLoading(_cancelOrderKey);

  String get cancelOrderMessage => message(_cancelOrderKey) ?? '';

  Future<void> fetchOrders() async {
    await execute(
      _getOrdersKey,
      operation: () => _getOrders(),
      onData: (data) {
        _orders = data;
        notifyListeners();
      },
    );
  }

  Future<void> cancelOrder(int orderId, {Function()? onSuccess, Function(String message)? onError}) async {
    await executeVoid(
      _cancelOrderKey,
      operation: () => _cancelOrder(orderId),
      onSuccess: () {
        fetchOrders();
        onSuccess?.call();
      },
      onFailed: (exception) => onError?.call(exception.message),
    );
  }
}
