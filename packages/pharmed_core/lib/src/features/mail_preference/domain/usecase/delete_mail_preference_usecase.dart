import 'package:pharmed_core/pharmed_core.dart';

class DeleteMailPreferenceUsecase {
  final IMailPreferenceRepository _repository;

  DeleteMailPreferenceUsecase(this._repository);

  Future<Result<void>> call(MailPreference preference) async {
    return _repository.deleteMailPreference(preference);
  }
}
