import 'package:pharmed_core/pharmed_core.dart';

class UpdateMailPreferenceUsecase {
  final IMailPreferenceRepository _repository;

  UpdateMailPreferenceUsecase(this._repository);

  Future<Result<void>> call(MailPreference preference) async {
    return _repository.updateMailPreference(preference);
  }
}
