import 'package:pharmed_core/pharmed_core.dart';

class GetRefundsUseCase {
  final IDashboardRepository _repository;

  GetRefundsUseCase(this._repository);

  Future<Result<List<Refund>>> call() {
    return _repository.getRefunds();
  }
}
