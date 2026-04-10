// [SWREQ-CORE-SERVICE-UC-005]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class DeleteRoomUseCase {
  const DeleteRoomUseCase(this._repository);

  final IServiceRepository _repository;

  Future<Result<void>> call(int roomId) => _repository.deleteRoom(roomId);
}
