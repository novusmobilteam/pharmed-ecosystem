// lib/features/setup_wizard/presentation/notifier/setup_wizard_notifier.dart
//
// [SWREQ-SETUP-UI-002] [IEC 62304 §5.5]
// Setup Wizard state yöneticisi.
// Her adımın verisini biriktir, son adımda kaydet.
// Sınıf: Class B

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/core/cache/app_settings_cache.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import '../../../../core/providers/providers.dart';
import '../../../cabin/cabin.dart';
import '../../domain/model/cabin_setup_config.dart';
import '../../domain/model/wizard_mobile_layout.dart';
import '../../domain/model/wizard_draft.dart';
import '../../domain/model/scan_log_entry.dart';
import '../state/setup_wizard_ui_state.dart';

final setupWizardNotifierProvider = NotifierProvider<SetupWizardNotifier, SetupWizardUiState>(SetupWizardNotifier.new);

class SetupWizardNotifier extends Notifier<SetupWizardUiState> {
  @override
  SetupWizardUiState build() {
    final serialService = ref.read(serialServiceProvider);
    final initialPorts = serialService.getAvailablePorts();

    return WizardActive(currentStep: 1, draft: WizardDraft.empty(), completedSteps: {}, availablePorts: initialPorts);
  }

  WizardActive? get _active => state is WizardActive ? state as WizardActive : null;

  // ── Adım 1: Kabin tipi ──────────────────────────────────────────

  /// [SWREQ-SETUP-UI-003]
  void selectCabinetType(CabinType type) {
    final current = _active;
    if (current == null) return;

    MedLogger.info(
      unit: 'SW-UNIT-SETUP',
      swreq: 'SWREQ-SETUP-UI-003',
      message: 'Kabin tipi seçildi',
      context: {'type': type.name},
    );

    state = current.copyWith(draft: current.draft.copyWith(cabinType: type));
  }

  // ── Adım 2: Temel bilgiler ──────────────────────────────────────

  /// [SWREQ-SETUP-UI-004]
  void updateBasicInfo(WizardBasicInfo info) {
    final current = _active;
    if (current == null) return;

    state = current.copyWith(draft: current.draft.copyWith(basicInfo: info));
  }

  // ── Adım 3: Hizmet kapsamı ──────────────────────────────────────

  /// [SWREQ-SETUP-UI-008]
  Future<void> loadStations() async {
    final current = _active;
    if (current == null) return;

    MedLogger.info(unit: 'SW-UNIT-SETUP', swreq: 'SWREQ-SETUP-UI-008', message: 'İstasyon listesi yükleniyor');

    state = current.copyWith(stationsLoadState: StationsLoadState.loading);

    final result = await ref.read(getStationsUseCaseProvider).call(GetStationsParams());

    final active = _active;
    if (active == null) return;

    result.when(
      ok: (response) {
        final stations = response.data ?? [];
        MedLogger.info(
          unit: 'SW-UNIT-SETUP',
          swreq: 'SWREQ-SETUP-UI-008',
          message: 'İstasyon listesi yüklendi',
          context: {'count': stations.length},
        );
        state = active.copyWith(stationsLoadState: StationsLoadState.loaded, stations: stations);
      },
      error: (error) {
        MedLogger.error(
          unit: 'SW-UNIT-SETUP',
          swreq: 'SWREQ-SETUP-UI-008',
          message: 'İstasyon listesi yüklenemedi',
          error: error,
        );
        state = active.copyWith(stationsLoadState: StationsLoadState.error, stationsError: error.message);
      },
    );
  }

