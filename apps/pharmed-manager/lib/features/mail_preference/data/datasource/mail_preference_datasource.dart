import '../../../../core/core.dart';
import '../model/mail_preference_dto.dart';

abstract class MailPreferenceDataSource {
  Future<Result<List<MailPreferenceDTO>>> getPreferences();
  Future<Result<MailPreferenceDTO?>> createMailPreference(MailPreferenceDTO dto);
  Future<Result<MailPreferenceDTO?>> updateMailPreference(MailPreferenceDTO dto);
  Future<Result<void>> deleteMailPreference(String id);
}
