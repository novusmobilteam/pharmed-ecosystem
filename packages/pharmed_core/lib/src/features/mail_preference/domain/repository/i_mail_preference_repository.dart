import 'package:pharmed_core/pharmed_core.dart';

abstract class IMailPreferenceRepository {
  Future<Result<List<MailPreference>>> getPreferences({bool forceRefresh = true});
  Future<Result<void>> createMailPreference(MailPreference preference);
  Future<Result<void>> updateMailPreference(MailPreference preference);
  Future<Result<void>> deleteMailPreference(MailPreference preference);
}
