sealed class IntakeCheckState {
  const IntakeCheckState();
}

class CheckIdle extends IntakeCheckState {
  const CheckIdle();
}

class CheckLoading extends IntakeCheckState {
  const CheckLoading();
}

class CheckSuccess extends IntakeCheckState {
  const CheckSuccess();
}

class CheckFailed extends IntakeCheckState {
  final String? message;
  const CheckFailed({this.message});
}