  /// [SWREQ-SETUP-UI-008]
  /// İki kabin tipinde de çağrılır.
  /// Standart: StandartScope kaydedilir, servis yüklenmez.
  /// Mobil: servis detayları yüklenir, MobileScope güncellenir.
  Future<void> onStationSelected(Station station) async {
    final current = _active;
    if (current == null) return;

    final stationId = station.id;
    if (stationId == null) return;

    final isMobile = current.draft.cabinType == CabinType.mobile;

    // Standart kabin: direkt scope kaydet, servis yüklemeye gerek yok
    if (!isMobile) {
      state = current.copyWith(draft: current.draft.copyWith(serviceScope: StandartScope(station)));
      return;
    }

    // Mobil kabin: önce scope'u kaydet, ardından servis detaylarını yükle
    state = current.copyWith(
      draft: current.draft.copyWith(
        serviceScope: MobileScope(station, rooms: [], beds: []),
      ),
      servicesLoadState: ServicesLoadState.loading,
      services: [],
    );

    // 1. İstasyon detayını çek
    final stationResult = await ref.read(getStationUseCaseProvider).call(stationId);

    final active1 = _active;
    if (active1 == null) return;

    Station? stationDetail;

    stationResult.when(
      ok: (value) => stationDetail = value,
      error: (error) {
        MedLogger.error(
          unit: 'SW-UNIT-SETUP',
          swreq: 'SWREQ-SETUP-UI-008',
          message: 'İstasyon detayı yüklenemedi',
          error: error,
        );
        state = active1.copyWith(
          servicesLoadState: ServicesLoadState.error,
          servicesError: 'İstasyon detayları yüklenemedi.',
        );
      },
    );

    if (stationDetail == null) return;

    if (stationDetail?.type != StationType.patientBased) {
      state = active1.copyWith(servicesLoadState: ServicesLoadState.loaded, services: []);
      return;
    }

    // 2. Servis ID'lerini topla
    final serviceIds = [
      if (stationDetail!.service?.id != null) stationDetail!.service!.id!,
      ...stationDetail!.services.map((s) => s.id).whereType<int>(),
    ];

    if (serviceIds.isEmpty) {
      state = active1.copyWith(servicesLoadState: ServicesLoadState.loaded, services: []);
      return;
    }

    // 3. Servisleri paralel çek
    final serviceResults = await Future.wait(
      serviceIds.map((id) => ref.read(getServiceUseCaseProvider).call(id)),
      eagerError: false,
    );

    final active2 = _active;
    if (active2 == null) return;

    final loaded = <HospitalService>[];
    for (final result in serviceResults) {
      result.when(
        ok: (service) {
          if (service != null) loaded.add(service);
        },
        error: (error) {
          MedLogger.error(
            unit: 'SW-UNIT-SETUP',
            swreq: 'SWREQ-SETUP-UI-008',
            message: 'Servis detayı yüklenemedi',
            error: error,
          );
        },
      );
    }

    if (loaded.isEmpty) {
      state = active2.copyWith(
        servicesLoadState: ServicesLoadState.error,
        servicesError: 'Servis detayları yüklenemedi.',
      );
      return;
    }

    MedLogger.info(
      unit: 'SW-UNIT-SETUP',
      swreq: 'SWREQ-SETUP-UI-008',
      message: 'Servis detayları yüklendi',
      context: {'count': loaded.length},
    );

    state = active2.copyWith(servicesLoadState: ServicesLoadState.loaded, services: loaded);
  }

  /// [SWREQ-SETUP-UI-005]
  /// Sadece mobil kabinde oda/yatak seçimi güncellemesi için kullanılır.
  void updateServiceScope(StationScope scope) {
    final current = _active;
    if (current == null) return;

    state = current.copyWith(draft: current.draft.copyWith(serviceScope: scope));
  }

