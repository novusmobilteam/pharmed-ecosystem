import 'package:pharmed_core/pharmed_core.dart';

class GetDashboardCabinsUseCase {
  final IDashboardRepository _repository;

  GetDashboardCabinsUseCase(this._repository);

  Future<Result<List<Cabin>>> call() {
    return _repository.getCabins();
  }
}
