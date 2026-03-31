import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';
import 'package:pharmed_data/src/network/base_remote_datasource.dart';

// [SWREQ-DATA-MATERIALTYPE-001]
// Sınıf: Class B
class MaterialTypeRemoteDataSource extends BaseRemoteDataSource {
  MaterialTypeRemoteDataSource({required super.apiManager});

  static const _base = '/MaterialType';

  @override
  String get logSwreq => 'SWREQ-DATA-MATERIALTYPE-001';

  @override
  String get logUnit => 'SW-UNIT-MATERIALTYPE';

  Future<Result<ApiResponse<List<MaterialTypeDTO>>?>> getMaterialTypes({int? skip, int? take, String? search}) async {
    return fetchRequest(
      path: _base,
      skip: skip,
      take: take,
      searchText: search,
      searchFields: const ['name'],
      envelope: ResponseEnvelope.raw,
      parser: BaseRemoteDataSource.apiResponseListParser(MaterialTypeDTO.fromJson),
      successLog: 'Malzeme tipleri getirildi',
      emptyLog: 'Malzeme tipi bulunamadı',
    );
  }

  Future<Result<void>> createMaterialType(MaterialTypeDTO dto) {
    return createRequest(
      path: _base,
      body: dto.toJson(),
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Malzeme tipi oluşturuldu',
    );
  }

  Future<Result<void>> updateMaterialType(MaterialTypeDTO dto) {
    return updateRequest(
      path: _base,
      body: dto.toJson(),
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Malzeme tipi güncellendi',
    );
  }

  Future<Result<void>> deleteMaterialType(int id) {
    return deleteRequest(
      path: '$_base/$id',
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Malzeme tipi silindi',
    );
  }
}
