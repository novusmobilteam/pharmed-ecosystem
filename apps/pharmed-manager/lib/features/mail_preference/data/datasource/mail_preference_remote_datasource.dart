import '../../../../core/core.dart';
import '../model/mail_preference_dto.dart';
import 'mail_preference_datasource.dart';

class MailPreferenceRemoteDataSource extends BaseRemoteDataSource implements MailPreferenceDataSource {
  final String _basePath = '/EmailSendingPreferences';

  MailPreferenceRemoteDataSource({required super.apiManager});

  @override
  Future<Result<List<MailPreferenceDTO>>> getPreferences() async {
    final res = await fetchRequest<List<MailPreferenceDTO>>(
      path: _basePath,
      parser: listParser(MailPreferenceDTO.fromJson),
      successLog: 'Mail preferences fetched',
      emptyLog: 'No mail preferences',
    );
    return res.when(
      ok: (data) => Result.ok(data ?? const <MailPreferenceDTO>[]),
      error: Result.error,
    );
  }

  @override
  Future<Result<MailPreferenceDTO?>> createMailPreference(MailPreferenceDTO dto) {
    return createRequest<MailPreferenceDTO?>(
      path: _basePath,
      body: dto.toJson(),
      parser: singleParser(MailPreferenceDTO.fromJson),
      successLog: 'Mail preference created',
    );
  }

  @override
  Future<Result<MailPreferenceDTO?>> updateMailPreference(MailPreferenceDTO dto) {
    if (dto.id == null || dto.id!.isEmpty) {
      return Future.value(
        Result.error(CustomException(message: 'updateMailPreference: id is null')),
      );
    }
    return updateRequest<MailPreferenceDTO?>(
      path: '$_basePath/${dto.id}',
      body: dto.toJson(),
      parser: singleParser(MailPreferenceDTO.fromJson),
      successLog: 'Mail preference updated',
    );
  }

  @override
  Future<Result<void>> deleteMailPreference(String id) {
    return deleteRequest<void>(
      path: '$_basePath/$id',
      parser: voidParser(),
      successLog: 'Mail preference deleted',
    );
  }
}
