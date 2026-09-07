import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class MailPreferenceRemoteDataSource extends BaseRemoteDataSource {
  MailPreferenceRemoteDataSource({required super.apiManager});

  final String _basePath = '/EmailSendingPreferences';

  @override
  String get logSwreq => 'SWREQ-DATA-PREFERENCE-001';

  @override
  String get logUnit => 'SW-UNIT-PREFERENCE';

  Future<Result<List<MailPreferenceDTO>>> getPreferences() async {
    final res = await fetchRequest<List<MailPreferenceDTO>>(
      path: _basePath,
      parser: BaseRemoteDataSource.listParser(MailPreferenceDTO.fromJson),
      successLog: 'Mail preferences fetched',
      emptyLog: 'No mail preferences',
    );
    return res.when(ok: (data) => Result.ok(data ?? const <MailPreferenceDTO>[]), error: Result.error);
  }

  Future<Result<void>> createMailPreference(MailPreferenceDTO dto) {
    return postRequest<MailPreferenceDTO?>(
      path: _basePath,
      body: dto.toJson(),
      parser: BaseRemoteDataSource.singleParser(MailPreferenceDTO.fromJson),
      successLog: 'Mail preference created',
    );
  }

  Future<Result<void>> updateMailPreference(MailPreferenceDTO dto) {
    return putRequest<MailPreferenceDTO?>(
      path: '$_basePath/${dto.id}',
      body: dto.toJson(),
      parser: BaseRemoteDataSource.singleParser(MailPreferenceDTO.fromJson),
      successLog: 'Mail preference updated',
    );
  }

  Future<Result<void>> deleteMailPreference(int id) {
    return deleteRequest<void>(
      path: '$_basePath/$id',
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Mail preference deleted',
    );
  }
}
