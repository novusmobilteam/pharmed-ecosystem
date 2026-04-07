import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'providers.dart';

/// ----- Dashboard -----

// GetCriticalStocksUseCase
final getCriticalStocksUseCaseProvider = Provider<GetCriticalStocksUseCase>((ref) {
  return GetCriticalStocksUseCase(ref.read(dashboardRepositoryProvider));
});

// GetExpiringMaterialsUseCase
final getExpiringMaterialsUseCaseProvider = Provider<GetExpiringMaterialsUseCase>((ref) {
  return GetExpiringMaterialsUseCase(ref.read(dashboardRepositoryProvider));
});

// GetUpcomingTreatmensUseCase
final getUpcomingTreatmensUseCaseProvider = Provider<GetUpcomingTreatmensUseCase>((ref) {
  return GetUpcomingTreatmensUseCase(ref.read(dashboardRepositoryProvider));
});

/// ----- Dashboard -----

// GetStationsUseCase
final getStationsUseCaseProvider = Provider<GetStationsUseCase>((ref) {
  return GetStationsUseCase(ref.read(stationRepositoryProvider));
});

// GetFilteredMenusUseCase
final getFilteredMenusUseCaseProvider = Provider<GetFilteredMenusUseCase>((ref) {
  return GetFilteredMenusUseCase(ref.read(dashboardRepositoryProvider), isManager: true);
});

/// ----- Assignment -----

final getAssignmentsUseCaseProvider = Provider<GetAssignmentsUseCase>((ref) {
  return GetAssignmentsUseCase(ref.read(cabinAssignmentRepositoryProvider));
});

final createAssignmentUseCaseProvider = Provider<CreateAssignmentUseCase>((ref) {
  return CreateAssignmentUseCase(ref.read(cabinAssignmentRepositoryProvider));
});

final updateAssignmentUseCaseProvider = Provider<UpdateAssignmentUseCase>((ref) {
  return UpdateAssignmentUseCase(ref.read(cabinAssignmentRepositoryProvider));
});

final deleteAssignmentUseCaseProvider = Provider<DeleteAssignmentUseCase>((ref) {
  return DeleteAssignmentUseCase(ref.read(cabinAssignmentRepositoryProvider));
});

/// ----- Assignment -----

/// ----- Medicine -----

final getDrugsUseCaseProvider = Provider<GetDrugsUseCase>((ref) {
  return GetDrugsUseCase(ref.read(medicineRepositoryProvider));
});

/// ----- Medicine -----

/// ----- Fault -----
final getCabinFaultsUseCaseProvider = Provider<GetCabinFaultsUseCase>((ref) {
  return GetCabinFaultsUseCase(ref.read(faultRepositoryProvider));
});

final createFaultRecordUseCaseProvider = Provider<CreateFaultRecordUseCase>((ref) {
  return CreateFaultRecordUseCase(ref.read(faultRepositoryProvider));
});

final clearFaultRecordUseCaseProvider = Provider<ClearFaultRecordUseCase>((ref) {
  return ClearFaultRecordUseCase(ref.read(faultRepositoryProvider));
});

/// ----- Fault -----
