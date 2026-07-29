sealed class RefundCheckStatus {
  const RefundCheckStatus();
}

class RefundCheckIdle extends RefundCheckStatus {
  const RefundCheckIdle();
}

class RefundCheckLoading extends RefundCheckStatus {
  const RefundCheckLoading();
}

class RefundCheckSuccess extends RefundCheckStatus {
  const RefundCheckSuccess();
}

class RefundCheckFailed extends RefundCheckStatus {
  final String? message;
  const RefundCheckFailed({this.message});
}
