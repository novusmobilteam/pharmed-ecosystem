import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class GetRoleDrugAuthorizationUseCase {
  final IRoleAuthorizationRepository _authRepository;
  final IMedicineRepository _medicineRepository;

  GetRoleDrugAuthorizationUseCase({
    required IRoleAuthorizationRepository authRepository,
    required IMedicineRepository medicineRepository,
  }) : _authRepository = authRepository,
       _medicineRepository = medicineRepository;

  Future<Result<List<RoleDrugAuthorization>>> call(Role role) async {
    List<Medicine> medicines = [];
    List<RoleDrugAuthorization> roleAuth = [];

    final results = await Future.wait([_medicineRepository.getMedicines(), _authRepository.getDrugAuthorizations()]);

    final medicineRes = results[0] as Result<ApiResponse<List<Medicine>>>;
    final authRes = results[1] as Result<List<RoleDrugAuthorization>>;

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

  List<RoleDrugAuthorization> _initializeOrUpdateAuths(
    Role role,
    List<RoleDrugAuthorization> existingAuths,
    List<Medicine> medicines,
  ) {
    final result = <RoleDrugAuthorization>[];
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
            RoleDrugAuthorization(
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
