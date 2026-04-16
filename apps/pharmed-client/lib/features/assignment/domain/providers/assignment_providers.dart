import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/core/flavor/app_flavor.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

import '../../../../core/providers/providers.dart';
import '../../assignment.dart';

final cabinAssignmentRemoteDataSourceProvider = Provider<AssignmentRemoteDataSource>((ref) {
  return AssignmentRemoteDataSource(apiManager: ref.read(apiManagerProvider));
});

final cabinAssignmentRepositoryProvider = Provider<IAssignmentRepository>((ref) {
  return switch (FlavorConfig.instance.flavor) {
    AppFlavor.mock => AssignmentRepository(
      dataSource: ref.read(cabinAssignmentRemoteDataSourceProvider),
      medicineAssignmentMapper: MedicineAssignmentMapper(),
      patientAssignmentMapper: PatientAssignmentMapper(),
    ),
    AppFlavor.dev || AppFlavor.prod => AssignmentRepository(
      dataSource: ref.read(cabinAssignmentRemoteDataSourceProvider),
      medicineAssignmentMapper: MedicineAssignmentMapper(),
      patientAssignmentMapper: PatientAssignmentMapper(),
    ),
  };
});

/// Medicine
final getAssignmentsUseCaseProvider = Provider<GetMedicineAssignmentsUseCase>((ref) {
  return GetMedicineAssignmentsUseCase(ref.read(cabinAssignmentRepositoryProvider));
});

final createAssignmentUseCaseProvider = Provider<CreateMedicineAssignmentUseCase>((ref) {
  return CreateMedicineAssignmentUseCase(ref.read(cabinAssignmentRepositoryProvider));
});

final updateAssignmentUseCaseProvider = Provider<UpdateMedicineAssignmentUseCase>((ref) {
  return UpdateMedicineAssignmentUseCase(ref.read(cabinAssignmentRepositoryProvider));
});

final deleteAssignmentUseCaseProvider = Provider<DeleteMedicineAssignmentUseCase>((ref) {
  return DeleteMedicineAssignmentUseCase(ref.read(cabinAssignmentRepositoryProvider));
});

/// Patient - Bed
final createPatientAssignmentUseCaseProvider = Provider<CreatePatientAssignmentUseCase>((ref) {
  return CreatePatientAssignmentUseCase(ref.read(cabinAssignmentRepositoryProvider));
});

final getPatientAssignmentsUseCaseProvider = Provider<GetPatientAssignmentsUseCase>((ref) {
  return GetPatientAssignmentsUseCase(ref.read(cabinAssignmentRepositoryProvider));
});
