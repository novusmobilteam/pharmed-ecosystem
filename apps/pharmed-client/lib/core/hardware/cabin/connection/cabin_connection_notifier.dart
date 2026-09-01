import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../../providers/providers.dart';
import 'cabin_connection.dart';

final cabinConnectionProvider = NotifierProvider<CabinConnectionNotifier, CabinConnectionState>(
  CabinConnectionNotifier.new,
);

class CabinConnectionNotifier extends Notifier<CabinConnectionState> {
  @override
  CabinConnectionState build() => const CabinConnectionState(status: CabinConnectionStatus.disconnected);

  ScanManagerUseCase get _scanManager => ref.read(scanManagerUseCaseProvider);

  Future<void> connect() async {
    print('CabinConnectionNotifier.connect()');
    if (state.status == CabinConnectionStatus.connecting) return;
    state = const CabinConnectionState(status: CabinConnectionStatus.connecting);

    try {
      final manager = await _scanManager.call();
      state = CabinConnectionState(status: CabinConnectionStatus.connected, managerAddress: manager.addressIndex);
    } on CabinConnectionException catch (e) {
      state = CabinConnectionState(status: CabinConnectionStatus.error, failure: e.failure, errorDetail: e.detail);
    }

    print('CabinConnectionNotifier.connect() done, state: $state');
  }

  void markDisconnected() {
    state = const CabinConnectionState(
      status: CabinConnectionStatus.error,
      failure: CabinConnectionFailure.disconnected,
    );
  }

  Future<void> reconnect() => connect();
}
