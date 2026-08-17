// [SWREQ-CLI-RFID-SCAN-002] [IEC 62304 §5.5]
// RFID okuyucu için tarama oturumu. Çekmece oturumundan bağımsız.
//
// Sorumluluk:
//   - start() → IRfidService.startInventory() stream'ine subscribe ol
//   - Okunan EPC'leri broadcast stream üzerinden yayınla
//   - stop() → IRfidService.stopInventory() çağır, subscription kapat
//   - Aynı EPC tekrar yayınlanmaz (deduplication oturum içinde)
//
// Polling artık yok — RfidService Real-time mode kullanıyor, tag'ler
// donanım tarafından otomatik push ediliyor.
//
// Sınıf: Class B

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

class RfidScanSessionNotifier extends ChangeNotifier {
  RfidScanSessionNotifier({required IRfidService rfid}) : _rfid = rfid;

  final IRfidService _rfid;

  bool _isDisposed = false;

  void _notify() {
    if (_isDisposed) return;
    notifyListeners();
  }

  StreamSubscription<RfidTag>? _inventorySub;
  final _epcController = StreamController<String>.broadcast();
  final _lostController = StreamController<String>.broadcast();

  final _lastSeen = <String, DateTime>{};
  final _presentEpcs = <String>{};
  Timer? _presenceTimer;
  static const _presenceTimeout = Duration(seconds: 3);
  static const _presenceCheckInterval = Duration(milliseconds: 500);

  /// Okunan EPC'leri yayınlayan broadcast stream.
  Stream<String> get epcStream => _epcController.stream;
  Stream<String> get epcLostStream => _lostController.stream;

  /// Aktif snapshot işlemleri. Birden çok aynı anda başlatılabilse de
  /// pratikte tek bir feature snapshot bekler; liste defensive kalır.
  final _baselineCompleters = <Completer<Set<String>>>[];

  /// Şu an kapsama alanındaki tüm EPC'lerin anlık snapshot'ı.
  /// Çekmece açıkken her an çağrılabilir; immutable bir kopya döner.
  Set<String> get presentEpcs => Set.unmodifiable(_presentEpcs);

  // ── State ────────────────────────────────────────────────────────

  bool _isScanning = false;
  bool get isScanning => _isScanning;

  RfidFailure? _failure;
  RfidFailure? get failure => _failure;

  bool get hasError => _failure != null;

  void _setScanning(bool value, {RfidFailure? failure, bool clearError = false}) {
    _isScanning = value;
    _failure = clearError ? null : (failure ?? _failure);
    _notify();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _completePendingSnapshots();
    unawaited(_inventorySub?.cancel());
    unawaited(_epcController.close());
    unawaited(_lostController.close());
    _presenceTimer?.cancel();
    super.dispose();
  }

  // ── API ──────────────────────────────────────────────────────────

  /// İnventory başlat. RFID service Real-time mode'a geçer ve tag'ler
  /// stream üzerinden gelmeye başlar.
  void start() {
    if (_inventorySub != null) {
      MedLogger.warn(
        unit: 'RfidScanSessionNotifier',
        swreq: 'SWREQ-CLI-RFID-SCAN-002',
        message: 'start() çağrıldı ama inventory zaten aktif',
      );
      return;
    }

    if (!_rfid.isConnected) {
      MedLogger.warn(
        unit: 'RfidScanSessionNotifier',
        swreq: 'SWREQ-CLI-RFID-SCAN-002',
        message: 'start() iptal — RFID bağlı değil',
      );
      _failure = RfidFailure.notConnected;
      _notify();
      return;
    }

    _lastSeen.clear();
    _presentEpcs.clear();
    _setScanning(true, clearError: true);

    MedLogger.info(
      unit: 'RfidScanSessionNotifier',
      swreq: 'SWREQ-CLI-RFID-SCAN-002',
      message: 'RFID inventory başlıyor',
    );

    try {
      _inventorySub = _rfid.startInventory().listen(_onTagRead, onError: _onInventoryError, onDone: _onInventoryDone);
    } on StateError catch (e) {
      MedLogger.error(
        unit: 'RfidScanSessionNotifier',
        swreq: 'SWREQ-CLI-RFID-SCAN-002',
        message: 'startInventory başarısız',
        context: {'error': e.message},
      );
      _setScanning(false, failure: RfidFailure.inventoryStartFailed);
    }

    _startPresenceTimer();
  }

