import 'package:pharmed_core/pharmed_core.dart';

class GetAllRoomsUseCase {
  const GetAllRoomsUseCase(this._repository);

  final IServiceRepository _repository;

  Future<Result<List<Room>?>> call() => _repository.getAllRooms();
}
