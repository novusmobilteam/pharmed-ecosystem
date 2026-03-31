import 'package:pharmed_core/pharmed_core.dart';

class GetPharmacyRefundsUseCase {
  final IRefundRepository _repository;

  GetPharmacyRefundsUseCase(this._repository);

  Future<Result<List<Refund>>> call() async {
    return _repository.getPharmacyRefunds();
  }
}
