import 'withdraw_type.dart';

enum OrderStatus { ordered, orderless }

extension OrderStatusExtension on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.ordered:
        return 'Orderlı';
      case OrderStatus.orderless:
        return 'Ordersız';
    }
  }

  static OrderStatus fromString(String? value) {
    if (value == null) {
      return OrderStatus.ordered;
    } else {
      switch (value.toLowerCase()) {
        case 'orderlı':
          return OrderStatus.ordered;
        case 'ordersız':
          return OrderStatus.orderless;
        default:
          throw Exception('Invalid status string');
      }
    }
  }

  bool get isActive {
    return this == OrderStatus.ordered;
  }

  bool get isOrderless {
    return this == OrderStatus.orderless;
  }

  bool get isOrdered {
    return this == OrderStatus.ordered;
  }

  WithdrawType get withdrawType {
    switch (this) {
      case OrderStatus.ordered:
        return WithdrawType.ordered;
      case OrderStatus.orderless:
        return WithdrawType.orderless;
    }
  }
}

OrderStatus orderStatusFromBool(bool value) {
  return value ? OrderStatus.ordered : OrderStatus.orderless;
}
