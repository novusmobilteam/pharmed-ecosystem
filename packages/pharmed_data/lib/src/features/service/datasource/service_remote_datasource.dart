import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class ServiceRemoteDataSource extends BaseRemoteDataSource {
  ServiceRemoteDataSource({required super.apiManager});

  static const _base = '/Service';

  @override
  String get logSwreq => 'SWREQ-DATA-SERVICE-001';

  @override
  String get logUnit => 'SW-UNIT-SERVICE';

  Future<Result<ApiResponse<List<ServiceDTO>>?>> getServices({int? skip, int? take, String? search}) async {
    final res = await fetchRequest(
      path: _base,
      skip: skip,
      take: take,
      searchText: search,
      searchFields: const ['name'],
      envelope: ResponseEnvelope.raw,
      parser: BaseRemoteDataSource.apiResponseListParser(ServiceDTO.fromJson),
      successLog: 'Servisler getirildi',
      emptyLog: 'Servis bulunamadı',
    );

    return res.when(
      ok: (data) => Result.ok(data ?? const ApiResponse(data: [], totalCount: 0)),
      error: Result.error,
    );
  }

  Future<Result<ServiceDTO?>> getService(int serviceId) async {
    final res = await fetchRequest(
      path: '$_base/$serviceId',
      parser: BaseRemoteDataSource.singleParser(ServiceDTO.fromJson),
      successLog: 'Servis getirildi',
      emptyLog: 'Servis bulunamadı',
    );

    return res.when(ok: (data) => Result.ok(data), error: Result.error);
  }

  Future<Result<void>> createService(ServiceDTO dto) {
    print(dto.toJson());
    return createRequest(
      path: _base,
      body: dto.toJson(),
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Servis oluşturuldu',
    );
  }

  Future<Result<void>> updateService(ServiceDTO dto) {
    print(dto.toJson());
    print(dto.toJson().toString());
    return updateRequest(
      path: '$_base/${dto.id}',
      body: dto.toJson(),
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Servis güncellendi',
    );
  }

  Future<Result<void>> deleteService(int id) {
    return deleteRequest(path: '$_base/$id', parser: BaseRemoteDataSource.voidParser(), successLog: 'Servis silindi');
  }

  Future<Result<List<RoomDto>?>> getRooms(int serviceId) async {
    return await fetchRequest(
      path: '/Room/service/$serviceId',
      parser: BaseRemoteDataSource.listParser(RoomDto.fromJson),
      successLog: 'Odalar getirildi',
      emptyLog: 'Oda bulunamadı',
    );
  }

  Future<Result<List<BedDto>?>> getBeds(int roomId) async {
    return await fetchRequest(
      path: '/Bed/room/$roomId',
      parser: BaseRemoteDataSource.listParser(BedDto.fromJson),
      successLog: 'Yataklar getirildi',
      emptyLog: 'Yatak bulunamadı',
    );
  }

  Future<Result<void>> deleteRoom(int roomId) {
    return deleteRequest(path: '/Room/$roomId', parser: BaseRemoteDataSource.voidParser(), successLog: 'Oda silindi');
  }

  Future<Result<void>> deleteBed(int bedId) {
    return deleteRequest(path: '/Bed/$bedId', parser: BaseRemoteDataSource.voidParser(), successLog: 'Yatak silindi');
  }
}
