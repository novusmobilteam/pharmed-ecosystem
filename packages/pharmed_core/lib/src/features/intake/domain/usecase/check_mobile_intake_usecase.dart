import 'package:pharmed_core/pharmed_core.dart';

class CheckMobileIntakeUseCase {
  final IIntakeRepository _repository;

  CheckMobileIntakeUseCase(this._repository);

  Future<Result<void>> call(List<MobileIntakeParams> params) {
    final data = params.map((p) => p.toJson()).toList();
    return _repository.checkMobileIntake(data);
  }
}