  /// [SWREQ-RFID-004]
  Future<void> testRfidConnection() async {
    final current = _active;
    if (current == null) return;

    final basicInfo = current.draft.basicInfo;
    final rfidIp = basicInfo?.rfidIpAddress;
    final rfidPort = int.tryParse(basicInfo?.rfidPort ?? '');

    if (rfidIp == null || rfidIp.isEmpty || rfidPort == null) return;

    state = current.copyWith(rfidTestState: RfidTestState.testing, rfidReaderInfo: null, rfidTestError: null);

    final result = await ref.read(testRfidConnectionUseCaseProvider).call(ip: rfidIp, port: rfidPort);

    final active = _active;
    if (active == null) return;

    result.when(
      ok: (info) {
        MedLogger.info(
          unit: 'SW-UNIT-SETUP',
          swreq: 'SWREQ-RFID-004',
          message: 'RFID test başarılı',
          context: {'fw': info.firmwareVersion, 'power': info.currentPower},
        );
        state = active.copyWith(rfidTestState: RfidTestState.success, rfidReaderInfo: info);
      },
      error: (error) {
        MedLogger.error(unit: 'SW-UNIT-SETUP', swreq: 'SWREQ-RFID-004', message: 'RFID test başarısız', error: error);
        state = active.copyWith(rfidTestState: RfidTestState.failure, rfidTestError: error.message);
      },
    );
  }

  /// [SWREQ-SETUP-UI-016]
  Future<void> testCabinConnection() async {
    final current = _active;
    if (current == null) return;

    final port = current.draft.basicInfo?.comPort;
    if (port == null || port.isEmpty) return;

    state = current.copyWith(cabinCardTestState: CabinCardTestState.testing, cabinCardTestError: null);

    final result = await ref.read(testCabinConnectionUseCaseProvider).call(port);

    final active = _active;
    if (active == null) return;

    result.when(
      ok: (_) {
        MedLogger.info(
          unit: 'SW-UNIT-SETUP',
          swreq: 'SWREQ-SETUP-UI-016',
          message: 'Kabin kartı bağlantı testi başarılı',
          context: {'port': port},
        );
        state = active.copyWith(cabinCardTestState: CabinCardTestState.success);
      },
      error: (error) {
        MedLogger.error(
          unit: 'SW-UNIT-SETUP',
          swreq: 'SWREQ-SETUP-UI-016',
          message: 'Kabin kartı bağlantı testi başarısız',
          error: error,
        );
        state = active.copyWith(cabinCardTestState: CabinCardTestState.failure, cabinCardTestError: error.message);
      },
    );
  }

  // ── Adım 4: Çekmece yapısı ──────────────────────────────────────

  /// [SWREQ-SETUP-UI-007]
  Future<void> scanDevice() async {
    final current = _active;
    if (current == null) return;

    final port = current.draft.basicInfo?.comPort;
    if (port == null || port.isEmpty) return;

    MedLogger.info(
      unit: 'SW-UNIT-SETUP',
      swreq: 'SWREQ-SETUP-UI-007',
      message: 'Cihaz taraması başlatıldı',
      context: {'port': port},
    );

    state = current.copyWith(
      scanState: DrawerScanState.scanning,
      scanLogs: [],
      draft: current.draft.copyWith(scannedLayout: null),
    );

    void addLog(ScanLogEntry entry) {
      final a = _active;
      if (a == null) return;
      state = a.copyWith(scanLogs: [...a.scanLogs, entry]);
    }

    void updateLastLog(ScanLogEntry Function(ScanLogEntry) updater) {
      final a = _active;
      if (a == null) return;
      if (a.scanLogs.isEmpty) return;
      final updated = [...a.scanLogs];
      updated[updated.length - 1] = updater(updated.last);
      state = a.copyWith(scanLogs: updated);
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
      cabinType: current.draft.cabinType ?? CabinType.master,
      onStatusChanged: onStatus,
    );

    final active = _active;
    if (active == null) return;

    result.when(
      ok: (layout) {
        MedLogger.info(
          unit: 'SW-UNIT-SETUP',
          swreq: 'SWREQ-SETUP-UI-007',
          message: 'Tarama tamamlandı',
          context: {'drawerCount': layout.length},
        );
        state = active.copyWith(
          scanState: DrawerScanState.found,
          draft: active.draft.copyWith(scannedLayout: layout),
        );
      },
      error: (error) {
        MedLogger.error(unit: 'SW-UNIT-SETUP', swreq: 'SWREQ-SETUP-UI-007', message: 'Tarama hatası', error: error);
        state = active.copyWith(scanState: DrawerScanState.error);
      },
    );
  }

