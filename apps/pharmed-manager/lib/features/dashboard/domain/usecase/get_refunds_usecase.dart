import '../../../../core/core.dart';

import '../../../medicine_refund/domain/entity/refund.dart';
import '../repository/i_dashboard_repository.dart';

class GetRefundsUseCase implements NoParamsUseCase<List<Refund>> {
  final IDashboardRepository _repository;

  GetRefundsUseCase(this._repository);

  @override
  Future<Result<List<Refund>>> call() {
    return _repository.getRefunds();
  }
}
