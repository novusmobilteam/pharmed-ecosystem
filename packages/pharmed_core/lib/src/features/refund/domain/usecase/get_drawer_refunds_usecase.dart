import 'package:pharmed_core/pharmed_core.dart';

class GetDrawerRefundsUseCase {
  final IRefundRepository _repository;

  GetDrawerRefundsUseCase(this._repository);

  Future<Result<List<Refund>>> call() async {
    return _repository.getDrawerRefunds();
  }
}
