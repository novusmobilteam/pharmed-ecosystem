// SWREQ-WASTE-01
// ignore_for_file: lines_longer_than_80_chars

import 'package:pharmed_core/pharmed_core.dart';

/// Mobil fire/imha ekranının UI state'i.
///
/// Akış:
///   Uninitialized → Loading → Idle
///                             Idle → PatientSelected (hasta seçildi)
///                             PatientSelected → DrugSelected (ilaç seçildi)
///                             DrugSelected ⇄ Saving (fire veya imha servisi çalışıyor)
///                                          ↘ Success
///                                          ↘ Error(previousState)
sealed class MobileWasteState {
  const MobileWasteState();
}

/// Notifier henüz init edilmedi.
final class MobileWasteUninitialized extends MobileWasteState {
  const MobileWasteUninitialized();
}

/// Hasta listesi yükleniyor.
final class MobileWasteLoading extends MobileWasteState {
  const MobileWasteLoading();
}

/// Hasta listesi yüklendi, seçim bekleniyor.
final class MobileWasteIdle extends MobileWasteState {
  const MobileWasteIdle({required this.patients, this.search = ''});

  final List<Hospitalization> patients;
  final String search;

  MobileWasteIdle copyWith({String? search}) {
    return MobileWasteIdle(patients: patients, search: search ?? this.search);
  }
}

/// Hasta seçildi, o hastanın fire/imha edilebilir ilaçları yükleniyor.
final class MobileWastePatientLoading extends MobileWasteState {
  const MobileWastePatientLoading({required this.patients, required this.selectedPatient, this.search = ''});

  final List<Hospitalization> patients;
  final Hospitalization selectedPatient;
  final String search;
}

/// Hasta seçildi, fire/imha edilebilir ilaç listesi hazır.
final class MobileWastePatientSelected extends MobileWasteState {
  const MobileWastePatientSelected({
    required this.patients,
    required this.selectedPatient,
    required this.disposables,
    this.search = '',
  });

  final List<Hospitalization> patients;
  final Hospitalization selectedPatient;
  final List<PrescriptionItem> disposables;
  final String search;

  MobileWastePatientSelected copyWith({String? search}) {
    return MobileWastePatientSelected(
      patients: patients,
      selectedPatient: selectedPatient,
      disposables: disposables,
      search: search ?? this.search,
    );
  }
}

/// İlaç seçildi, miktar girilebilir.
final class MobileWasteDrugSelected extends MobileWasteState {
  const MobileWasteDrugSelected({
    required this.patients,
    required this.selectedPatient,
    required this.disposables,
    required this.selectedItem,
    required this.quantity,
    this.search = '',
  });

  final List<Hospitalization> patients;
  final Hospitalization selectedPatient;
  final List<PrescriptionItem> disposables;
  final PrescriptionItem selectedItem;
  final double quantity;
  final String search;

  static const _sentinel = Object();

  MobileWasteDrugSelected copyWith({Object? quantity = _sentinel}) {
    return MobileWasteDrugSelected(
      patients: patients,
      selectedPatient: selectedPatient,
      disposables: disposables,
      selectedItem: selectedItem,
      quantity: quantity == _sentinel ? this.quantity : quantity as double,
      search: search,
    );
  }
}

/// Fire veya imha servisi çalışıyor (MobileWastageUseCase / MobileDestructionUseCase).
final class MobileWasteSaving extends MobileWasteState {
  const MobileWasteSaving({
    required this.patients,
    required this.selectedPatient,
    required this.disposables,
    required this.selectedItem,
    required this.quantity,
    this.search = '',
  });

  final List<Hospitalization> patients;
  final Hospitalization selectedPatient;
  final List<PrescriptionItem> disposables;
  final PrescriptionItem selectedItem;
  final double quantity;
  final String search;
}

/// İşlem tamamlandı — liste yenilenir, ardından dismiss edilir.
final class MobileWasteSuccess extends MobileWasteState {
  const MobileWasteSuccess({
    required this.patients,
    required this.selectedPatient,
    required this.disposables,
    required this.message,
    this.search = '',
  });

  final List<Hospitalization> patients;
  final Hospitalization selectedPatient;
  final List<PrescriptionItem> disposables;
  final String message;
  final String search;
}

/// Hata — previousState ile geriye dönülür.
final class MobileWasteError extends MobileWasteState {
  const MobileWasteError({required this.message, required this.previousState});

  final String message;
  final MobileWasteState previousState;
}

extension MobileWasteStateX on MobileWasteState {
  List<Hospitalization> get patients => switch (this) {
    MobileWasteIdle(:final patients) => patients,
    MobileWastePatientLoading(:final patients) => patients,
    MobileWastePatientSelected(:final patients) => patients,
    MobileWasteDrugSelected(:final patients) => patients,
    MobileWasteSaving(:final patients) => patients,
    MobileWasteSuccess(:final patients) => patients,
    MobileWasteError(:final previousState) => previousState.patients,
    _ => const [],
  };

  String get search => switch (this) {
    MobileWasteIdle(:final search) => search,
    MobileWastePatientLoading(:final search) => search,
    MobileWastePatientSelected(:final search) => search,
    MobileWasteDrugSelected(:final search) => search,
    MobileWasteSaving(:final search) => search,
    MobileWasteSuccess(:final search) => search,
    MobileWasteError(:final previousState) => previousState.search,
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
    MobileWastePatientLoading(:final selectedPatient) => selectedPatient,
    MobileWastePatientSelected(:final selectedPatient) => selectedPatient,
    MobileWasteDrugSelected(:final selectedPatient) => selectedPatient,
    MobileWasteSaving(:final selectedPatient) => selectedPatient,
    MobileWasteSuccess(:final selectedPatient) => selectedPatient,
    MobileWasteError(:final previousState) => previousState.selectedPatient,
    _ => null,
  };

  List<PrescriptionItem> get disposables => switch (this) {
    MobileWastePatientSelected(:final disposables) => disposables,
    MobileWasteDrugSelected(:final disposables) => disposables,
    MobileWasteSaving(:final disposables) => disposables,
    MobileWasteSuccess(:final disposables) => disposables,
    MobileWasteError(:final previousState) => previousState.disposables,
    _ => const [],
  };

  PrescriptionItem? get selectedItem => switch (this) {
    MobileWasteDrugSelected(:final selectedItem) => selectedItem,
    MobileWasteSaving(:final selectedItem) => selectedItem,
    MobileWasteError(:final previousState) => previousState.selectedItem,
    _ => null,
  };

  double? get quantity => switch (this) {
    MobileWasteDrugSelected(:final quantity) => quantity,
    MobileWasteSaving(:final quantity) => quantity,
    MobileWasteError(:final previousState) => previousState.quantity,
    _ => null,
  };

  bool get isPatientLoading => this is MobileWastePatientLoading;

  bool get isSaving => this is MobileWasteSaving;

  bool get canWaste => switch (this) {
    MobileWasteDrugSelected(:final quantity) => quantity > 0,
    _ => false,
  };
}
