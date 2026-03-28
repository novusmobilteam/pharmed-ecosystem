import '../../../../core/core.dart';

import '../entity/patient.dart';
import '../repository/i_patient_repository.dart';

class GetPatientsParams {
  final int? skip;
  final int? take;
  final String? search;

  GetPatientsParams({this.skip, this.take, this.search});
}

class GetPatientsUseCase implements UseCase<ApiResponse<List<Patient>>, GetPatientsParams> {
  final IPatientRepository _repository;
  GetPatientsUseCase(this._repository);

  @override
  Future<Result<ApiResponse<List<Patient>>>> call(GetPatientsParams params) {
    return _repository.getPatients(skip: params.skip, take: params.take, search: params.search);
  }
}
