import 'package:pharmed_core/pharmed_core.dart';

sealed class UnscannedBarcodesState {
  const UnscannedBarcodesState();
}

final class UnscannedBarcodesLoading extends UnscannedBarcodesState {
  const UnscannedBarcodesLoading();
}

class UnscannedBarcodesLoaded extends UnscannedBarcodesState {
  const UnscannedBarcodesLoaded({required this.items, this.isLoading = false});

  final List<PrescriptionItem> items;
  final bool isLoading;

  UnscannedBarcodesLoaded copyWith({List<PrescriptionItem>? items, bool? isLoading}) =>
      UnscannedBarcodesLoaded(items: items ?? this.items, isLoading: isLoading ?? this.isLoading);
}

final class UnscannedBarcodesError extends UnscannedBarcodesState {
  final String message;

  const UnscannedBarcodesError({required this.message});
}
