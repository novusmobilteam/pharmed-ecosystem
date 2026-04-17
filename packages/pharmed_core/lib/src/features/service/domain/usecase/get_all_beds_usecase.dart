import 'package:pharmed_core/pharmed_core.dart';

class GetAllBedsUseCase {
  const GetAllBedsUseCase(this._repository);

  final IServiceRepository _repository;

  Future<Result<List<Bed>?>> call() => _repository.getAllBeds();
}
