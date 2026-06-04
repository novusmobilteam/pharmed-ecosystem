import 'package:pharmed_core/pharmed_core.dart';

class GetUnreadQrcodesUsecase {
  final IDashboardRepository _repository;

  GetUnreadQrcodesUsecase(this._repository);

  Future<Result<List<PrescriptionItem>>> call() {
    return _repository.getUnreadQrCodes();
  }
}
