import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

// [SWREQ-DATA-FIRM-001]
// Sınıf: Class B
class FirmRemoteDataSource extends BaseRemoteDataSource {
  FirmRemoteDataSource({required super.apiManager});

  static const _base = '/Firm';

  @override
  String get logSwreq => 'SWREQ-DATA-Firm-001';

  @override
  String get logUnit => 'SW-UNIT-Firm';

  Future<Result<ApiResponse<List<FirmDTO>>?>> getFirms({int? skip, int? take, String? search}) async {
    return fetchRequest(
      path: _base,
      skip: skip,
      take: take,
      searchText: search,
      searchFields: const ['name'],
      envelope: ResponseEnvelope.raw,
      parser: BaseRemoteDataSource.apiResponseListParser(FirmDTO.fromJson),
      successLog: 'Firmalar getirildi',
      emptyLog: 'Firma bulunamadı',
    );
  }

  Future<Result<void>> createFirm(FirmDTO dto) {
    print(dto.toJson().toString());
    return createRequest(
      path: _base,
      body: dto.toJson(),
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Firma oluşturuldu',
    );
  }

  Future<Result<void>> updateFirm(FirmDTO dto) {
    return updateRequest(
      path: '${_base}/${dto.id}',
      body: dto.toJson(),
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Firma güncellendi',
    );
  }

  Future<Result<void>> deleteFirm(int id) {
    return deleteRequest(path: '$_base/$id', parser: BaseRemoteDataSource.voidParser(), successLog: 'Firma silindi');
  }
}
