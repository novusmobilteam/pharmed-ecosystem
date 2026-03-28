import '../../../../core/core.dart';

import '../entity/withdraw_params.dart';
import '../repository/i_medicine_withdraw_repository.dart';

class CompleteWithdrawUseCase implements UseCase<void, WithdrawParams> {
  final IMedicineWithdrawRepository _repository;

  CompleteWithdrawUseCase(this._repository);

  @override
  Future<Result<void>> call(WithdrawParams params) async {
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

  Future<Result<void>> _completeOrdered(WithdrawParams params) {
    return _repository.completeOrderedWithdraw(params.toJson());
  }

  Future<Result<void>> _completeOrderless(WithdrawParams params) {
    return _repository.completeOrderlessWithdraw(params.toJson());
  }

  Future<Result<void>> _completeFree(WithdrawParams params) async {
    return _repository.completeFreeWithdraw(params.toJson());
  }
}
