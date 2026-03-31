import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';
import 'package:pharmed_data/src/network/base_remote_datasource.dart';

// [SWREQ-DATA-UNIT-001]
// Sınıf: Class B
class UnitRemoteDataSource extends BaseRemoteDataSource {
  UnitRemoteDataSource({required super.apiManager});

  static const _base = '/Unit';

  @override
  String get logSwreq => 'SWREQ-DATA-UNIT-001';

  @override
  String get logUnit => 'SW-UNIT-UNIT';

  Future<Result<ApiResponse<List<UnitDTO>>?>> getUnits({int? skip, int? take, String? search}) async {
    return fetchRequest(
      path: _base,
      skip: skip,
      take: take,
      searchText: search,
      searchFields: const ['name'],
      envelope: ResponseEnvelope.raw,
      parser: BaseRemoteDataSource.apiResponseListParser(UnitDTO.fromJson),
      successLog: 'Birimler getirildi',
      emptyLog: 'Birim bulunamadı',
    );
  }

  Future<Result<void>> createUnit(UnitDTO dto) {
    return createRequest(
      path: _base,
      body: dto.toJson(),
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Birim oluşturuldu',
    );
  }

  Future<Result<void>> updateUnit(UnitDTO dto) {
    return updateRequest(
      path: _base,
      body: dto.toJson(),
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Birim güncellendi',
    );
  }

  Future<Result<void>> deleteUnit(int id) {
    return deleteRequest(path: '$_base/$id', parser: BaseRemoteDataSource.voidParser(), successLog: 'Birim silindi');
  }
}
