// [SWREQ-CLI-CABIN-CONN-001] [IEC 62304 §5.5]
// Kabin yönetim kartı bağlantı durumunu yönetir.
// Sınıf: Class B

import 'package:flutter/foundation.dart';
import 'package:pharmed_core/pharmed_core.dart';

enum CabinConnectionStatus { disconnected, connecting, connected, error }

class CabinConnectionNotifier extends ChangeNotifier {
  CabinConnectionNotifier({required ScanManagerUseCase scanManager}) : _scanManager = scanManager;

  final ScanManagerUseCase _scanManager;

  bool _isDisposed = false;

  void _notify() {
    if (_isDisposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  CabinConnectionStatus _status = CabinConnectionStatus.disconnected;
  CabinConnectionStatus get status => _status;

  int? _managerAddress;
  int? get managerAddress => _managerAddress;

  CabinConnectionFailure? _failure;
  CabinConnectionFailure? get failure => _failure;

  String? _errorDetail;
  String? get errorDetail => _errorDetail;

  bool get isConnected => _status == CabinConnectionStatus.connected;
  bool get isError => _status == CabinConnectionStatus.error;
  bool get isConnecting => _status == CabinConnectionStatus.connecting;

  Future<void> connect() async {
    if (_status == CabinConnectionStatus.connecting) return;

    _status = CabinConnectionStatus.connecting;
    _failure = null;
    _errorDetail = null;
    _notify();

    try {
      final manager = await _scanManager.call();
      if (_isDisposed) return;
      _status = CabinConnectionStatus.connected;
      _managerAddress = manager.addressIndex;
      _failure = null;
      _errorDetail = null;
      _notify();
    } on CabinConnectionException catch (e) {
      if (_isDisposed) return;
      _status = CabinConnectionStatus.error;
      _failure = e.failure;
      _errorDetail = e.detail;
      _notify();
    }
  }

  void markDisconnected() {
    _status = CabinConnectionStatus.error;
    _failure = CabinConnectionFailure.disconnected;
    _errorDetail = null;
    _notify();
  }

  Future<void> reconnect() => connect();
}
