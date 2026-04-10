// [SWREQ-CORE-SERVICE-UC-006]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class DeleteBedUseCase {
  const DeleteBedUseCase(this._repository);

  final IServiceRepository _repository;

  Future<Result<void>> call(int bedId) => _repository.deleteBed(bedId);
}
