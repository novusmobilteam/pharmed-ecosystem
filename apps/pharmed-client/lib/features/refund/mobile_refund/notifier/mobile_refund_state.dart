// SWREQ-REFUND-01
// ignore_for_file: lines_longer_than_80_chars

import 'package:pharmed_core/pharmed_core.dart';

/// Mobil iade ekranının UI state'i.
///
/// Akış:
///   Uninitialized → Loading → Idle
///                             Idle → PatientSelected (hasta seçildi)
///                             PatientSelected → DrugSelected (ilaç seçildi)
///                             DrugSelected ⇄ Checking
///                             DrugSelected ⇄ Saving
///                                          ↘ Success
///                                          ↘ Error(previousState)
sealed class MobileRefundState {
  const MobileRefundState();
}

/// Notifier henüz init edilmedi.
final class MobileRefundUninitialized extends MobileRefundState {
  const MobileRefundUninitialized();
}

/// Hasta listesi yükleniyor.
final class MobileRefundLoading extends MobileRefundState {
  const MobileRefundLoading();
}

/// Hasta listesi yüklendi, seçim bekleniyor.
final class MobileRefundIdle extends MobileRefundState {
  const MobileRefundIdle({required this.patients, this.search = ''});

  final List<Hospitalization> patients;
  final String search;

  MobileRefundIdle copyWith({String? search}) {
    return MobileRefundIdle(patients: patients, search: search ?? this.search);
  }
}

/// Hasta seçildi, o hastanın iade edilebilir ilaçları yükleniyor.
final class MobileRefundPatientLoading extends MobileRefundState {
  const MobileRefundPatientLoading({required this.patients, required this.selectedPatient, this.search = ''});

  final List<Hospitalization> patients;
  final Hospitalization selectedPatient;
  final String search;
}

/// Hasta seçildi, iade edilebilir ilaç listesi hazır.
final class MobileRefundPatientSelected extends MobileRefundState {
  const MobileRefundPatientSelected({
    required this.patients,
    required this.selectedPatient,
    required this.refundables,
    this.search = '',
  });

  final List<Hospitalization> patients;
  final Hospitalization selectedPatient;
  final List<PrescriptionItem> refundables;
  final String search;

  MobileRefundPatientSelected copyWith({String? search}) {
    return MobileRefundPatientSelected(
      patients: patients,
      selectedPatient: selectedPatient,
      refundables: refundables,
      search: search ?? this.search,
    );
  }
}

/// İlaç seçildi, miktar girilebilir.
final class MobileRefundDrugSelected extends MobileRefundState {
  const MobileRefundDrugSelected({
    required this.patients,
    required this.selectedPatient,
    required this.refundables,
    required this.selectedItem,
    required this.quantity,
    this.search = '',
  });

  final List<Hospitalization> patients;
  final Hospitalization selectedPatient;
  final List<PrescriptionItem> refundables;
  final PrescriptionItem selectedItem;
  final double quantity;
  final String search;

  static const _sentinel = Object();

  MobileRefundDrugSelected copyWith({Object? quantity = _sentinel}) {
    return MobileRefundDrugSelected(
      patients: patients,
      selectedPatient: selectedPatient,
      refundables: refundables,
      selectedItem: selectedItem,
      quantity: quantity == _sentinel ? this.quantity : quantity as double,
      search: search,
    );
  }
}

/// Kontrol servisi çalışıyor (CheckMobileRefundStatusUseCase).
final class MobileRefundChecking extends MobileRefundState {
  const MobileRefundChecking({
    required this.patients,
    required this.selectedPatient,
    required this.refundables,
    required this.selectedItem,
    required this.quantity,
    this.search = '',
  });

  final List<Hospitalization> patients;
  final Hospitalization selectedPatient;
  final List<PrescriptionItem> refundables;
  final PrescriptionItem selectedItem;
  final double quantity;
  final String search;
}

/// İade servisi çalışıyor (CompleteMobileRefundUseCase).
final class MobileRefundSaving extends MobileRefundState {
  const MobileRefundSaving({
    required this.patients,
    required this.selectedPatient,
    required this.refundables,
    required this.selectedItem,
    required this.quantity,
    this.search = '',
  });

  final List<Hospitalization> patients;
  final Hospitalization selectedPatient;
  final List<PrescriptionItem> refundables;
  final PrescriptionItem selectedItem;
  final double quantity;
  final String search;
}

