import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class OverdueDescriptionRemoteDataSource extends BaseRemoteDataSource {
  OverdueDescriptionRemoteDataSource({required super.apiManager});

  static const _base = '/OverdueAdministrationTemplate';

  @override
  String get logUnit => 'SW-UNIT-OVERDUE-TEMPLATE';

  @override
  String get logSwreq => 'SWREQ-DATA-OVERDUE-TEMPLATE-001';

  Future<Result<List<OverdueDescriptionDto>?>> getTemplates({String? search}) {
    return fetchRequest(
      path: _base,
      parser: BaseRemoteDataSource.listParser(OverdueDescriptionDto.fromJson),
      successLog: 'Gecikme açıklama şablonları getirildi',
      emptyLog: 'Gecikme açıklama şablonu bulunamadı',
    );
  }

  Future<Result<OverdueDescriptionDto?>> createTemplate(OverdueDescriptionDto dto) {
    return postRequest(
      path: _base,
      body: dto.toJson(),
      parser: BaseRemoteDataSource.singleParser(OverdueDescriptionDto.fromJson),
      successLog: 'Gecikme açıklama şablonu oluşturuldu',
    );
  }

  Future<Result<OverdueDescriptionDto?>> updateTemplate(OverdueDescriptionDto dto) {
    return putRequest(
      path: '$_base/${dto.id}',
      body: dto.toJson(),
      parser: BaseRemoteDataSource.singleParser(OverdueDescriptionDto.fromJson),
      successLog: 'Gecikme açıklama şablonu güncellendi',
    );
  }

  Future<Result<void>> deleteTemplate(int id) {
    return deleteRequest(
      path: '$_base/$id',
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Gecikme açıklama şablonu silindi',
    );
  }
}
