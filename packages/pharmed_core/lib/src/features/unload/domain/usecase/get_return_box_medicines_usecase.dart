import 'package:pharmed_core/pharmed_core.dart';

class GetReturnBoxMedicinesUseCase {
  const GetReturnBoxMedicinesUseCase(this._repository);

  final IUnloadRepository _repository;

  Future<Result<List<ReturnDrawerMedicine>?>> call() => _repository.getReturnBoxMedicines();
}
