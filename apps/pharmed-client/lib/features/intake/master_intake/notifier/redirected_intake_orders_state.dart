import 'package:pharmed_core/pharmed_core.dart';

sealed class RedirectedIntakeOrdersState {
  const RedirectedIntakeOrdersState();
}

final class RedirectedOrdersNoPatient extends RedirectedIntakeOrdersState {
  const RedirectedOrdersNoPatient();
}

final class RedirectedOrdersLoading extends RedirectedIntakeOrdersState {
  const RedirectedOrdersLoading(this.hospitalization);
  final Hospitalization hospitalization;
}

final class RedirectedOrdersLoaded extends RedirectedIntakeOrdersState {
  const RedirectedOrdersLoaded({
    required this.hospitalization,
    required this.orders,
    this.selectedOrderIds = const {},
    this.checkStates = const {},
  });

  final Hospitalization hospitalization;
  final List<RedirectedIntakeOrder> orders;
  final Set<int> selectedOrderIds;
  final Map<int, IntakeCheckState> checkStates;

  List<RedirectedIntakeOrder> get pendingOrders => orders.where((o) => o.isPending).toList();
  bool get canStart => selectedOrderIds.isNotEmpty;

  RedirectedOrdersLoaded copyWith({
    List<RedirectedIntakeOrder>? orders,
    Set<int>? selectedOrderIds,
    Map<int, IntakeCheckState>? checkStates,
  }) {
    return RedirectedOrdersLoaded(
      hospitalization: hospitalization,
      orders: orders ?? this.orders,
      selectedOrderIds: selectedOrderIds ?? this.selectedOrderIds,
      checkStates: checkStates ?? this.checkStates,
    );
  }
}

final class RedirectedOrdersError extends RedirectedIntakeOrdersState {
  const RedirectedOrdersError(this.hospitalization, this.message);
  final Hospitalization? hospitalization;
  final String? message;
}
