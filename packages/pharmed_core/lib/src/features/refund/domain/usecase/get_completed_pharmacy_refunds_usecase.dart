import 'package:pharmed_core/pharmed_core.dart';

class GetCompletedPharmacyRefundsUseCase {
  final IRefundRepository _repository;

  GetCompletedPharmacyRefundsUseCase(this._repository);

  Future<Result<List<Refund>>> call() async {
    return _repository.getCompletedPharmacyRefunds();
  }
}
