import 'package:pharmed_core/pharmed_core.dart';

class SaveRoleDrugAuthorizationUseCase {
  final IRoleAuthorizationRepository _repository;

  SaveRoleDrugAuthorizationUseCase(this._repository);

  Future<Result<void>> call(List<RoleDrugAuthorization> params) {
    return _repository.saveDrugAuthorizations(params);
  }
}
