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

    state = current.copyWith(draft: current.draft.copyWith(cabinetType: type));
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
  /// Adım 3'e geçildiğinde otomatik çağrılır.
  /// Standart kabinde istasyon listesini yükler, mobil kabinde no-op.
  Future<void> loadStations() async {
    final current = _active;
    if (current == null) return;

    // Mobil kabinde istasyon yüklenmez
    if (current.draft.cabinetType == CabinType.mobile) return;

    // Zaten yüklendiyse tekrar istek atma
    //if (current.stationsLoadState == StationsLoadState.loaded) return;

    MedLogger.info(unit: 'SW-UNIT-SETUP', swreq: 'SWREQ-SETUP-UI-008', message: 'İstasyon listesi yükleniyor');

    state = current.copyWith(stationsLoadState: StationsLoadState.loading);

    final useCase = ref.read(getStationsUseCaseProvider);
    final result = await useCase.call(GetStationsParams());

    final active = _active;
    if (active == null) return;

    result.when(
      ok: (response) {
        print('Notifier${response.data}');
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

  /// [SWREQ-SETUP-UI-005]
  void updateServiceScope(ServiceScope scope) {
    final current = _active;
    if (current == null) return;

    state = current.copyWith(draft: current.draft.copyWith(serviceScope: scope));
  }

  // ── Adım 4: Çekmece yapısı ──────────────────────────────────────

  /// [SWREQ-SETUP-UI-007] Standart kabin — adım adım cihaz taraması.
  /// ScanCabinUseCase'den gelen ScanStatus değerleri log satırlarına dönüştürülür.
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

    // Taramayı sıfırla, scanning moduna geç
    state = current.copyWith(
      scanState: DrawerScanState.scanning,
      scanLogs: [],
      draft: current.draft.copyWith(scannedLayout: null),
    );

    // ── Yardımcı: log satırı ekle ──────────────────────────────
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

    // ── ScanStatus → ScanLogEntry dönüşümü ─────────────────────
    void onStatus(ScanStatus status, {String? detail}) {
      switch (status) {
        // Pending satırı ekle
        case ScanStatus.connecting:
          addLog(ScanLogEntry.pending('Seri porta bağlanılıyor…'));
        case ScanStatus.fetchingMetadata:
          addLog(ScanLogEntry.pending('Çekmece tanımları yükleniyor…'));
        case ScanStatus.searchingManager:
          addLog(ScanLogEntry.pending('Yönetim kartı aranıyor…'));
        case ScanStatus.scanningCards:
          addLog(ScanLogEntry.pending('Kontrol kartları taranıyor…'));

        // Önceki satırı ok'a çevir
        case ScanStatus.connected:
          updateLastLog((e) => e.asOk(detail: detail));
        case ScanStatus.metadataReady:
          updateLastLog((e) => e.asOk(detail: detail));
        case ScanStatus.managerFound:
          updateLastLog((e) => e.asOk(detail: detail));

        // Çekmece bulundu — yeni ok satırı ekle
        case ScanStatus.drawerFound:
          addLog(ScanLogEntry(message: detail ?? 'Çekmece bulundu', status: ScanLogStatus.ok));

        // Hata — önceki satırı error'a çevir
        case ScanStatus.connectionFailed:
        case ScanStatus.metadataFailed:
        case ScanStatus.managerNotFound:
        case ScanStatus.noCardsFound:
          updateLastLog((e) => e.asError(detail: detail));

        // completed — result.when içinde hallediliyor
        case ScanStatus.completed:
          break;
      }
    }

    final scanUseCase = ref.read(scanCabinUseCaseProvider);

    final result = await scanUseCase(
      portName: port,
      cabinType: current.draft.cabinetType ?? CabinType.master,
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

  /// Tarama sonucunu sıfırla — tekrar tara
  void resetScan() {
    final current = _active;
    if (current == null) return;

    state = current.copyWith(
      scanState: DrawerScanState.idle,
      scanLogs: [],
      draft: current.draft.copyWith(scannedLayout: null),
    );
  }

  /// [SWREQ-SETUP-UI-012] Mobil kabin — çekmece sayısını güncelle
  void updateDrawerCount(int count) {
    final current = _active;
    if (current == null) return;

    final layout = (current.draft.mobileLayout ?? WizardMobileLayout.defaultLayout()).withDrawerCount(count);

    state = current.copyWith(draft: current.draft.copyWith(mobileLayout: layout));
  }

  /// [SWREQ-SETUP-UI-013] Mobil kabin — tek çekmece konfigürasyonunu güncelle
  void updateDrawerConfig(int drawerIndex, {int? rows, int? columns}) {
    final current = _active;
    if (current == null) return;

    final layout = (current.draft.mobileLayout ?? WizardMobileLayout.defaultLayout()).withDrawerConfig(
      drawerIndex,
      rows: rows,
      columns: columns,
    );

    state = current.copyWith(draft: current.draft.copyWith(mobileLayout: layout));
  }

  /// [SWREQ-SETUP-UI-015] Mobil kabin — tüm çekmeceler aynı yapıda toggle
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
    if (step > current.currentStep) {
      completed.add(current.currentStep);
    }

    state = current.copyWith(currentStep: step, completedSteps: completed);

    // Adım 3'e geçilince standart kabinde istasyonları yükle
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

  // ── Tamamlama ────────────────────────────────────────────────────

  /// [SWREQ-SETUP-UC-001] Wizard tamamla → kaydet.
  Future<void> finish() async {
    final current = _active;
    if (current == null) return;
    if (!current.draft.isComplete) return;

    final config = current.draft.toConfig();

    MedLogger.info(
      unit: 'SW-UNIT-SETUP',
      swreq: 'SWREQ-SETUP-UC-001',
      message: 'Kabin kurulumu kaydediliyor',
      context: {'cabinName': config.basicInfo.cabinName, 'type': config.cabinetType.name},
    );

    state = WizardSaving(draft: current.draft);

    final result = await ref.read(finishCabinSetupUseCaseProvider)(config);

    result.when(
      ok: (cabinId) {
        MedLogger.info(
          unit: 'SW-UNIT-SETUP',
          swreq: 'SWREQ-SETUP-UC-001',
          message: 'Kabin kurulumu tamamlandı',
          context: {'cabinId': cabinId},
        );

        // [SWREQ-CORE-003] Fire & forget — await etme
        appSettingsCache.markSetupComplete(deviceMode: config.cabinetType.name);

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

  WizardActive? get _active => state is WizardActive ? state as WizardActive : null;
}