  /// İnventory durdur. RFID service Answer Mode'a döner.
  Future<void> stop() async {
    _stopPresenceTimer();
    _completePendingSnapshots();

    final sub = _inventorySub;
    _inventorySub = null;

    if (sub != null) {
      // cancel() öncesi RfidService'teki _inventoryController'ı kapat —
      // böylece onCancel tetiklenmez, stopInventory() tek komut gönderir.
      await _rfid.stopInventory(); // Answer Mode'a dön + controller.close()
      if (_isDisposed) return;
      await sub.cancel(); // artık onCancel'da _setWorkingMode gitmez
      if (_isDisposed) return;
    }

    if (_isScanning) {
      _isScanning = false;
      _notify();
    }

    MedLogger.info(
      unit: 'RfidScanSessionNotifier',
      swreq: 'SWREQ-CLI-RFID-SCAN-002',
      message: 'RFID inventory durdu',
      context: {'totalEpcsRead': _presentEpcs.length},
    );
  }

  /// Çekmece açıldıktan sonra çağrılır.
  /// [window] süresince stream'i dinler, biriken EPC'leri snapshot olarak döner.
  Future<Set<String>> snapshot({
    Duration settleTime = const Duration(milliseconds: 500),
    Duration maxWindow = const Duration(milliseconds: 2500),
  }) async {
    if (_inventorySub == null) {
      MedLogger.warn(
        unit: 'RfidScanSessionNotifier',
        swreq: 'SWREQ-CLI-RFID-SCAN-003',
        message: 'snapshot() çağrıldı ama inventory aktif değil',
      );
      return const {};
    }

    MedLogger.info(
      unit: 'RfidScanSessionNotifier',
      swreq: 'SWREQ-CLI-RFID-SCAN-003',
      message: 'Baseline snapshot başladı (stabilizasyon)',
      context: {'settleMs': settleTime.inMilliseconds, 'maxMs': maxWindow.inMilliseconds},
    );

    final deadline = DateTime.now().add(maxWindow);
    int lastCount = -1;
    DateTime lastChange = DateTime.now();

    while (DateTime.now().isBefore(deadline)) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (_isDisposed) return const {};
      final now = _presentEpcs.length;
      if (now != lastCount) {
        lastCount = now;
        lastChange = DateTime.now();
      } else if (DateTime.now().difference(lastChange) >= settleTime && now > 0) {
        break;
      }
    }

    final result = Set<String>.from(_presentEpcs);
    MedLogger.info(
      unit: 'RfidScanSessionNotifier',
      swreq: 'SWREQ-CLI-RFID-SCAN-003',
      message: 'Baseline snapshot tamamlandı',
      context: {'epcCount': result.length, 'epcs': result.toList()},
    );
    return result;
  }

  // ── Internal handlers ────────────────────────────────────────────

  void _onTagRead(RfidTag tag) {
    final now = DateTime.now();
    _lastSeen[tag.epc] = now;

    if (_presentEpcs.add(tag.epc)) {
      _epcController.add(tag.epc);
      MedLogger.info(
        unit: 'RfidScanSessionNotifier',
        swreq: 'SWREQ-CLI-RFID-SCAN-002',
        message: 'Yeni EPC kapsama alanına girdi',
        context: {'epc': tag.epc, 'rssi': tag.rssi, 'antenna': tag.antenna},
      );
    }
  }

  void _onInventoryError(Object e, StackTrace _) {
    MedLogger.error(
      unit: 'RfidScanSessionNotifier',
      swreq: 'SWREQ-CLI-RFID-SCAN-002',
      message: 'Inventory stream hatası',
      context: {'error': e.toString()},
    );
    _failure = RfidFailure.inventoryStreamError;
    _notify();
  }

  void _onInventoryDone() {
    _inventorySub = null;
    if (_isScanning) {
      _isScanning = false;
      _notify();
    }
  }

  void _startPresenceTimer() {
    _presenceTimer = Timer.periodic(_presenceCheckInterval, (_) {
      final now = DateTime.now();
      final lost = _presentEpcs.where((epc) {
        final last = _lastSeen[epc];
        return last == null || now.difference(last) > _presenceTimeout;
      }).toList();

      for (final epc in lost) {
        _presentEpcs.remove(epc);
        _lastSeen.remove(epc);
        _lostController.add(epc);
        MedLogger.info(
          unit: 'RfidScanSessionNotifier',
          swreq: 'SWREQ-CLI-RFID-SCAN-002',
          message: 'EPC kapsama alanından çıktı (timeout)',
          context: {'epc': epc},
        );
      }
    });
  }

  void _stopPresenceTimer() {
    _presenceTimer?.cancel();
    _presenceTimer = null;
    _presentEpcs.clear();
    _lastSeen.clear();
  }

  void _completePendingSnapshots() {
    for (final c in _baselineCompleters) {
      if (!c.isCompleted) c.complete(const {});
    }
    _baselineCompleters.clear();
  }
}
