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

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../providers/providers.dart';
import 'rfid_scan_session_state.dart';

final rfidScanSessionProvider = NotifierProvider<RfidScanSessionNotifier, RfidScanSessionState>(
  RfidScanSessionNotifier.new,
);

class RfidScanSessionNotifier extends Notifier<RfidScanSessionState> {
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

  IRfidService get _rfid => ref.read(rfidServiceProvider);

  /// Aktif snapshot işlemleri. Birden çok aynı anda başlatılabilse de
  /// pratikte tek bir feature snapshot bekler; liste defensive kalır.
  final _baselineCompleters = <Completer<Set<String>>>[];

  /// Şu an kapsama alanındaki tüm EPC'lerin anlık snapshot'ı.
  /// Çekmece açıkken her an çağrılabilir; immutable bir kopya döner.
  Set<String> get presentEpcs => Set.unmodifiable(_presentEpcs);

  @override
  RfidScanSessionState build() {
    ref.onDispose(_dispose);
    return const RfidScanSessionState.initial();
  }

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
      state = state.copyWith(lastError: 'RFID okuyucuya bağlı değil');
      return;
    }

    _lastSeen.clear();
    _presentEpcs.clear();
    state = state.copyWith(isScanning: true, clearError: true);

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
      state = state.copyWith(isScanning: false, lastError: e.message);
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
      await sub.cancel(); // artık onCancel'da _setWorkingMode gitmez
    }

    if (state.isScanning) {
      state = state.copyWith(isScanning: false);
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
  /// Stream çalışmaya devam eder; sonraki [epcStream] ve [epcLostStream]
  /// event'leri normal akışta çalışır.
  ///
  /// Inventory aktif değilse boş set döner (yanlış kullanımı sessizce kabul eder
  /// ama log'lar; çağıran tarafın start() sonrası bu metodu çağırması beklenir).
  Future<Set<String>> snapshot({Duration window = const Duration(milliseconds: 1500)}) async {
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
      message: 'Baseline snapshot başladı',
      context: {'windowMs': window.inMilliseconds},
    );

    final completer = Completer<Set<String>>();
    _baselineCompleters.add(completer);

    Timer(window, () {
      if (completer.isCompleted) return;
      _baselineCompleters.remove(completer);
      final result = Set<String>.from(_presentEpcs);

      MedLogger.info(
        unit: 'RfidScanSessionNotifier',
        swreq: 'SWREQ-CLI-RFID-SCAN-003',
        message: 'Baseline snapshot tamamlandı',
        context: {'epcCount': result.length, 'epcs': result.toList()},
      );

      completer.complete(result);
    });

    return completer.future;
  }

  // ── Internal handlers ────────────────────────────────────────────────────

  void _onTagRead(RfidTag tag) {
    final now = DateTime.now();
    _lastSeen[tag.epc] = now;

    // İlk kez görüldü → yayınla
    if (_presentEpcs.add(tag.epc)) {
      _epcController.add(tag.epc);
      MedLogger.info(
        unit: 'RfidScanSessionNotifier',
        swreq: 'SWREQ-CLI-RFID-SCAN-002',
        message: 'Yeni EPC kapsama alanına girdi',
        context: {'epc': tag.epc, 'rssi': tag.rssi, 'antenna': tag.antenna},
      );
    }
    // _seenEpcs artık kullanılmıyor
  }

  void _onInventoryError(Object e, StackTrace _) {
    MedLogger.error(
      unit: 'RfidScanSessionNotifier',
      swreq: 'SWREQ-CLI-RFID-SCAN-002',
      message: 'Inventory stream hatası',
      context: {'error': e.toString()},
    );
    state = state.copyWith(lastError: e.toString());
  }

  void _onInventoryDone() {
    _inventorySub = null;
    if (state.isScanning) {
      state = state.copyWith(isScanning: false);
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

  Future<void> _dispose() async {
    _completePendingSnapshots();
    await _inventorySub?.cancel();
    await _epcController.close();
    await _lostController.close(); // mevcut kodda kapatılmıyordu, ekledim
  }

  void _completePendingSnapshots() {
    for (final c in _baselineCompleters) {
      if (!c.isCompleted) c.complete(const {});
    }
    _baselineCompleters.clear();
  }
}
