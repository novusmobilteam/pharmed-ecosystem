import '../../../../core/core.dart';

import '../entity/hospitalization.dart';
import '../repository/i_hospitalization_repository.dart';

class GetHospitalizationsParams {
  final int? skip;
  final int? take;
  final String? search;

  GetHospitalizationsParams({this.skip, this.take, this.search});
}

class GetHospitalizationsUseCase implements UseCase<ApiResponse<List<Hospitalization>>, GetHospitalizationsParams> {
  final IHospitalizationRepository _repository;

  GetHospitalizationsUseCase(this._repository);

  @override
  Future<Result<ApiResponse<List<Hospitalization>>>> call(GetHospitalizationsParams params) async {
    return _repository.getHospitalizations(skip: params.skip, take: params.take, search: params.search);
  }
}
