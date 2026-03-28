// lib/features/setup_wizard/presentation/notifier/setup_wizard_notifier.dart
//
// [SWREQ-SETUP-UI-002] [IEC 62304 §5.5]
// Setup Wizard state yöneticisi.
// Her adımın verisini biriktir, son adımda kaydet.
// Sınıf: Class B

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import '../../../../core/enums/cabinet_type.dart';
import '../../../../core/hardware/serial_communication/i_serial_communication_service.dart';
import '../../../../core/hardware/serial_communication/serial_communication_service.dart';
import '../../domain/model/cabin_setup_config.dart';
import '../../domain/model/wizard_draft.dart';
import '../../domain/usecase/save_cabin_config_usecase.dart';
import '../state/setup_wizard_ui_state.dart';
import '../../../../core/di/datasource_injector.dart';
import '../../../../core/cache/app_settings_cache.dart';

final setupWizardNotifierProvider = NotifierProvider<SetupWizardNotifier, SetupWizardUiState>(SetupWizardNotifier.new);

// ─────────────────────────────────────────────────────────────────
// SetupWizardNotifier
// ─────────────────────────────────────────────────────────────────

class SetupWizardNotifier extends Notifier<SetupWizardUiState> {
  late final SaveCabinConfigUseCase _saveUseCase;
  late final ScanDeviceDrawerConfigUseCase _scanUseCase;
  late final ISerialCommunicationService _serialService;

  @override
  SetupWizardUiState build() {
    final repo = DI.setupWizardRepository();
    _saveUseCase = SaveCabinConfigUseCase(repository: repo);
    _scanUseCase = ScanDeviceDrawerConfigUseCase(repository: repo);
    _serialService = ref.watch(serialServiceProvider);

    final initialPorts = _serialService.getAvailablePorts();

    return WizardActive(currentStep: 1, draft: WizardDraft.empty(), completedSteps: {}, availablePorts: initialPorts);
  }

  // ── Adım 1: Kabin tipi ──────────────────────────────────────────

  /// [SWREQ-SETUP-UI-003]
  void selectCabinetType(CabinetType type) {
    final current = _active;
    if (current == null) return;

    MedLogger.info(
      unit: 'SW-UNIT-SETUP',
      swreq: 'SWREQ-SETUP-UI-003',
      message: 'Kabin tipi seçildi',
      context: {'type': type.name},
    );

    // Tip değişince scope ve çekmece sıfırlanır
    final resetDraft = current.draft.copyWith(cabinetType: type);

    state = current.copyWith(
      draft: resetDraft,
      // Scope/drawer verilerini sıfırla
    );
  }

  // ── Adım 2: Temel bilgiler ──────────────────────────────────────

  /// [SWREQ-SETUP-UI-004]
  void updateBasicInfo(WizardBasicInfo info) {
    final current = _active;
    if (current == null) return;

    state = current.copyWith(draft: current.draft.copyWith(basicInfo: info));
  }

  // ── Adım 3: Hizmet kapsamı ──────────────────────────────────────

  /// [SWREQ-SETUP-UI-005]
  void updateServiceScope(ServiceScope scope) {
    final current = _active;
    if (current == null) return;

    state = current.copyWith(draft: current.draft.copyWith(serviceScope: scope));
  }

  // ── Adım 4: Çekmece yapısı ──────────────────────────────────────

  /// [SWREQ-SETUP-UI-006]
  void updateDrawerConfig(DrawerConfig config) {
    final current = _active;
    if (current == null) return;

    state = current.copyWith(draft: current.draft.copyWith(drawerConfig: config));
  }

  /// [SWREQ-SETUP-UI-007] Standart kabin cihaz taraması
  Future<void> scanDevice() async {
    final current = _active;
    if (current == null) return;
    final ip = current.draft.basicInfo?.ipAddress;
    if (ip == null || ip.isEmpty) return;

    MedLogger.info(
      unit: 'SW-UNIT-SETUP',
      swreq: 'SWREQ-SETUP-UI-007',
      message: 'Cihaz taraması başlatıldı',
      context: {'ip': ip},
    );

    state = current.copyWith(scanState: DrawerScanState.scanning);

    final result = await _scanUseCase(ip);

    result.when(
      ok: (config) {
        MedLogger.info(
          unit: 'SW-UNIT-SETUP',
          swreq: 'SWREQ-SETUP-UI-007',
          message: 'Cihaz taraması tamamlandı',
          context: {'sections': config.sections, 'type': config.drawerType.name},
        );
        final a = _active;
        if (a == null) return;
        state = a.copyWith(
          draft: a.draft.copyWith(drawerConfig: config),
          scanState: DrawerScanState.found,
        );
      },
      error: (error) {
        MedLogger.error(
          unit: 'SW-UNIT-SETUP',
          swreq: 'SWREQ-SETUP-UI-007',
          message: 'Cihaz tarama hatası',
          error: error,
        );
        final a = _active;
        if (a == null) return;
        state = a.copyWith(scanState: DrawerScanState.error);
      },
    );
  }

  // ── Adım geçişleri ───────────────────────────────────────────────

  /// Sonraki adıma geç. Mevcut adımı tamamlandı olarak işaretle.
  void goToStep(int step) {
    final current = _active;
    if (current == null) return;
    if (step < 1 || step > 5) return;

    final completed = Set<int>.from(current.completedSteps);
    if (step > current.currentStep) {
      completed.add(current.currentStep);
    }

    state = current.copyWith(currentStep: step, completedSteps: completed);
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

  /// [SWREQ-SETUP-UC-001] Wizard tamamla → kaydet
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

    final result = await _saveUseCase(config);

    result.when(
      ok: (cabinId) {
        MedLogger.info(
          unit: 'SW-UNIT-SETUP',
          swreq: 'SWREQ-SETUP-UC-001',
          message: 'Kabin başarıyla kaydedildi',
          context: {'cabinId': cabinId},
        );

        // [SWREQ-CORE-003] Cihaz modunu cache'e yaz (fire & forget).
        // Dashboard'a geçiş, kullanıcı "Dashboard'a Git" butonuna
        // bastığında appSetupStatusProvider.markComplete() ile tetiklenir.
        appSettingsCache.markSetupComplete(deviceMode: config.cabinetType.name);

        state = WizardSaved(cabinId: cabinId, cabinName: config.basicInfo.cabinName);
      },
      error: (error) {
        MedLogger.error(
          unit: 'SW-UNIT-SETUP',
          swreq: 'SWREQ-SETUP-UC-001',
          message: 'Kabin kayıt hatası',
          error: error,
        );
        state = WizardSaveError(message: error.toString().replaceFirst('Exception: ', ''), draft: current.draft);
      },
    );
  }

  /// Kayıt hatası sonrası wizard'a geri dön
  void retryFromError() {
    if (state case WizardSaveError(:final draft)) {
      state = WizardActive(currentStep: 5, draft: draft, completedSteps: const {1, 2, 3, 4});
    }
  }

  // ── Yardımcılar ──────────────────────────────────────────────────

  WizardActive? get _active => state is WizardActive ? state as WizardActive : null;
}
