import 'package:pharmed_core/pharmed_core.dart';

class GetMailPreferencesUseCase {
  final IMailPreferenceRepository _repository;

  GetMailPreferencesUseCase(this._repository);

  Future<Result<List<MailPreference>>> call() async {
    return await _repository.getPreferences();
  }
}
