import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/src/network/base_remote_datasource.dart';

class CabinRemoteDataSource extends BaseRemoteDataSource {
  CabinRemoteDataSource({required super.apiManager});

  final String _base = '/Cabin';

  String get logSwreq => 'SWREQ-DATA-CABIN-001';

  String get logUnit => 'SW-UNIT-CABIN';

  Future<Result<List<CabinDTO>>> getCabins() async {
    final res = await fetchRequest<List<CabinDTO>>(
      path: '$_base',
      parser: BaseRemoteDataSource.listParser(CabinDTO.fromJson),
      successLog: 'Kabinler getirildi',
      emptyLog: 'Kabin bulunamadı',
    );

    return res.when(ok: (data) => Result.ok(data ?? []), error: Result.error);
  }

  Future<Result<CabinDTO?>> getCabin(int cabinId) async {
    final res = await fetchRequest<CabinDTO>(
      path: '$_base/$cabinId',
      parser: BaseRemoteDataSource.singleParser(CabinDTO.fromJson),
      successLog: 'Kabin-$cabinId getirildi',
      emptyLog: 'Kabin bulunamadı',
    );

    return res.when(ok: (data) => Result.ok(data), error: Result.error);
  }

  Future<Result<List<CabinDTO>>> getCabinsByStation(int stationId) async {
    final res = await fetchRequest<List<CabinDTO>>(
      path: '$_base/station/$stationId',
      parser: BaseRemoteDataSource.listParser(CabinDTO.fromJson),
      successLog: 'İstasyon bazlı kabinler getirildi',
      emptyLog: 'Bu istasyon için kabin bulunamadı',
    );

    return res.when(ok: (data) => Result.ok(data ?? []), error: Result.error);
  }

  Future<Result<CabinDTO?>> createCabin(CabinDTO dto) {
    return createRequest(
      path: _base,
      body: dto.toJson(),
      parser: BaseRemoteDataSource.singleParser(CabinDTO.fromJson),
      successLog: 'Kabin oluşturuldu',
    );
  }

  Future<Result<CabinDTO?>> updateCabin(CabinDTO dto) {
    return updateRequest(
      path: _base,
      body: dto.toJson(),
      parser: BaseRemoteDataSource.singleParser(CabinDTO.fromJson),
      successLog: 'Kabin güncellendi',
    );
  }

  Future<Result<void>> deleteCabin(int id) {
    return deleteRequest<void>(
      path: '$_base/$id',
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Kabin silindi',
    );
  }

  Future<Result<List<DrawerConfigDTO>>> getDrawerConfigs() async {
    final res = await fetchRequest<List<DrawerConfigDTO>>(
      path: '/DrawrDetail',
      parser: BaseRemoteDataSource.listParser(DrawerConfigDTO.fromJson),
      successLog: 'Kabin konfigürasyonları getirildi',
      emptyLog: 'Konfigürasyon bulunamadı',
    );

    return res.when(ok: (data) => Result.ok(data ?? const <DrawerConfigDTO>[]), error: Result.error);
  }

  Future<Result<List<DrawerTypeDTO>>> getDrawerTypes() async {
    final res = await fetchRequest<List<DrawerTypeDTO>>(
      path: '/Drawr',
      parser: BaseRemoteDataSource.listParser(DrawerTypeDTO.fromJson),
      successLog: 'Çekmece tipleri getirildi',
      emptyLog: 'Çekmece tipi bulunamadı',
    );

    return res.when(ok: (data) => Result.ok(data ?? const <DrawerTypeDTO>[]), error: Result.error);
  }

  Future<Result<void>> createDrawerSlots(List<DrawerSlotDTO> dtos) async {
    return createBulkRequest(path: '/CabinDesign/bulk', body: dtos.map((d) => d.toJson()).toList(), parser: null);
  }

  Future<Result<List<DrawerSlotDTO>>> getCabinSlots(int cabinId) async {
    final res = await fetchRequest<List<DrawerSlotDTO>>(
      path: '/CabinDesign/cabin/$cabinId',
      parser: BaseRemoteDataSource.listParser(DrawerSlotDTO.fromJson),
      successLog: 'Cabin Layout fetched',
      emptyLog: 'No Layout data',
    );

    return res.when(ok: (list) => Result.ok(list ?? const <DrawerSlotDTO>[]), error: Result.error);
  }

  Future<Result<List<MobileDrawerSlotDTO>>> getMobileCabinSlots(int cabinId) async {
    final res = await fetchRequest<List<MobileDrawerSlotDTO>>(
      path: '/CabinDesign/drawCabinMobile/$cabinId',
      parser: BaseRemoteDataSource.listParser(MobileDrawerSlotDTO.fromJson),
      successLog: 'Mobil kabin layout getirildi',
      emptyLog: 'Mobil kabin layout bulunamadı',
    );
    return res.when(ok: (list) => Result.ok(list ?? const []), error: Result.error);
  }

  Future<Result<void>> updateDrawerSlots(List<DrawerSlotDTO> dtos) {
    return updateBulkRequest(path: '$_base/bulk', body: dtos.map((d) => d.toJson()).toList(), parser: null);
  }

  Future<Result<List<DrawerSlotDTO>>> getSerumCabins() async {
    final res = await fetchRequest<List<DrawerSlotDTO>>(
      path: '/CabinDrawr/serum',
      parser: BaseRemoteDataSource.listParser(DrawerSlotDTO.fromJson),
      successLog: 'Serum kabinleri getirildi',
      emptyLog: 'Serum kabini bulunamadı',
    );

    return res.when(ok: (list) => Result.ok(list ?? const <DrawerSlotDTO>[]), error: Result.error);
  }

  Future<Result<void>> createMobileDrawerSlots(List<MobileDrawerRequestDTO> drawers) {
    return createBulkRequest(
      path: '/CabinDesign/mobileBulk',
      body: drawers.map((d) => d.toJson()).toList(),
      parser: null,
    );
  }

  Future<Result<void>> updateMobileDrawerSlots(List<MobileDrawerRequestDTO> drawers) {
    return updateBulkRequest(
      path: '/CabinDesign/mobile/bulk',
      body: drawers.map((d) => d.toJson()).toList(),
      parser: null,
    );
  }

  Future<Result<List<DrawerUnitDTO>>> getDrawerUnits(int slotId) async {
    final res = await fetchRequest<List<DrawerUnitDTO>>(
      path: '/CabinDesign/cabinDrawr/$slotId',
      parser: BaseRemoteDataSource.listParser(DrawerUnitDTO.fromJson),
    );

    return res.when(ok: (list) => Result.ok(list ?? const <DrawerUnitDTO>[]), error: Result.error);
  }
}
