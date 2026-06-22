// [SWREQ-CORE-STATION-UC-001]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class GetStationsParams {
  final int? skip;
  final int? take;
  final String? search;
  final List<String>? searchFields;

  GetStationsParams({this.skip, this.take, this.search, this.searchFields});
}

class GetStationsUseCase {
  const GetStationsUseCase(this._repository);

  final IStationRepository _repository;

  Future<Result<ApiResponse<List<Station>>>> call(GetStationsParams params) async {
    return await _repository.getStations(skip: params.skip, take: params.take, search: params.search);
  }
}
