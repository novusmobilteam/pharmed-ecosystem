import 'package:pharmed_core/pharmed_core.dart';

class GetCabinUseCase {
  final ICabinRepository _repository;

  GetCabinUseCase(this._repository);

  Future<Result<Cabin?>> call(int cabinId) async {
    return _repository.getCabin(cabinId);
  }
}
