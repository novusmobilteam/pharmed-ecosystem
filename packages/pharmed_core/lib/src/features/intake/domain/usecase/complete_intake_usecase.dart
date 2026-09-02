import 'package:pharmed_core/pharmed_core.dart';

class CompleteIntakeUseCase {
  final IIntakeRepository _repository;

  CompleteIntakeUseCase(this._repository);

  Future<Result<void>> call(IntakeParams params) async {
    final type = params.type;

    switch (type) {
      case IntakeType.ordered:
        return await _completeOrdered(params);
      case IntakeType.orderless:
        return await _completeOrderless(params);
      case IntakeType.free:
        return await _completeFree(params);
      case IntakeType.urgent:
        return await _completeUrgent(params);
    }
  }

  Future<Result<void>> _completeOrdered(IntakeParams params) {
    return _repository.completeOrderedIntake(params.toJson());
  }

  Future<Result<void>> _completeOrderless(IntakeParams params) {
    return _repository.completeOrderlessIntake(params.toJson());
  }

  Future<Result<void>> _completeFree(IntakeParams params) async {
    return _repository.completeFreeIntake(params.toJson());
  }

  Future<Result<void>> _completeUrgent(IntakeParams params) async {
    return _repository.completeUrgentIntake(params.toJson());
  }
}
