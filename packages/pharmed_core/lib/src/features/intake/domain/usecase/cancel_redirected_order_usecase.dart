import 'package:pharmed_core/pharmed_core.dart';

class CancelRedirectedOrderUseCase {
  const CancelRedirectedOrderUseCase(this._repository);

  final IIntakeRepository _repository;

  Future<Result<void>> call(int redirectedOrderId) => _repository.cancelRedirectedOrder(redirectedOrderId);
}
