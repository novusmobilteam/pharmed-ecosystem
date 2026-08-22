import 'package:pharmed_core/pharmed_core.dart';

sealed class PrescriptionState {
  const PrescriptionState();
}

final class PrescriptionUninitialized extends PrescriptionState {
  const PrescriptionUninitialized();
}

final class PrescriptionLoading extends PrescriptionState {
  const PrescriptionLoading();
}

final class PrescriptionIdle extends PrescriptionState {
  const PrescriptionIdle({required this.hospitalizations, this.search = ''});

  final List<Hospitalization> hospitalizations;
  final String search;
}

final class PrescriptionPatientSelected extends PrescriptionState {
  const PrescriptionPatientSelected({
    required this.hospitalizations,
    required this.selectedPatient,
    required this.prescriptionItems,
    this.search = '',
    this.isPrescriptionsLoading = false,
  });

  final List<Hospitalization> hospitalizations;
  final Hospitalization selectedPatient;

  /// Tüm statusler — filtrelenmemiş.
  final List<PrescriptionItem> prescriptionItems;

  final String search;
  final bool isPrescriptionsLoading;

  static const _sentinel = Object();

  PrescriptionPatientSelected copyWith({
    List<PrescriptionItem>? prescriptionItems,
    String? search,
    Object? isPrescriptionsLoading = _sentinel,
  }) {
    return PrescriptionPatientSelected(
      hospitalizations: hospitalizations,
      selectedPatient: selectedPatient,
      prescriptionItems: prescriptionItems ?? this.prescriptionItems,
      search: search ?? this.search,
      isPrescriptionsLoading: isPrescriptionsLoading == _sentinel
          ? this.isPrescriptionsLoading
          : isPrescriptionsLoading as bool,
    );
  }
}

final class PrescriptionError extends PrescriptionState {
  const PrescriptionError({required this.message, required this.previousState});

  final String message;
  final PrescriptionState previousState;
}

// ─────────────────────────────────────────────────────────────────────────────
// Extension
// ─────────────────────────────────────────────────────────────────────────────

extension PrescriptionStateX on PrescriptionState {
  List<Hospitalization> get hospitalizations => switch (this) {
    PrescriptionIdle(:final hospitalizations) => hospitalizations,
    PrescriptionPatientSelected(:final hospitalizations) => hospitalizations,
    PrescriptionError(:final previousState) => previousState.hospitalizations,
    _ => const [],
  };

  String get search => switch (this) {
    PrescriptionIdle(:final search) => search,
    PrescriptionPatientSelected(:final search) => search,
    PrescriptionError(:final previousState) => previousState.search,
    _ => '',
  };

  Hospitalization? get selectedPatient => switch (this) {
    PrescriptionPatientSelected(:final selectedPatient) => selectedPatient,
    PrescriptionError(:final previousState) => previousState.selectedPatient,
    _ => null,
  };

  List<PrescriptionItem> get prescriptionItems => switch (this) {
    PrescriptionPatientSelected(:final prescriptionItems) => prescriptionItems,
    PrescriptionError(:final previousState) => previousState.prescriptionItems,
    _ => const [],
  };

  bool get isPrescriptionsLoading => switch (this) {
    PrescriptionPatientSelected(:final isPrescriptionsLoading) => isPrescriptionsLoading,
    _ => false,
  };

  bool get isPatientSelected => switch (this) {
    PrescriptionPatientSelected() => true,
    PrescriptionError(:final previousState) => previousState.isPatientSelected,
    _ => false,
  };
}
