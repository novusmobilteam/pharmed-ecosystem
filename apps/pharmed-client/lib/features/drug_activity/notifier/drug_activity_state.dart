import 'package:pharmed_core/pharmed_core.dart';

sealed class DrugActivityState {
  const DrugActivityState();
}

final class DrugActivityLoading extends DrugActivityState {
  const DrugActivityLoading();
}

final class DrugActivityLoaded extends DrugActivityState {
  final List<PrescriptionItemMovement> items;
  const DrugActivityLoaded({required this.items});
}

final class DrugActivityError extends DrugActivityState {
  final String message;
  const DrugActivityError({required this.message});
}
