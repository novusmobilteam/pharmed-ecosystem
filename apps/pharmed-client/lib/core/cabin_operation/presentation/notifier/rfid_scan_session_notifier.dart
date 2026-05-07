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

import '../../../providers/providers.dart';
import 'rfid_scan_session_state.dart';

final rfidScanSessionProvider = NotifierProvider<RfidScanSessionNotifier, RfidScanSessionState>(
  RfidScanSessionNotifier.new,
);

class RfidScanSessionNotifier extends Notifier<RfidScanSessionState> {
  StreamSubscription<RfidTag>? _inventorySub;
  final _seenEpcs = <String>{};
  final _epcController = StreamController<String>.broadcast();

  /// Okunan EPC'leri yayınlayan broadcast stream.
  Stream<String> get epcStream => _epcController.stream;

  IRfidService get _rfid => ref.read(rfidServiceProvider);

  @override
  RfidScanSessionState build() {
    ref.onDispose(_dispose);
    return const RfidScanSessionState.initial();
  }

  // ── Public API ───────────────────────────────────────────────────────────

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

    _seenEpcs.clear();
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
  }

  /// İnventory durdur. RFID service Answer Mode'a döner.
  Future<void> stop() async {
    final sub = _inventorySub;
    _inventorySub = null;

    if (sub != null) {
      await sub.cancel();
    }

    final result = await _rfid.stopInventory();
    result.when(
      ok: (_) {},
      error: (e) {
        MedLogger.warn(
          unit: 'RfidScanSessionNotifier',
          swreq: 'SWREQ-CLI-RFID-SCAN-002',
          message: 'stopInventory hatası (göz ardı edildi)',
          context: {'error': e.toString()},
        );
      },
    );

    if (state.isScanning) {
      state = state.copyWith(isScanning: false);
    }

    MedLogger.info(
      unit: 'RfidScanSessionNotifier',
      swreq: 'SWREQ-CLI-RFID-SCAN-002',
      message: 'RFID inventory durdu',
      context: {'totalEpcsRead': _seenEpcs.length},
    );
  }

  // ── Internal handlers ────────────────────────────────────────────────────

  void _onTagRead(RfidTag tag) {
    if (!_seenEpcs.add(tag.epc)) return; // duplicate

    _epcController.add(tag.epc);
    MedLogger.info(
      unit: 'RfidScanSessionNotifier',
      swreq: 'SWREQ-CLI-RFID-SCAN-002',
      message: 'Yeni EPC okundu',
      context: {'epc': tag.epc, 'rssi': tag.rssi, 'antenna': tag.antenna},
    );
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

  Future<void> _dispose() async {
    await _inventorySub?.cancel();
    await _epcController.close();
  }
}
