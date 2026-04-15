import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

// [SWREQ-DATA-DRUGCLASS-001]
// Sınıf: Class B
class DrugClassRemoteDataSource extends BaseRemoteDataSource {
  DrugClassRemoteDataSource({required super.apiManager});

  static const _base = '/DrugClass';

  @override
  String get logSwreq => 'SWREQ-DATA-DRUGCLASS-001';

  @override
  String get logUnit => 'SW-UNIT-DRUGCLASS';

  Future<Result<ApiResponse<List<DrugClassDTO>>?>> getDrugClasses({int? skip, int? take, String? search}) async {
    return fetchRequest(
      path: _base,
      skip: skip,
      take: take,
      searchText: search,
      searchFields: const ['name'],
      envelope: ResponseEnvelope.raw,
      parser: BaseRemoteDataSource.apiResponseListParser(DrugClassDTO.fromJson),
      successLog: 'İlaç sınıfları getirildi',
      emptyLog: 'İlaç sınıfı bulunamadı',
    );
  }

  Future<Result<void>> createDrugClass(DrugClassDTO dto) {
    return createRequest(
      path: _base,
      body: dto.toJson(),
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'İlaç sınıfı oluşturuldu',
    );
  }

  Future<Result<void>> updateDrugClass(DrugClassDTO dto) {
    return updateRequest(
      path: _base,
      body: dto.toJson(),
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Branş güncellendi',
    );
  }

  Future<Result<void>> deleteDrugClass(int id) {
    return deleteRequest(
      path: '$_base/$id',
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'İlaç sınıfı silindi',
    );
  }
}
