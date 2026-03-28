import '../../../../core/core.dart';

import '../entity/station.dart';
import '../repository/i_station_repository.dart';

class GetStationsParams {
  final int? skip;
  final int? take;
  final String? search;

  GetStationsParams({this.skip, this.take, this.search});
}

class GetStationsUseCase implements UseCase<ApiResponse<List<Station>>, GetStationsParams> {
  final IStationRepository _repository;

  GetStationsUseCase(this._repository);

  @override
  Future<Result<ApiResponse<List<Station>>>> call(GetStationsParams params) {
    return _repository.getStations(skip: params.skip, take: params.take, search: params.search);
  }
}
