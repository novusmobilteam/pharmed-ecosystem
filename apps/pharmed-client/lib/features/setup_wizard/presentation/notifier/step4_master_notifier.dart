// [SWREQ-SETUP-UI-007] [IEC 62304 §5.5]
// Setup Wizard Adım 4 — master kabin tarama state yöneticisi.
// Sınıf: Class B

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../core/providers/providers.dart';
import '../notifier/step2_notifier.dart';
import '../state/step4_master_state.dart';

final step4MasterNotifierProvider = NotifierProvider<Step4MasterNotifier, Step4MasterState>(Step4MasterNotifier.new);

class Step4MasterNotifier extends Notifier<Step4MasterState> {
  @override
  Step4MasterState build() => const Step4MasterState();

  /// [SWREQ-SETUP-UI-007]
  Future<void> scanDevice() async {
    final port = ref.read(step2NotifierProvider).basicInfo?.comPort;
    if (port == null || port.isEmpty) return;

    MedLogger.info(
      unit: 'SW-UNIT-SETUP',
      swreq: 'SWREQ-SETUP-UI-007',
      message: 'Cihaz taraması başlatıldı',
      context: {'port': port},
    );

    state = state.copyWith(scanState: DrawerScanState.scanning, scanLogs: [], scannedLayout: []);

    void addLog(ScanLogEntry entry) {
      state = state.copyWith(scanLogs: [...state.scanLogs, entry]);
    }

    void updateLastLog(ScanLogEntry Function(ScanLogEntry) updater) {
      if (state.scanLogs.isEmpty) return;
      final updated = [...state.scanLogs];
      updated[updated.length - 1] = updater(updated.last);
      state = state.copyWith(scanLogs: updated);
    }

    void onStatus(ScanStatus status, {String? detail}) {
      switch (status) {
        case ScanStatus.connecting:
          addLog(ScanLogEntry.pending('Seri porta bağlanılıyor…'));
        case ScanStatus.fetchingMetadata:
          addLog(ScanLogEntry.pending('Çekmece tanımları yükleniyor…'));
        case ScanStatus.searchingManager:
          addLog(ScanLogEntry.pending('Yönetim kartı aranıyor…'));
        case ScanStatus.scanningCards:
          addLog(ScanLogEntry.pending('Kontrol kartları taranıyor…'));
        case ScanStatus.connected:
          updateLastLog((e) => e.asOk(detail: detail));
        case ScanStatus.metadataReady:
          updateLastLog((e) => e.asOk(detail: detail));
        case ScanStatus.managerFound:
          updateLastLog((e) => e.asOk(detail: detail));
        case ScanStatus.drawerFound:
          addLog(ScanLogEntry(message: detail ?? 'Çekmece bulundu', status: ScanLogStatus.ok));
        case ScanStatus.connectionFailed:
        case ScanStatus.metadataFailed:
        case ScanStatus.managerNotFound:
        case ScanStatus.noCardsFound:
          updateLastLog((e) => e.asError(detail: detail));
        case ScanStatus.completed:
          break;
      }
    }

    final result = await ref.read(scanCabinUseCaseProvider)(
      portName: port,
      cabinType: CabinType.master,
      onStatusChanged: onStatus,
    );

    result.when(
      ok: (layout) {
        MedLogger.info(
          unit: 'SW-UNIT-SETUP',
          swreq: 'SWREQ-SETUP-UI-007',
          message: 'Tarama tamamlandı',
          context: {'drawerCount': layout.length},
        );
        state = state.copyWith(scanState: DrawerScanState.found, scannedLayout: layout);
      },
      error: (e) {
        MedLogger.error(unit: 'SW-UNIT-SETUP', swreq: 'SWREQ-SETUP-UI-007', message: 'Tarama hatası', error: e);
        state = state.copyWith(scanState: DrawerScanState.error);
      },
    );
  }

  void resetScan() {
    state = const Step4MasterState();
  }
}
