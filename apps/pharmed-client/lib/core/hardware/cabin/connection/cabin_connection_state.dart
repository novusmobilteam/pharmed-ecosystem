import 'package:pharmed_core/pharmed_core.dart';

enum CabinConnectionStatus { disconnected, connecting, connected, error }

class CabinConnectionState {
  const CabinConnectionState({required this.status, this.managerAddress, this.failure, this.errorDetail});

  final CabinConnectionStatus status;
  final int? managerAddress;
  final CabinConnectionFailure? failure;
  final String? errorDetail;

  bool get isConnected => status == CabinConnectionStatus.connected;
  bool get isError => status == CabinConnectionStatus.error;

  CabinConnectionState copyWith({
    CabinConnectionStatus? status,
    int? managerAddress,
    CabinConnectionFailure? failure,
    String? errorDetail,
  }) => CabinConnectionState(
    status: status ?? this.status,
    managerAddress: managerAddress ?? this.managerAddress,
    failure: failure ?? this.failure,
    errorDetail: errorDetail ?? this.errorDetail,
  );
}