/// İade tamamlandı — liste yenilenir, ardından dismiss edilir.
final class MobileRefundSuccess extends MobileRefundState {
  const MobileRefundSuccess({
    required this.patients,
    required this.selectedPatient,
    required this.refundables,
    required this.message,
    this.search = '',
  });

  final List<Hospitalization> patients;
  final Hospitalization selectedPatient;
  final List<PrescriptionItem> refundables;
  final String message;
  final String search;
}

/// Hata — previousState ile geriye dönülür.
final class MobileRefundError extends MobileRefundState {
  const MobileRefundError({required this.message, required this.previousState});

  final String message;
  final MobileRefundState previousState;
}

extension MobileRefundStateX on MobileRefundState {
  List<Hospitalization> get patients => switch (this) {
    MobileRefundIdle(:final patients) => patients,
    MobileRefundPatientLoading(:final patients) => patients,
    MobileRefundPatientSelected(:final patients) => patients,
    MobileRefundDrugSelected(:final patients) => patients,
    MobileRefundChecking(:final patients) => patients,
    MobileRefundSaving(:final patients) => patients,
    MobileRefundSuccess(:final patients) => patients,
    MobileRefundError(:final previousState) => previousState.patients,
    _ => const [],
  };

  String get search => switch (this) {
    MobileRefundIdle(:final search) => search,
    MobileRefundPatientLoading(:final search) => search,
    MobileRefundPatientSelected(:final search) => search,
    MobileRefundDrugSelected(:final search) => search,
    MobileRefundChecking(:final search) => search,
    MobileRefundSaving(:final search) => search,
    MobileRefundSuccess(:final search) => search,
    MobileRefundError(:final previousState) => previousState.search,
    _ => '',
  };

  /// Arama filtresi uygulanmış hasta listesi.
  List<Hospitalization> get filteredPatients {
    final q = search.trim().toLowerCase();
    if (q.isEmpty) return patients;
    return patients.where((h) {
      final name = h.patient?.fullName.toLowerCase() ?? '';
      final room = h.room?.name?.toLowerCase() ?? '';
      return name.contains(q) || room.contains(q);
    }).toList();
  }

  Hospitalization? get selectedPatient => switch (this) {
    MobileRefundPatientLoading(:final selectedPatient) => selectedPatient,
    MobileRefundPatientSelected(:final selectedPatient) => selectedPatient,
    MobileRefundDrugSelected(:final selectedPatient) => selectedPatient,
    MobileRefundChecking(:final selectedPatient) => selectedPatient,
    MobileRefundSaving(:final selectedPatient) => selectedPatient,
    MobileRefundSuccess(:final selectedPatient) => selectedPatient,
    MobileRefundError(:final previousState) => previousState.selectedPatient,
    _ => null,
  };

  List<PrescriptionItem> get refundables => switch (this) {
    MobileRefundPatientSelected(:final refundables) => refundables,
    MobileRefundDrugSelected(:final refundables) => refundables,
    MobileRefundChecking(:final refundables) => refundables,
    MobileRefundSaving(:final refundables) => refundables,
    MobileRefundSuccess(:final refundables) => refundables,
    MobileRefundError(:final previousState) => previousState.refundables,
    _ => const [],
  };

  PrescriptionItem? get selectedItem => switch (this) {
    MobileRefundDrugSelected(:final selectedItem) => selectedItem,
    MobileRefundChecking(:final selectedItem) => selectedItem,
    MobileRefundSaving(:final selectedItem) => selectedItem,
    MobileRefundError(:final previousState) => previousState.selectedItem,
    _ => null,
  };

  double? get quantity => switch (this) {
    MobileRefundDrugSelected(:final quantity) => quantity,
    MobileRefundChecking(:final quantity) => quantity,
    MobileRefundSaving(:final quantity) => quantity,
    MobileRefundError(:final previousState) => previousState.quantity,
    _ => null,
  };

  bool get isPatientLoading => this is MobileRefundPatientLoading;

  bool get isChecking => this is MobileRefundChecking;

  bool get isSaving => this is MobileRefundSaving;

  bool get isBusy => isChecking || isSaving;

  bool get canRefund => switch (this) {
    MobileRefundDrugSelected(:final selectedItem, :final quantity) =>
      quantity > 0 && (selectedItem.status?.canReturn ?? false),
    _ => false,
  };
}
