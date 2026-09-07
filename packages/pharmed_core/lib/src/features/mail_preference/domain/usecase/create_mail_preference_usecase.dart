import 'package:pharmed_core/pharmed_core.dart';

class CreateMailPreferenceUsecase {
  final IMailPreferenceRepository _repository;

  CreateMailPreferenceUsecase(this._repository);

  Future<Result<void>> call(MailPreference preference) async {
    return _repository.createMailPreference(preference);
  }
}
