// [SWREQ-SETUP-UI-007] [IEC 62304 §5.5]
// Setup Wizard Adım 4 — master kabin tarama state tanımları.
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';
import '../../domain/entity/scan_log_entry.dart';

class Step4MasterState {
  const Step4MasterState({
    this.scanState = DrawerScanState.idle,
    this.scanLogs = const [],
    this.scannedLayout = const [],
  });

  final DrawerScanState scanState;
  final List<ScanLogEntry> scanLogs;
  final List<DrawerGroup> scannedLayout;

  bool get isComplete => scanState == DrawerScanState.found && scannedLayout.isNotEmpty;

  Step4MasterState copyWith({
    DrawerScanState? scanState,
    List<ScanLogEntry>? scanLogs,
    List<DrawerGroup>? scannedLayout,
  }) {
    return Step4MasterState(
      scanState: scanState ?? this.scanState,
      scanLogs: scanLogs ?? this.scanLogs,
      scannedLayout: scannedLayout ?? this.scannedLayout,
    );
  }
}

enum DrawerScanState {
  idle, // Henüz başlamadı
  scanning, // Taranıyor
  found, // Cihaz bulundu, yapı okundu
  error, // Tarama başarısız
}
