import '../../../../core/core.dart';
import '../../domain/entity/mail_preference.dart';

abstract class IMailPreferenceRepository {
  void clearCache();

  Future<Result<List<MailPreference>>> getPreferences({bool forceRefresh = true});
  Future<Result<MailPreference>> createMailPreference(MailPreference preference);
  Future<Result<MailPreference>> updateMailPreference(MailPreference preference);
  Future<Result<void>> deleteMailPreference(MailPreference preference);
}
