import 'package:pharmed_core/pharmed_core.dart';

sealed class InventoryState {
  const InventoryState();
}

final class InventoryLoading extends InventoryState {
  const InventoryLoading();
}

class InventoryLoaded extends InventoryState {
  const InventoryLoaded({required this.items, this.isLoading = false});

  final List<MedicineAssignment> items;
  final bool isLoading;

  InventoryLoaded copyWith({List<MedicineAssignment>? items, bool? isLoading}) =>
      InventoryLoaded(items: items ?? this.items, isLoading: isLoading ?? this.isLoading);
}

final class InventoryError extends InventoryState {
  final String message;

  const InventoryError({required this.message});
}
