import 'package:pharmed_core/pharmed_core.dart';

sealed class ExpiringItemsState {
  const ExpiringItemsState();
}

final class ExpiringItemsLoading extends ExpiringItemsState {
  const ExpiringItemsLoading();
}

class ExpiringItemsLoaded extends ExpiringItemsState {
  const ExpiringItemsLoaded({required this.items, this.isLoading = false});

  final List<CabinStock> items;
  final bool isLoading;

  ExpiringItemsLoaded copyWith({List<CabinStock>? items, bool? isLoading}) =>
      ExpiringItemsLoaded(items: items ?? this.items, isLoading: isLoading ?? this.isLoading);
}

final class ExpiringItemsError extends ExpiringItemsState {
  final String message;
  const ExpiringItemsError({required this.message});
}
