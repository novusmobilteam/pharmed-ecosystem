// [SWREQ-SETUP-UI-001] [IEC 62304 §5.5]
// Setup Wizard UiState — 5 adımlı ilk kurulum akışı.
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';
import '../../../../core/hardware/service/rfid/model/rfid_reader_info.dart';
import '../../domain/model/scan_log_entry.dart';
import '../../domain/model/wizard_draft.dart';

sealed class SetupWizardUiState {
  const SetupWizardUiState();
}

/// Wizard aktif — kullanıcı adımları dolduruyor
final class WizardActive extends SetupWizardUiState {
  const WizardActive({
    required this.currentStep,
    required this.draft,
    required this.completedSteps,
    this.scanState = DrawerScanState.idle,
    this.availablePorts = const [],
    this.rfidTestState = RfidTestState.idle,
    this.rfidReaderInfo,
    this.rfidTestError,
    this.stationsLoadState = StationsLoadState.idle,
    this.stations = const [],
    this.stationsError,
    this.scanLogs = const [],
    this.rooms = const [],
    this.servicesLoadState = ServicesLoadState.idle,
    this.services = const [],
    this.servicesError,
  });

  final int currentStep; // 1–5
  final WizardDraft draft;
  final Set<int> completedSteps; // Tamamlanan adımlar (yeşil)
  final DrawerScanState scanState; // Adım 4 tarama durumu
  final List<String> availablePorts;

  // Adım 2 - RFID
  final RfidTestState rfidTestState;
  final RfidReaderInfo? rfidReaderInfo; // test başarılıysa dolar
  final String? rfidTestError;

  // Adım 3 — istasyon/servis listesi
  final StationsLoadState stationsLoadState;
  final List<Station> stations;
  final String? stationsError;

  final ServicesLoadState servicesLoadState;
  final List<HospitalService> services;
  final String? servicesError;

  final List<Room> rooms;

  // Adım 4 — tarama log satırları
  final List<ScanLogEntry> scanLogs;

  WizardActive copyWith({
    int? currentStep,
    WizardDraft? draft,
    Set<int>? completedSteps,
    DrawerScanState? scanState,
    List<String>? availablePorts,
    StationsLoadState? stationsLoadState,
    List<Station>? stations,
    String? stationsError,
    List<ScanLogEntry>? scanLogs,
    ServicesLoadState? servicesLoadState,
    List<HospitalService>? services,
    String? servicesError,
    RfidTestState? rfidTestState,
    RfidReaderInfo? rfidReaderInfo,
    String? rfidTestError,
  }) {
    return WizardActive(
      currentStep: currentStep ?? this.currentStep,
      draft: draft ?? this.draft,
      completedSteps: completedSteps ?? this.completedSteps,
      scanState: scanState ?? this.scanState,
      availablePorts: availablePorts ?? this.availablePorts,
      stationsLoadState: stationsLoadState ?? this.stationsLoadState,
      stations: stations ?? this.stations,
      stationsError: stationsError ?? this.stationsError,
      scanLogs: scanLogs ?? this.scanLogs,
      servicesLoadState: servicesLoadState ?? this.servicesLoadState,
      services: services ?? this.services,
      servicesError: servicesError ?? this.servicesError,
      rfidTestState: rfidTestState ?? this.rfidTestState,
      rfidReaderInfo: rfidReaderInfo ?? this.rfidReaderInfo,
      rfidTestError: rfidTestError ?? this.rfidTestError,
    );
  }
}

/// Kayıt işlemi devam ediyor (Son adımda "Tamamla" basıldıktan sonra)
final class WizardSaving extends SetupWizardUiState {
  const WizardSaving({required this.draft});
  final WizardDraft draft;
}

/// Kayıt başarılı — success ekranı gösterilir
final class WizardSaved extends SetupWizardUiState {
  const WizardSaved({required this.cabinId, required this.cabinName});
  final int cabinId;
  final String cabinName;
}

/// Kayıt hatası — wizard'a geri dön seçeneği
final class WizardSaveError extends SetupWizardUiState {
  const WizardSaveError({required this.message, required this.draft});
  final String message;
  final WizardDraft draft;
}

// ─────────────────────────────────────────────────────────────────
// Alt-durumlar
// ─────────────────────────────────────────────────────────────────

/// Çekmece tarama alt-durumu (Adım 4 — Standart kabin)
enum DrawerScanState {
  idle, // Henüz başlamadı
  scanning, // Taranıyor (animasyon gösterilir)
  found, // Cihaz bulundu, yapı okundu
  error, // Tarama başarısız
}

/// İstasyon listesi yükleme durumu (Adım 3 — Standart kabin)
enum StationsLoadState {
  idle, // Henüz yüklenmedi
  loading, // API isteği devam ediyor
  loaded, // Liste hazır
  error, // Yükleme başarısız
}

enum ServicesLoadState { idle, loading, loaded, error }

enum RfidTestState { idle, testing, success, failure }
