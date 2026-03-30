// [SWREQ-CORE-USER-UC-008]
// Sadece pharmed_manager tarafından kullanılır.
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class BulkUpdateValidDateParams {
  const BulkUpdateValidDateParams({required this.date, required this.ids});

  final DateTime date;
  final List<int> ids;
}

class BulkUpdateValidDateUseCase {
  const BulkUpdateValidDateUseCase(this._repository);

  final IUserManager _repository;

  Future<Result<void>> call(BulkUpdateValidDateParams params) =>
      _repository.bulkUpdateValidDate(params.date, params.ids);
}
