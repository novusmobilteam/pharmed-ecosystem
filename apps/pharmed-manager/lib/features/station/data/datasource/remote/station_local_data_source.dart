import '../../../../../core/core.dart';
import '../../model/station_dto.dart';
import 'station_data_source.dart';

class StationLocalDataSource extends BaseLocalDataSource<StationDTO, int> implements StationDataSource {
  StationLocalDataSource({required String assetPath})
      : super(
          filePath: assetPath,
          fromJson: (m) => StationDTO.fromJson(m),
          toJson: (d) => d.toJson(),
          getId: (d) => d.id ?? -1,
          assignId: (d, id) => StationDTO(
            id: id,
            name: d.name,
            stationDrug: d.stationDrug,
            stationMedicalConsumables: d.stationMedicalConsumables,
          ),
        );

  @override
  Future<Result<ApiResponse<List<StationDTO>>>> getStations({
    int? skip,
    int? take,
    String? search,
  }) {
    return fetchRequest(
      skip: skip,
      take: take,
      searchText: search,
      searchField: 'name',
    );
  }

  @override
  Future<Result<StationDTO?>> createStation(StationDTO dto) => createRequest(dto);

  @override
  Future<Result<StationDTO?>> updateStation(StationDTO dto) => updateRequest(dto);

  @override
  Future<Result<void>> deleteStation(int id) => deleteRequest(id);

  @override
  Future<Result<void>> updateStationMacAddress(int stationId) async {
    return Result.ok(null);
  }

  @override
  Future<Result<StationDTO?>> getStation(int stationId) async {
    return Result.ok(null);
  }

  @override
  Future<Result<StationDTO?>> getCurrentStation() async {
    return Result.ok(null);
  }
}
