import 'package:pharmed_core/pharmed_core.dart';

class CompleteMobileIntakeUseCase {
  final IIntakeRepository _repository;

  CompleteMobileIntakeUseCase(this._repository);

  Future<Result<void>> call(List<MobileIntakeParams> params) {
    final data = params.map((p) => p.toJson()).toList();
    return _repository.completeMobileIntake(data);
  }
}
