// [SWREQ-CORE-SERVICE-UC-008]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class GetBedsUseCase {
  const GetBedsUseCase(this._repository);

  final IServiceRepository _repository;

  Future<Result<List<Bed>?>> call(int roomId) => _repository.getBeds(roomId);
}
