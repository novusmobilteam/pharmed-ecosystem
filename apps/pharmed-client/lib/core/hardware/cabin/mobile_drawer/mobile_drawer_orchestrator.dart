// [SWREQ-CLI-CABIN-OP-005] [IEC 62304 §5.5]
// Mobil çekmece + RFID oturumlarını birlikte yöneten composition helper.
//
// Sorumluluk:
//   - mobileDrawerSessionProvider'a subscribe olur
//   - rfidScanSessionProvider.epcStream'i dinler
//   - Drawer.Opened anında RFID polling'i otomatik başlatır
//   - Drawer.Closed/Failed anında RFID polling'i otomatik durdurur
//   - Stage geçişleri ve EPC okumaları için feature notifier'a callback yapar
//
// Feature notifier'ları (refill, pickup, return, ...) kendi build() içinde
// bir instance oluşturur, init() çağırır, dispose'da temizler.
//
// State manipülasyonu YAPMAZ — feature notifier callback'lerle kendi state'ini
// yönetir.
//
// Sınıf: Class B

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../providers/providers.dart';
import 'mobile_drawer_session_notifier.dart';
import 'mobile_drawer_session_state.dart';
import '../../rfid/rfid_scan_session_notifier.dart';
import 'mobile_drawer_stage.dart';

typedef DrawerStageCallback = void Function(MobileDrawerStage? previous, MobileDrawerStage current);

typedef EpcReadCallback = void Function(String epc);
typedef EpcLostCallback = void Function(String epc);

class MobileDrawerOrchestrator {
  MobileDrawerOrchestrator({required this.ref});

  final Ref ref;

  ProviderSubscription<MobileDrawerSessionState>? _drawerSub;

  DrawerStageCallback? _onStage;

  EpcReadCallback? _onEpc;
  EpcLostCallback? _onEpcLost;

  StreamSubscription<String>? _epcSub;
  StreamSubscription<String>? _epcLostSub;

  bool _initialized = false;
  bool _isConnecting = false;
  static bool _globalConnecting = false;

  IRfidService get _rfid => ref.read(rfidServiceProvider);

  /// Listener'ları başlatır. Feature notifier build() içinde çağırmalı.
  ///
  /// [onStageChange] her drawer stage geçişinde çağrılır.
  /// [onEpcRead] her yeni okunan EPC için çağrılır (deduplication oturum içinde).
  void init({DrawerStageCallback? onStageChange, EpcReadCallback? onEpcRead, EpcLostCallback? onEpcLost}) {
    if (_initialized) {
      MedLogger.warn(
        unit: 'MobileDrawerOrchestrator',
        swreq: 'SWREQ-CLI-CABIN-OP-005',
        message: 'init() zaten çağrılmış, yeniden başlatma atlandı',
      );
      return;
    }
    _initialized = true;

    _onStage = onStageChange;
    _onEpc = onEpcRead;
    _onEpcLost = onEpcLost;

    _drawerSub = ref.listen<MobileDrawerSessionState>(
      mobileDrawerSessionProvider,
      (prev, next) => _handleStageChange(prev?.stage, next.stage),
    );

    _epcSub = ref.read(rfidScanSessionProvider.notifier).epcStream.listen(_handleEpcRead);
    _epcLostSub = ref.read(rfidScanSessionProvider.notifier).epcLostStream.listen(_handleEpcLost);
  }

  /// Tüm subscription'ları kapatır. Feature notifier ref.onDispose'da çağırmalı.
  Future<void> dispose() async {
    _drawerSub?.close();
    _drawerSub = null;
    await _epcSub?.cancel();
    await _epcLostSub?.cancel();

    // RFID oturumunu kapat — bir sonraki feature (dolum→alım geçişi) temiz başlasın.
    // Aksi halde inventory açık kalır, yeni feature Opened'da erken/çift inventory yaşar.
    ref.read(rfidScanSessionProvider.notifier).stop();
    if (_rfid.isConnected) {
      await _rfid.disconnect();
    }

    _onStage = null;
    _epcSub = null;
    _epcLostSub = null;
    _onEpc = null;
    _onEpcLost = null;
    _initialized = false;
    _isConnecting = false;
    _globalConnecting = false; // static guard'ı da temizle — geçişte kalıntı kalmasın
  }

