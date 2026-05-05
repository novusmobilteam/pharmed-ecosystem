// [SWREQ-CABIN-UC-XXX]
// Mobil kabin gözündeki yatak atamasını günceller.
// Sınıf: Class B

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../core/providers/providers.dart';

final updateBedAssignmentUseCaseProvider = Provider<UpdateBedAssignmentUseCase>((ref) {
  return UpdateBedAssignmentUseCase(ref.read(cabinAssignmentRepositoryProvider));
});

class UpdateBedAssignmentUseCase {
  const UpdateBedAssignmentUseCase(this._repository);

  final IAssignmentRepository _repository;

  Future<Result<void>> call(BedAssignment entity) async {
    MedLogger.info(
      unit: 'SW-UNIT-CABIN',
      swreq: 'SWREQ-CABIN-UC-XXX',
      message: 'Mobil kabin göz ataması güncellendi',
      context: {'cellId': entity.cellId, 'bedId': entity.bedId},
    );

    return _repository.updateBedAssignment(entity);
  }
}
