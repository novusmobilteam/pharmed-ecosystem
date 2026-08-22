// [SWREQ-UI-UNAPP-STATE-001]
// Sınıf : Class A
//
// PrescriptionState ile aynı yapı — fark:
//   - prescriptionItems yalnızca PrescriptionItemStatus.pendingPickup kalemlerini içerir
//   - Filtre notifier katmanında uygulanır, view saf kalır

import 'package:pharmed_core/pharmed_core.dart';

sealed class UnappliedPrescriptionState {
  const UnappliedPrescriptionState();
}

final class UnappliedPrescriptionUninitialized extends UnappliedPrescriptionState {
  const UnappliedPrescriptionUninitialized();
}

final class UnappliedPrescriptionLoading extends UnappliedPrescriptionState {
  const UnappliedPrescriptionLoading();
}

final class UnappliedPrescriptionIdle extends UnappliedPrescriptionState {
  const UnappliedPrescriptionIdle({required this.hospitalizations, this.search = ''});

  final List<Hospitalization> hospitalizations;
  final String search;
}

final class UnappliedPrescriptionPatientSelected extends UnappliedPrescriptionState {
  const UnappliedPrescriptionPatientSelected({
    required this.hospitalizations,
    required this.selectedPatient,
    required this.prescriptionItems,
    this.search = '',
    this.isPrescriptionsLoading = false,
  });

  final List<Hospitalization> hospitalizations;
  final Hospitalization selectedPatient;

  /// Yalnızca [PrescriptionItemStatus.pendingPickup] durumundaki kalemler.
  final List<PrescriptionItem> prescriptionItems;

  final String search;
  final bool isPrescriptionsLoading;

  static const _sentinel = Object();

  UnappliedPrescriptionPatientSelected copyWith({
    List<PrescriptionItem>? prescriptionItems,
    String? search,
    Object? isPrescriptionsLoading = _sentinel,
  }) {
    return UnappliedPrescriptionPatientSelected(
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

final class UnappliedPrescriptionError extends UnappliedPrescriptionState {
  const UnappliedPrescriptionError({required this.message, required this.previousState});

  final String message;
  final UnappliedPrescriptionState previousState;
}

extension UnappliedPrescriptionStateX on UnappliedPrescriptionState {
  List<Hospitalization> get hospitalizations => switch (this) {
    UnappliedPrescriptionIdle(:final hospitalizations) => hospitalizations,
    UnappliedPrescriptionPatientSelected(:final hospitalizations) => hospitalizations,
    UnappliedPrescriptionError(:final previousState) => previousState.hospitalizations,
    _ => const [],
  };

  String get search => switch (this) {
    UnappliedPrescriptionIdle(:final search) => search,
    UnappliedPrescriptionPatientSelected(:final search) => search,
    UnappliedPrescriptionError(:final previousState) => previousState.search,
    _ => '',
  };

  Hospitalization? get selectedPatient => switch (this) {
    UnappliedPrescriptionPatientSelected(:final selectedPatient) => selectedPatient,
    UnappliedPrescriptionError(:final previousState) => previousState.selectedPatient,
    _ => null,
  };

  List<PrescriptionItem> get prescriptionItems => switch (this) {
    UnappliedPrescriptionPatientSelected(:final prescriptionItems) => prescriptionItems,
    UnappliedPrescriptionError(:final previousState) => previousState.prescriptionItems,
    _ => const [],
  };

  bool get isPrescriptionsLoading => switch (this) {
    UnappliedPrescriptionPatientSelected(:final isPrescriptionsLoading) => isPrescriptionsLoading,
    _ => false,
  };

  bool get isPatientSelected => switch (this) {
    UnappliedPrescriptionPatientSelected() => true,
    UnappliedPrescriptionError(:final previousState) => previousState.isPatientSelected,
    _ => false,
  };
}
