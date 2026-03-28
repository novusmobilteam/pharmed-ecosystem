import '../../../../core/core.dart';

import '../../user.dart';

class BulkUpdateValidDateParams {
  final DateTime date;
  final List<int> ids;
  BulkUpdateValidDateParams({required this.date, required this.ids});
}

class BulkUpdateValidDateUseCase implements UseCase<void, BulkUpdateValidDateParams> {
  final IUserRepository _repository;
  BulkUpdateValidDateUseCase(this._repository);

  @override
  Future<Result<void>> call(BulkUpdateValidDateParams params) {
    return _repository.bulkUpdateValidDate(params.date, params.ids);
  }
}
