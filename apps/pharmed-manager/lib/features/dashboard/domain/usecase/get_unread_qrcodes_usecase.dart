import '../../../../core/core.dart';

import '../../../prescription/domain/entity/prescription_item.dart';
import '../repository/i_dashboard_repository.dart';

class GetUnreadQrcodesUsecase implements NoParamsUseCase<List<PrescriptionItem>> {
  final IDashboardRepository _repository;

  GetUnreadQrcodesUsecase(this._repository);

  @override
  Future<Result<List<PrescriptionItem>>> call() {
    return _repository.getUnreadQrCodes();
  }
}
