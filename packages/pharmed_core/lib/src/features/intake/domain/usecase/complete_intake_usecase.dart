import 'package:pharmed_core/pharmed_core.dart';

class CompleteIntakeUseCase {
  final IIntakeRepository _repository;

  CompleteIntakeUseCase(this._repository);

  Future<Result<void>> call(IntakeParams params) async {
    final type = params.type;

    switch (type) {
      case WithdrawType.ordered:
        return await _completeOrdered(params);
      case WithdrawType.orderless:
      case WithdrawType.urgent:
        return await _completeOrderless(params);
      case WithdrawType.free:
        return await _completeFree(params);
    }
  }

  Future<Result<void>> _completeOrdered(IntakeParams params) {
    return _repository.checkOrderedIntake(params.toJson());
  }

  Future<Result<void>> _completeOrderless(IntakeParams params) {
    return _repository.checkOrderlessIntake(params.toJson());
  }

  Future<Result<void>> _completeFree(IntakeParams params) async {
    return _repository.completeFreeIntake(params.toJson());
  }
}
