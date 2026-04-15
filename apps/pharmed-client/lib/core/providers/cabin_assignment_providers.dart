import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/core/flavor/app_flavor.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

import 'providers.dart';

final cabinAssignmentRemoteDataSourceProvider = Provider<CabinAssignmentRemoteDataSource>((ref) {
  return CabinAssignmentRemoteDataSource(apiManager: ref.read(apiManagerProvider));
});

final cabinAssignmentRepositoryProvider = Provider<ICabinAssignmentRepository>((ref) {
  return switch (FlavorConfig.instance.flavor) {
    AppFlavor.mock => CabinAssignmentRepository(
      dataSource: ref.read(cabinAssignmentRemoteDataSourceProvider),
      mapper: CabinAssignmentMapper(),
    ),
    AppFlavor.dev || AppFlavor.prod => CabinAssignmentRepository(
      dataSource: ref.read(cabinAssignmentRemoteDataSourceProvider),
      mapper: CabinAssignmentMapper(),
    ),
  };
});

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
