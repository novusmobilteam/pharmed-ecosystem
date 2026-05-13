import 'package:pharmed_core/pharmed_core.dart';

class MobileWastageUseCase {
  final IWasteRepository _repository;

  MobileWastageUseCase(this._repository);

  Future<Result<void>> call(WasteParams params) async {
    return _repository.mobileWastage(params.toJson());
  }
}
