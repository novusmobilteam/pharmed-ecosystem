sealed class WithdrawCheckStatus {
  const WithdrawCheckStatus();
}

class CheckIdle extends WithdrawCheckStatus {
  const CheckIdle();
}

class CheckLoading extends WithdrawCheckStatus {
  const CheckLoading();
}

class CheckSuccess extends WithdrawCheckStatus {
  const CheckSuccess();
}

class CheckFailed extends WithdrawCheckStatus {
  final String? message;
  const CheckFailed({this.message});
}
