import 'package:pharmed_core/pharmed_core.dart';

class GetTransactionStepsUseCase {
  final IReportRepository _repository;

  GetTransactionStepsUseCase(this._repository);

  Future<Result<List<StationTransactionStep>>> call(int transactionId) async {
    return await _repository.getTransactionSteps(transactionId);
  }
}