  /// Tarama sonucunu sıfırla
  void resetScan() {
    final current = _active;
    if (current == null) return;

    state = current.copyWith(
      scanState: DrawerScanState.idle,
      scanLogs: [],
      draft: current.draft.copyWith(scannedLayout: null),
    );
  }

  /// [SWREQ-SETUP-UI-012]
  void updateDrawerCount(int count) {
    final current = _active;
    if (current == null) return;

    final layout = (current.draft.mobileLayout ?? WizardMobileLayout.defaultLayout()).withDrawerCount(count);

    state = current.copyWith(draft: current.draft.copyWith(mobileLayout: layout));
  }

  /// [SWREQ-SETUP-UI-013]
  void updateDrawerConfig(int drawerIndex, List<int> rowColumns) {
    final current = _active;
    if (current == null) return;

    final layout = (current.draft.mobileLayout ?? WizardMobileLayout.defaultLayout()).withDrawerConfig(
      drawerIndex,
      rowColumns,
    );

    state = current.copyWith(draft: current.draft.copyWith(mobileLayout: layout));
  }

  /// [SWREQ-SETUP-UI-015]
  void toggleSameConfig({required bool value}) {
    final current = _active;
    if (current == null) return;

    final layout = (current.draft.mobileLayout ?? WizardMobileLayout.defaultLayout()).withSameConfig(value);

    state = current.copyWith(draft: current.draft.copyWith(mobileLayout: layout));
  }

  // ── Adım geçişleri ───────────────────────────────────────────────

  void goToStep(int step) {
    final current = _active;
    if (current == null) return;
    if (step < 1 || step > 5) return;

    final completed = Set<int>.from(current.completedSteps);
    if (step > current.currentStep) completed.add(current.currentStep);

    state = current.copyWith(currentStep: step, completedSteps: completed);

    if (step == 3) loadStations();
  }

  void nextStep() {
    final current = _active;
    if (current == null) return;
    if (current.currentStep < 5) goToStep(current.currentStep + 1);
  }

  void previousStep() {
    final current = _active;
    if (current == null) return;
    if (current.currentStep > 1) {
      state = current.copyWith(currentStep: current.currentStep - 1);
    }
  }

  /// [SWREQ-SETUP-UC-001]
  Future<void> finish() async {
    final current = _active;
    if (current == null) return;
    if (!current.draft.isComplete) return;

    final config = current.draft.toConfig();

    MedLogger.info(
      unit: 'SW-UNIT-SETUP',
      swreq: 'SWREQ-SETUP-UC-001',
      message: 'Kabin kurulumu kaydediliyor',
      context: {'cabinName': config.basicInfo.cabinName, 'type': config.cabinType.name},
    );

    state = WizardSaving(draft: current.draft);

    final result = await ref.read(finishCabinSetupUseCaseProvider).call(config);

    result.when(
      ok: (cabinId) {
        MedLogger.info(
          unit: 'SW-UNIT-SETUP',
          swreq: 'SWREQ-SETUP-UC-001',
          message: 'Kabin kurulumu tamamlandı',
          context: {'cabinId': cabinId},
        );
        // [SWREQ-CORE-003] Fire & forget
        appSettingsCache.markSetupComplete(deviceMode: config.cabinType.name);
        state = WizardSaved(cabinId: cabinId, cabinName: config.basicInfo.cabinName);
      },
      error: (error) {
        MedLogger.error(
          unit: 'SW-UNIT-SETUP',
          swreq: 'SWREQ-SETUP-UC-001',
          message: 'Kabin kurulum hatası',
          error: error,
        );
        state = WizardSaveError(message: error.message, draft: current.draft);
      },
    );
  }

  /// Kayıt hatası sonrası wizard'a geri dön
  void retryFromError() {
    if (state case WizardSaveError(:final draft)) {
      state = WizardActive(currentStep: 5, draft: draft, completedSteps: const {1, 2, 3, 4}, availablePorts: []);
    }
  }
}
