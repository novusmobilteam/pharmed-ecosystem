import '../../../../core/core.dart';
import '../../../../core/utils/device_info.dart';

import '../../../user/user.dart';

class WitnessUserLoginParams {
  final String username;
  final String password;

  WitnessUserLoginParams({required this.username, required this.password});
}

class WitnessUserLoginUseCase implements UseCase<User?, WitnessUserLoginParams> {
  final IUserRepository _repository;

  WitnessUserLoginUseCase(this._repository);

  @override
  Future<Result<User?>> call(WitnessUserLoginParams params) async {
    final macAddress = await DeviceInfo.getMacAddress();
    return _repository.witnessUserLogin(email: params.username, password: params.password, macAddress: macAddress);
  }
}
