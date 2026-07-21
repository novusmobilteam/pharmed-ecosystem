enum CabinConnectionFailure { managerNotFound, managerConnectFailed, disconnected, unknown }

class CabinConnectionException implements Exception {
  const CabinConnectionException(this.failure, {this.detail});

  final CabinConnectionFailure failure;
  final String? detail;
}
