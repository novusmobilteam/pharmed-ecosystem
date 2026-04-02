import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';
import 'package:pharmed_utils/pharmed_utils.dart';

class StationRemoteDataSource extends BaseRemoteDataSource {
  StationRemoteDataSource({required super.apiManager});

  static const _base = '/Station';

  @override
  String get logSwreq => 'SWREQ-DATA-STATION-001';

  @override
  String get logUnit => 'SW-UNIT-STATION';

  Future<Result<ApiResponse<List<StationDTO>>?>> getStations({int? skip, int? take, String? search}) async {
    return await fetchRequest(
      path: _base,
      skip: skip,
      take: take,
      //searchText: search,
      //searchFields: const ['name'],
      envelope: ResponseEnvelope.raw,
      parser: BaseRemoteDataSource.apiResponseListParser(StationDTO.fromJson),
      successLog: 'İstasyonlar getirildi',
      emptyLog: 'İstasyon bulunamadı',
    );
  }

  Future<Result<void>> createStation(StationDTO dto) {
    return createRequest(
      path: _base,
      body: dto.toJson(),
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'İstasyon oluşturuldu',
    );
  }

  Future<Result<void>> updateStation(StationDTO dto) {
    return updateRequest(
      path: _base,
      body: dto.toJson(),
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'İstasyon güncellendi',
    );
  }

  Future<Result<void>> deleteStation(int id) {
    return deleteRequest(path: '$_base/$id', parser: BaseRemoteDataSource.voidParser(), successLog: 'İstasyon silindi');
  }

  Future<Result<void>> updateStationMacAddress(int stationId) async {
    final macAddress = await DeviceInfo.getMacAddress();

    return updateRequest(
      path: '$_base/macAddress/$stationId?macAddress=$macAddress',
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'İstasyon MAC Adresi güncellendi',
    );
  }

  Future<Result<StationDTO?>> getStation(int stationId) async {
    return fetchRequest(
      path: '$_base/$stationId',
      parser: BaseRemoteDataSource.singleParser(StationDTO.fromJson),
      successLog: 'İstasyon getirildi',
      emptyLog: 'İstasyon bulunamadı',
    );
  }

  Future<Result<StationDTO?>> getCurrentStation() async {
    return fetchRequest(
      path: '$_base/currentStation',
      parser: BaseRemoteDataSource.singleParser(StationDTO.fromJson),
      successLog: 'İstasyon getirildi',
      emptyLog: 'İstasyon bulunamadı',
    );
  }
}
