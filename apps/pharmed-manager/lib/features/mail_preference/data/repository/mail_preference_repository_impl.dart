import '../../../../core/core.dart';
import '../../domain/entity/mail_preference.dart';
import '../datasource/mail_preference_datasource.dart';
import 'mail_preference_repository.dart';

class MailPreferenceRepository implements IMailPreferenceRepository {
  final MailPreferenceDataSource _ds;
  List<MailPreference>? _cache;

  MailPreferenceRepository._(this._ds);

  /// Production
  factory MailPreferenceRepository.prod({required MailPreferenceDataSource remote}) =>
      MailPreferenceRepository._(remote);

  /// Development (lokal JSON vs.)
  factory MailPreferenceRepository.dev({required MailPreferenceDataSource local}) => MailPreferenceRepository._(local);

  @override
  void clearCache() => _cache = null;

  @override
  Future<Result<List<MailPreference>>> getPreferences({bool forceRefresh = true}) async {
    if (!forceRefresh && _cache != null) {
      return Result.ok(List<MailPreference>.from(_cache!));
    }

    final r = await _ds.getPreferences();
    return r.when(
      ok: (list) {
        final entities = (list).map((e) => e.toEntity()).toList();
        _cache = entities;
        return Result.ok(entities);
      },
      error: (err) {
        if (_cache?.isNotEmpty == true) {
          // Best-effort: cache varsa dön
          return Result.ok(List<MailPreference>.from(_cache!));
        }
        return Result.error(err);
      },
    );
  }

  @override
  Future<Result<MailPreference>> createMailPreference(MailPreference preference) async {
    final dto = preference.toDTO();
    final r = await _ds.createMailPreference(dto);
    return r.when(
      ok: (saved) {
        final entity = (saved ?? dto).toEntity();
        _cache = (_cache ?? <MailPreference>[])..add(entity);
        return Result.ok(entity);
      },
      error: Result.error,
    );
  }

  @override
  Future<Result<MailPreference>> updateMailPreference(MailPreference preference) async {
    final dto = preference.toDTO();
    final r = await _ds.updateMailPreference(dto);
    return r.when(
      ok: (saved) {
        final entity = (saved ?? dto).toEntity();
        final i = _cache?.indexWhere((x) => x.id == entity.id) ?? -1;
        if (i >= 0) _cache![i] = entity;
        return Result.ok(entity);
      },
      error: Result.error,
    );
  }

  @override
  Future<Result<void>> deleteMailPreference(MailPreference preference) async {
    final id = preference.id;
    if (id == null || id.isEmpty) {
      return Result.error(CustomException(message: 'deleteMailPreference: id is null'));
    }

    final r = await _ds.deleteMailPreference(id);
    return r.when(
      ok: (_) {
        _cache?.removeWhere((x) => x.id == id);
        return const Result.ok(null);
      },
      error: Result.error,
    );
  }
}
