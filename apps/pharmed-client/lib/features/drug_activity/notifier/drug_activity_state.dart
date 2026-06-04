import 'package:pharmed_core/pharmed_core.dart';

sealed class DrugActivityState {
  const DrugActivityState();
}

final class DrugActivityLoading extends DrugActivityState {
  const DrugActivityLoading();
}

class DrugActivityLoaded extends DrugActivityState {
  const DrugActivityLoaded({required this.items, this.isLoading = false});

  final List<PrescriptionItemMovement> items;
  final bool isLoading;

  DrugActivityLoaded copyWith({List<PrescriptionItemMovement>? items, bool? isLoading}) =>
      DrugActivityLoaded(items: items ?? this.items, isLoading: isLoading ?? this.isLoading);
}

final class DrugActivityError extends DrugActivityState {
  final String message;
  const DrugActivityError({required this.message});
}
