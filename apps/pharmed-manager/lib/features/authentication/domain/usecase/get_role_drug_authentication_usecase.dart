import '../../../../core/core.dart';

import '../../../medicine/domain/entity/medicine.dart';
import '../../../medicine/domain/repository/i_medicine_repository.dart';
import '../../../role/domain/entity/role.dart';
import '../entity/role_drug_authentication.dart';
import '../repository/i_role_authentication_repository.dart';

class GetRoleDrugAuthenticationUseCase extends UseCase<List<RoleDrugAuthentication>, Role> {
  final IRoleAuthenticationRepository _authRepository;
  final IMedicineRepository _medicineRepository;

  GetRoleDrugAuthenticationUseCase({
    required IRoleAuthenticationRepository authRepository,
    required IMedicineRepository medicineRepository,
  }) : _authRepository = authRepository,
       _medicineRepository = medicineRepository;

  @override
  Future<Result<List<RoleDrugAuthentication>>> call(Role role) async {
    List<Medicine> medicines = [];
    List<RoleDrugAuthentication> roleAuth = [];

    final results = await Future.wait([_medicineRepository.getMedicines(), _authRepository.getDrugAuthentications()]);

    final medicineRes = results[0] as Result<ApiResponse<List<Medicine>>>;
    final authRes = results[1] as Result<List<RoleDrugAuthentication>>;

    if (medicineRes case Error(error: final e)) return Result.error(e);
    if (authRes case Error(error: final e)) return Result.error(e);

    if (medicineRes case Ok(value: final drugResponse)) {
      medicines = drugResponse.data ?? [];
    }

    if (authRes case Ok(value: final auth)) {
      roleAuth = auth;
    }

    final result = _initializeOrUpdateAuths(role, roleAuth, medicines);

    return Result.ok(result);
  }

  List<RoleDrugAuthentication> _initializeOrUpdateAuths(
    Role role,
    List<RoleDrugAuthentication> existingAuths,
    List<Medicine> medicines,
  ) {
    final result = <RoleDrugAuthentication>[];
    final existingAuthsByDrugId = {
      for (final auth in existingAuths.where((a) => a.medicine?.id != null && a.role?.id == role.id))
        auth.medicine!.id!: auth,
    };

    for (final medicine in medicines) {
      if (medicine.id != null) {
        final existingAuth = existingAuthsByDrugId[medicine.id!];

        if (existingAuth != null) {
          final updatedAuth = existingAuth.copyWith(medicine: medicine);

          result.add(updatedAuth);
        } else {
          result.add(
            RoleDrugAuthentication(
              role: Role(id: role.id, name: ''),
              medicine: medicine,
              originalOps: {},
              pendingOps: {},
            ),
          );
        }
      }
    }

    return result;
  }
}
