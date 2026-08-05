import 'package:pharmed_core/pharmed_core.dart';

class RedirectIntakeParams {
  const RedirectIntakeParams({required this.prescriptionDetailId, required this.stationId, required this.materialId});

  final int prescriptionDetailId;
  final int stationId;
  final int materialId;

  Map<String, dynamic> toJson() => {
    'prescriptionDetailId': prescriptionDetailId,
    'stationId': stationId,
    'materialId': materialId,
  };
}

class RedirectIntakeUseCase {
  const RedirectIntakeUseCase(this._repository);
  final IIntakeRepository _repository;

  Future<Result<void>> call(RedirectIntakeParams params) => _repository.redirectIntake(params.toJson());
}

class GetRedirectedIntakeOrdersUseCase {
  const GetRedirectedIntakeOrdersUseCase(this._repository);

  final IIntakeRepository _repository;

  Future<Result<List<RedirectedIntakeOrder>>> call(int hospitalizationId) async {
    return await _repository.getRedirectedIntakeOrders(hospitalizationId);
  }
}

class CheckRedirectedIntakeUseCase {
  const CheckRedirectedIntakeUseCase(this._repository);

  final IIntakeRepository _repository;

  Future<Result<void>> call(int referralId) => _repository.checkRedirectedIntake(referralId);
}

class CompleteRedirectedIntakeUseCase {
  const CompleteRedirectedIntakeUseCase(this._repository);

  final IIntakeRepository _repository;

  Future<Result<void>> call({required int referralId, double? censusQuantity}) =>
      _repository.completeRedirectedIntake(referralId: referralId, censusQuantity: censusQuantity);
}
