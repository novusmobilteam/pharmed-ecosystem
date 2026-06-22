// cabin_connection_state.dart
enum CabinConnectionStatus { disconnected, connecting, connected, error }

class CabinConnectionState {
  const CabinConnectionState({required this.status, this.managerAddress, this.message});

  final CabinConnectionStatus status;
  final int? managerAddress;
  final String? message;

  CabinConnectionState copyWith({CabinConnectionStatus? status, int? managerAddress, String? message}) =>
      CabinConnectionState(
        status: status ?? this.status,
        managerAddress: managerAddress ?? this.managerAddress,
        message: message ?? this.message,
      );
}
