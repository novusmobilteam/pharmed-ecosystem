import 'package:pharmed_core/pharmed_core.dart';

class GetMobileDisposablesUseCase {
  final IWasteRepository _repository;

  GetMobileDisposablesUseCase(this._repository);

  Future<Result<List<PrescriptionItem>>> call(int hospitalizationId) {
    return _repository.getMobileDisposables(hospitalizationId: hospitalizationId);
  }
}
