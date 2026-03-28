import '../../../../core/core.dart';

import '../entity/role_drug_authentication.dart';
import '../repository/i_role_authentication_repository.dart';

class SaveRoleDrugAuthenticationUseCase extends UseCase<void, List<RoleDrugAuthentication>> {
  final IRoleAuthenticationRepository _repository;

  SaveRoleDrugAuthenticationUseCase(this._repository);

  @override
  Future<Result<void>> call(List<RoleDrugAuthentication> params) {
    return _repository.saveDrugAuthentication(params);
  }
}
