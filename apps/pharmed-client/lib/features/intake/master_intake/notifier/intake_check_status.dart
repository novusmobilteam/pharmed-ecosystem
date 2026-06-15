sealed class IntakeCheckStatus {
  const IntakeCheckStatus();
}

class CheckIdle extends IntakeCheckStatus {
  const CheckIdle();
}

class CheckLoading extends IntakeCheckStatus {
  const CheckLoading();
}

class CheckSuccess extends IntakeCheckStatus {
  const CheckSuccess();
}

class CheckFailed extends IntakeCheckStatus {
  final String? message;
  const CheckFailed({this.message});
}
