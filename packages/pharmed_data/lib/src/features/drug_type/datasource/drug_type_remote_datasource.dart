import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

// [SWREQ-DATA-DRUGTYPE-001]
// Sınıf: Class B
class DrugTypeRemoteDataSource extends BaseRemoteDataSource {
  DrugTypeRemoteDataSource({required super.apiManager});

  static const _base = '/DrugType';

  @override
  String get logSwreq => 'SWREQ-DATA-DRUGTYPE-001';

  @override
  String get logUnit => 'SW-UNIT-DRUGTYPE';

  Future<Result<ApiResponse<List<DrugTypeDTO>>?>> getDrugTypes({int? skip, int? take, String? search}) async {
    return fetchRequest(
      path: _base,
      skip: skip,
      take: take,
      searchText: search,
      searchFields: const ['name'],
      envelope: ResponseEnvelope.raw,
      parser: BaseRemoteDataSource.apiResponseListParser(DrugTypeDTO.fromJson),
      successLog: 'İlaç tipleri getirildi',
      emptyLog: 'İlaç tipi bulunamadı',
    );
  }

  Future<Result<void>> createDrugType(DrugTypeDTO dto) {
    return createRequest(
      path: _base,
      body: dto.toJson(),
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'İlaç tipi oluşturuldu',
    );
  }

  Future<Result<void>> updateDrugType(DrugTypeDTO dto) {
    return updateRequest(
      path: _base,
      body: dto.toJson(),
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'İlaç tipi güncellendi',
    );
  }

  Future<Result<void>> deleteDrugType(int id) {
    return deleteRequest(
      path: '$_base/$id',
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'İlaç tipi silindi',
    );
  }
}
