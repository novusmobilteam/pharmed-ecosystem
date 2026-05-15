// lib/features/my_patients/notifier/my_patients_state.dart
//
// [SWREQ-UI-MYPATIENTS-STATE-001]
// Sınıf : Class A

import 'package:pharmed_core/pharmed_core.dart';

sealed class MyPatientsState {
  const MyPatientsState();
}

/// İlk yüklemeden önce.
final class MyPatientsUninitialized extends MyPatientsState {
  const MyPatientsUninitialized();
}

/// Sol liste (BedAssignments) + sağ liste (MyPatients) yükleniyor.
final class MyPatientsLoading extends MyPatientsState {
  const MyPatientsLoading({required this.cabinId});
  final int cabinId;
}

/// Her iki liste de yüklenmiş, idle.
final class MyPatientsIdle extends MyPatientsState {
  const MyPatientsIdle({
    required this.cabinId,
    required this.allPatients,
    required this.myPatients,
    this.search = '',
    this.pendingIds = const {},
  });

  final int cabinId;

  /// Sol liste — kabindeki tüm yatışlar.
  final List<Hospitalization> allPatients;

  /// Sağ liste — oturumdaki kullanıcının hastaları.
  final List<MyPatient> myPatients;

  final String search;

  /// O an API isteği devam eden hospitalizationId'ler.
  /// Bu set'teki ID'lerin butonu spinner gösterir.
  final Set<int> pendingIds;

  /// Sağ listede olan hospitalizationId'ler —
  /// sol listede soluk/disabled göstermek için kullanılır.
  Set<int> get myPatientHospitalizationIds => myPatients.map((p) => p.hospitalization?.id).whereType<int>().toSet();

  MyPatientsIdle copyWith({
    List<Hospitalization>? allPatients,
    List<MyPatient>? myPatients,
    String? search,
    Set<int>? pendingIds,
  }) {
    return MyPatientsIdle(
      cabinId: cabinId,
      allPatients: allPatients ?? this.allPatients,
      myPatients: myPatients ?? this.myPatients,
      search: search ?? this.search,
      pendingIds: pendingIds ?? this.pendingIds,
    );
  }
}

final class MyPatientsError extends MyPatientsState {
  const MyPatientsError({required this.message, required this.previousState});

  final String message;
  final MyPatientsState previousState;
}

extension MyPatientsStateX on MyPatientsState {
  int? get cabinId => switch (this) {
    MyPatientsLoading(:final cabinId) => cabinId,
    MyPatientsIdle(:final cabinId) => cabinId,
    MyPatientsError(:final previousState) => previousState.cabinId,
    _ => null,
  };

  List<Hospitalization> get allPatients => switch (this) {
    MyPatientsIdle(:final allPatients) => allPatients,
    MyPatientsError(:final previousState) => previousState.allPatients,
    _ => const [],
  };

  List<MyPatient> get myPatients => switch (this) {
    MyPatientsIdle(:final myPatients) => myPatients,
    MyPatientsError(:final previousState) => previousState.myPatients,
    _ => const [],
  };

  String get search => switch (this) {
    MyPatientsIdle(:final search) => search,
    MyPatientsError(:final previousState) => previousState.search,
    _ => '',
  };

  Set<int> get pendingIds => switch (this) {
    MyPatientsIdle(:final pendingIds) => pendingIds,
    _ => const {},
  };

  Set<int> get myPatientHospitalizationIds => switch (this) {
    MyPatientsIdle s => s.myPatientHospitalizationIds,
    MyPatientsError(:final previousState) => previousState.myPatientHospitalizationIds,
    _ => const {},
  };

  bool isPending(int hospitalizationId) => pendingIds.contains(hospitalizationId);
}
