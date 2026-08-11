import 'package:pharmed_core/pharmed_core.dart';

class GetReturnDrawerMedicinesUseCase {
  const GetReturnDrawerMedicinesUseCase(this._repository);

  final IUnloadRepository _repository;

  Future<Result<List<ReturnDrawerMedicine>?>> call() => _repository.getReturnDrawerMedicines();
}
