// [SWREQ-CORE-SERVICE-UC-008]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class GetRoomsUseCase {
  const GetRoomsUseCase(this._repository);

  final IServiceRepository _repository;
  // Fiziksel servis id
  Future<Result<List<Room>?>> call(int serviceId) => _repository.getRooms(serviceId);
}
