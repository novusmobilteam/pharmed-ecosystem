import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class WarehouseRemoteDataSource extends BaseRemoteDataSource {
  WarehouseRemoteDataSource({required super.apiManager});

  static const _base = '/Warehouse';

  @override
  String get logSwreq => 'SWREQ-DATA-WAREHOUSE-001';

  @override
  String get logUnit => 'SW-UNIT-WAREHOUSE';

  Future<Result<ApiResponse<List<WarehouseDTO>>?>> getWarehouses({int? skip, int? take, String? search}) async {
    return fetchRequest(
      path: _base,
      skip: skip,
      take: take,
      searchText: search,
      searchFields: const ['name'],
      envelope: ResponseEnvelope.raw,
      parser: BaseRemoteDataSource.apiResponseListParser(WarehouseDTO.fromJson),
      successLog: 'Depolar getirildi',
      emptyLog: 'Depo bulunamadı',
    );
  }

  Future<Result<void>> createWarehouse(WarehouseDTO dto) {
    return createRequest(
      path: _base,
      body: dto.toJson(),
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Depo oluşturuldu',
    );
  }

  Future<Result<void>> updateWarehouse(WarehouseDTO dto) {
    return updateRequest(
      path: _base,
      body: dto.toJson(),
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Depo güncellendi',
    );
  }

  Future<Result<void>> deleteWarehouse(int id) {
    return deleteRequest(path: '$_base/$id', parser: BaseRemoteDataSource.voidParser(), successLog: 'Depo silindi');
  }
}
