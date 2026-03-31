// [SWREQ-CORE-USER-UC-003]
// Sadece pharmed_client tarafından kullanılır.
// Tanık hemşire/doktor girişi — kabin işlemlerinde ikinci onay.
// IUserManager bağımlılığı.
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class WitnessUserLoginParams {
  const WitnessUserLoginParams({required this.email, required this.password, required this.macAddress});

  final String email;
  final String password;
  final String macAddress;
}

class WitnessUserLoginUseCase {
  const WitnessUserLoginUseCase(this._repository);

  final IUserManager _repository;

  Future<Result<User?>> call(WitnessUserLoginParams params) =>
      _repository.witnessUserLogin(email: params.email, password: params.password, macAddress: params.macAddress);
}
