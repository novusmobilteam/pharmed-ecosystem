import 'package:pharmed_core/pharmed_core.dart';

import '../mail_preference.dart';

class MailPreferenceRepositoryImpl implements IMailPreferenceRepository {
  final MailPreferenceRemoteDataSource _dataSource;
  final MailPreferenceMapper _mailPreferenceMapper;

  MailPreferenceRepositoryImpl({
    required MailPreferenceRemoteDataSource dataSource,
    required MailPreferenceMapper mailPreferenceMapper,
  }) : _dataSource = dataSource,
       _mailPreferenceMapper = mailPreferenceMapper;

  @override
  Future<Result<List<MailPreference>>> getPreferences({bool forceRefresh = true}) async {
    final r = await _dataSource.getPreferences();
    return r.when(
      ok: (dtos) {
        final entities = _mailPreferenceMapper.toEntityList(dtos);
        return Result.ok(entities);
      },
      error: Result.error,
    );
  }

  @override
  Future<Result<void>> createMailPreference(MailPreference preference) async {
    final dto = _mailPreferenceMapper.toDto(preference);
    final r = await _dataSource.createMailPreference(dto);
    return r.when(ok: Result.ok, error: Result.error);
  }

  @override
  Future<Result<void>> updateMailPreference(MailPreference preference) async {
    final dto = _mailPreferenceMapper.toDto(preference);
    final r = await _dataSource.updateMailPreference(dto);
    return r.when(ok: Result.ok, error: Result.error);
  }

  @override
  Future<Result<void>> deleteMailPreference(MailPreference preference) async {
    final id = preference.id ?? 0;
    final r = await _dataSource.deleteMailPreference(id);
    return r.when(ok: Result.ok, error: Result.error);
  }
}
