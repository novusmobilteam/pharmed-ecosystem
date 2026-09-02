import 'package:pharmed_core/pharmed_core.dart';

class GetRedirectedOrdersUseCase {
  const GetRedirectedOrdersUseCase(this._repository);

  final IIntakeRepository _repository;

  Future<Result<List<RedirectedOrder>>> call() => _repository.getRedirectedOrders();
}
