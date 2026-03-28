import '../../../../core/core.dart';
import '../model/mail_preference_dto.dart';
import 'mail_preference_datasource.dart';

class _MailPreferenceStore extends BaseLocalDataSource<MailPreferenceDTO, String> {
  _MailPreferenceStore({required super.filePath})
      : super(
          fromJson: (m) => MailPreferenceDTO.fromJson(m),
          toJson: (d) => d.toJson(),
          getId: (d) => d.id ?? '',
          assignId: (d, id) => d.copyWith(id: id),
        );
}

class MailPreferenceLocalDataSource implements MailPreferenceDataSource {
  final _MailPreferenceStore _store;

  MailPreferenceLocalDataSource({required String assetPath}) : _store = _MailPreferenceStore(filePath: assetPath);

  @override
  Future<Result<List<MailPreferenceDTO>>> getPreferences() async {
    final res = await _store.fetchRequest();
    return res.when(
      ok: (response) => Result.ok(response.data ?? []),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<MailPreferenceDTO?>> createMailPreference(MailPreferenceDTO dto) {
    return _store.createRequest(dto);
  }

  @override
  Future<Result<MailPreferenceDTO?>> updateMailPreference(MailPreferenceDTO dto) {
    if (dto.id == null || dto.id!.isEmpty) {
      return Future.value(
        Result.error(CustomException(message: 'updateMailPreference: id is null')),
      );
    }
    return _store.updateRequest(dto);
  }

  @override
  Future<Result<void>> deleteMailPreference(String id) {
    return _store.deleteRequest(id);
  }
}
