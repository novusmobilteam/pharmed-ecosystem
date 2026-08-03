// [SWREQ-UI-JobList-STATE-001]
// Sınıf : Class A

import 'package:pharmed_core/pharmed_core.dart';

sealed class JobListState {
  const JobListState();
}

final class JobListUninitialized extends JobListState {
  const JobListUninitialized();
}

final class JobListLoading extends JobListState {
  const JobListLoading({required this.cabinId});
  final int cabinId;
}

final class JobListIdle extends JobListState {
  const JobListIdle({
    required this.cabinId,
    required this.allPatients,
    required this.selectedHospitalization,
    required this.jobList,
    this.search = '',
    this.isJobListLoading = false,
  });

  final int cabinId;

  /// Sol liste — GetMyPatients'tan türetilen hastalar.
  final List<Hospitalization> allPatients;

  /// Sol listede o an seçili hasta (null = henüz/otomatik seçim yapılmadı).
  final Hospitalization? selectedHospitalization;

  /// Sağ liste — seçili hastanın iş listesi.
  final List<PrescriptionItem> jobList;

  final String search;

  /// Hasta değişince sağ panelde ayrı bir spinner göstermek için.
  final bool isJobListLoading;

  int? get selectedHospitalizationId => selectedHospitalization?.id;

  JobListIdle copyWith({
    List<Hospitalization>? allPatients,
    Hospitalization? selectedHospitalization,
    List<PrescriptionItem>? jobList,
    String? search,
    bool? isJobListLoading,
  }) {
    return JobListIdle(
      cabinId: cabinId,
      allPatients: allPatients ?? this.allPatients,
      selectedHospitalization: selectedHospitalization ?? this.selectedHospitalization,
      jobList: jobList ?? this.jobList,
      search: search ?? this.search,
      isJobListLoading: isJobListLoading ?? this.isJobListLoading,
    );
  }
}

final class JobListError extends JobListState {
  const JobListError({required this.message, required this.previousState});

  final String message;
  final JobListState previousState;
}

extension JobListStateX on JobListState {
  int? get cabinId => switch (this) {
    JobListLoading(:final cabinId) => cabinId,
    JobListIdle(:final cabinId) => cabinId,
    JobListError(:final previousState) => previousState.cabinId,
    _ => null,
  };

  List<Hospitalization> get allPatients => switch (this) {
    JobListIdle(:final allPatients) => allPatients,
    JobListError(:final previousState) => previousState.allPatients,
    _ => const [],
  };

  Hospitalization? get selectedHospitalization => switch (this) {
    JobListIdle(:final selectedHospitalization) => selectedHospitalization,
    JobListError(:final previousState) => previousState.selectedHospitalization,
    _ => null,
  };

  List<PrescriptionItem> get jobList => switch (this) {
    JobListIdle(:final jobList) => jobList,
    JobListError(:final previousState) => previousState.jobList,
    _ => const [],
  };

  String get search => switch (this) {
    JobListIdle(:final search) => search,
    JobListError(:final previousState) => previousState.search,
    _ => '',
  };

  bool get isJobListLoading => switch (this) {
    JobListIdle(:final isJobListLoading) => isJobListLoading,
    _ => false,
  };
}
