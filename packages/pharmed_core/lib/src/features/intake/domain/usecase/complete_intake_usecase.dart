import 'package:pharmed_core/pharmed_core.dart';

class CompleteIntakeUseCase {
  final IIntakeRepository _repository;

  CompleteIntakeUseCase(this._repository);

  Future<Result<int?>> call(IntakeParams params) async {
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

  Future<Result<int?>> _completeOrdered(IntakeParams params) {
    return _repository.completeOrderedIntake(params.toJson());
  }

  Future<Result<int?>> _completeOrderless(IntakeParams params) {
    return _repository.completeOrderlessIntake(params.toJson());
  }

  Future<Result<int?>> _completeFree(IntakeParams params) async {
    return _repository.completeFreeIntake(params.toJson());
  }

  Future<Result<int?>> _completeUrgent(IntakeParams params) async {
    return _repository.completeUrgentIntake(params.toJson());
  }
}
