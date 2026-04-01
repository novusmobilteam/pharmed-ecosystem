import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class GetHospitalizationsParams {
  final int? skip;
  final int? take;
  final String? search;

  GetHospitalizationsParams({this.skip, this.take, this.search});
}

class GetHospitalizationsUseCase {
  final IHospitalizationRepository _repository;

  GetHospitalizationsUseCase(this._repository);

  Future<Result<ApiResponse<List<Hospitalization>>>> call(GetHospitalizationsParams params) async {
    return _repository.getHospitalizations(skip: params.skip, take: params.take, search: params.search);
  }
}