  /// Verilen [slot] için yeni bir çekmece oturumu başlatır.
  /// Port numarası [slots] listesindeki sıraya göre çözülür
  /// (MobileSlotVisual.portOf).
  ///
  /// RFID polling otomatik olarak Opened anında başlar.
  Future<void> open({required List<MobileSlotVisual> slots, required MobileSlotVisual slot}) async {
    MedLogger.info(unit: 'Mobile Drawer Orch', swreq: '', message: '_drawer.open()');
    final port = MobileSlotVisual.portOf(slots, slot);
    await ref.read(mobileDrawerSessionProvider.notifier).start(drawerPort: port, slotId: slot.slotId);
  }

  /// Aynı slot ile çekmeceyi tekrar açar (Closed/Failed sonrası).
  Future<void> reopen() async {
    await ref.read(mobileDrawerSessionProvider.notifier).reopen();
  }

  /// Çekmece ve RFID oturumlarını sıfırlar. Banner kaybolur.
  Future<void> stop() async {
    ref.read(rfidScanSessionProvider.notifier).stop();
    await Future.delayed(const Duration(milliseconds: 150));
    if (_rfid.isConnected) {
      await _rfid.disconnect();
    }
    await ref.read(mobileDrawerSessionProvider.notifier).stop();
  }

  /// Baseline snapshot — RFID inventory aktifken çağrılır.
  /// [window] süresi boyunca biriken EPC'leri döner.
  ///
  /// Çekmece açıldıktan sonra _handleStageChange RFID'yi başlatır;
  /// feature notifier _onStage callback'inde MobileDrawerOpened gördüğünde
  /// bu metodu çağırarak baseline alır.
  Future<Set<String>> snapshot({Duration window = const Duration(milliseconds: 1500)}) {
    return ref.read(rfidScanSessionProvider.notifier).snapshot();
  }

  void _handleStageChange(MobileDrawerStage? prev, MobileDrawerStage next) {
    final rfidNotifier = ref.read(rfidScanSessionProvider.notifier);

    if (next is MobileDrawerOpened && prev is! MobileDrawerOpened) {
      if (!_isConnecting) {
        _isConnecting = true;
        // Opened'ı feature notifier'a inventory HAZIR olduktan sonra bildir.
        unawaited(
          _onDrawerOpened(rfidNotifier).whenComplete(() {
            _isConnecting = false;
            _onStage?.call(prev, next);
          }),
        );
      }
      return; // Opened için _onStage'i aşağıda TEKRAR çağırma
    } else if (next is MobileDrawerClosed || next is MobileDrawerFailed) {
      _onDrawerClosed(rfidNotifier);
    }

    _onStage?.call(prev, next);
  }

  Future<void> _onDrawerOpened(RfidScanSessionNotifier rfidNotifier) async {
    await _ensureRfidConnected();
    rfidNotifier.start();
  }

  void _onDrawerClosed(RfidScanSessionNotifier rfidNotifier) {
    rfidNotifier.stop();
  }

  void _handleEpcRead(String epc) {
    _onEpc?.call(epc);
  }

  void _handleEpcLost(String epc) {
    _onEpcLost?.call(epc);
  }

  Future<void> _ensureRfidConnected() async {
    // Zaten bağlıysa hiçbir şey yapma — reconnect döngüsünü kır.
    if (_rfid.isConnected) {
      MedLogger.info(
        unit: 'MobileDrawerOrchestrator',
        swreq: 'SWREQ-CLI-CABIN-OP-005',
        message: 'RFID zaten bağlı, reconnect atlandı',
      );
      return;
    }

    while (_globalConnecting) {
      await Future.delayed(const Duration(milliseconds: 50));
    }

    // Bekleme bitince başka bir çağrı bağlamış olabilir — tekrar kontrol et.
    if (_rfid.isConnected) return;

    _globalConnecting = true;
    try {
      ref.read(rfidScanSessionProvider.notifier).stop();
      await Future.delayed(const Duration(milliseconds: 150));

      // disconnect'e gerek yok — zaten bağlı değiliz (yukarıda kontrol edildi).

      MedLogger.info(
        unit: 'MobileDrawerOrchestrator',
        swreq: 'SWREQ-CLI-CABIN-OP-005',
        message: 'RFID connect başlatılıyor',
      );

      final result = await _rfid.connect('192.168.1.190', 6000);
      result.when(
        ok: (_) => MedLogger.info(
          unit: 'MobileDrawerOrchestrator',
          swreq: 'SWREQ-CLI-CABIN-OP-005',
          message: 'RFID connect başarılı',
        ),
        error: (e) => MedLogger.error(
          unit: 'MobileDrawerOrchestrator',
          swreq: 'SWREQ-CLI-CABIN-OP-005',
          message: 'RFID connect başarısız',
          context: {'error': e.message},
        ),
      );
    } finally {
      _globalConnecting = false;
    }
  }
}
