import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class GetPatientsParams {
  final int? skip;
  final int? take;
  final String? search;

  GetPatientsParams({this.skip, this.take, this.search});
}

class GetPatientsUseCase {
  final IPatientRepository _repository;
  GetPatientsUseCase(this._repository);

  Future<Result<ApiResponse<List<Patient>>>> call(GetPatientsParams params) {
    return _repository.getPatients(skip: params.skip, take: params.take, search: params.search);
  }
}
