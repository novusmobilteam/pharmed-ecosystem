import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';
import 'package:pharmed_data/src/network/base_remote_datasource.dart';

// [SWREQ-DATA-DOSAGE-001]
// Sınıf: Class B
class DosageFormRemoteDataSource extends BaseRemoteDataSource {
  DosageFormRemoteDataSource({required super.apiManager});

  static const _base = '/DosageForm';

  @override
  String get logSwreq => 'SWREQ-DATA-DOSAGE-001';

  @override
  String get logUnit => 'SW-UNIT-DOSAGE';

  Future<Result<ApiResponse<List<DosageFormDTO>>?>> getDosageForms({int? skip, int? take, String? search}) async {
    return fetchRequest(
      path: _base,
      skip: skip,
      take: take,
      searchText: search,
      searchFields: const ['name'],
      envelope: ResponseEnvelope.raw,
      parser: BaseRemoteDataSource.apiResponseListParser(DosageFormDTO.fromJson),
      successLog: 'Dozaj formları getirildi',
      emptyLog: 'Dozaj formu bulunamadı',
    );
  }

  Future<Result<void>> createDosageForm(DosageFormDTO dto) {
    return createRequest(
      path: _base,
      body: dto.toJson(),
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Dozaj formu oluşturuldu',
    );
  }

  Future<Result<void>> updateDosageForm(DosageFormDTO dto) {
    return updateRequest(
      path: _base,
      body: dto.toJson(),
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Dozaj formu güncellendi',
    );
  }

  Future<Result<void>> deleteDosageForm(int id) {
    return deleteRequest(
      path: '$_base/$id',
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Dozaj formu silindi',
    );
  }
}
