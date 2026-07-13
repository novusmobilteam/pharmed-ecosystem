import 'package:pharmed_core/pharmed_core.dart';

class LoginWithBadgeUseCase {
  const LoginWithBadgeUseCase(this._repository);

  final IAuthRepository _repository;

  Future<Result<AuthToken>> call({required String cardData, required String macAddress}) =>
      _repository.loginWithBadge(cardData: cardData, macAddress: macAddress);
}
