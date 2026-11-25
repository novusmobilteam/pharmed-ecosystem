import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';

import '../../../core/cache/app_settings_cache.dart';
import '../../../core/providers/providers.dart';
import '../setup_wizard.dart';

final setupWizardNotifierProvider = NotifierProvider<SetupWizardNotifier, SetupWizardState>(SetupWizardNotifier.new);

class SetupWizardNotifier extends Notifier<SetupWizardState> {
  String? macAddress;

  @override
  SetupWizardState build() {
    init();
    return const WizardCheckingInstallation();
  }

  Future<void> init() async {
    macAddress = await DeviceInfo.getMacAddress();
    await checkInstallation();
  }

  // MARK: Kayıtlı kurulumu geri yükleme

  /// [SWREQ-SETUP-RESTORE-003]
  /// Yerel kurulum kaydı yokken çağrılır: cihazın MAC adresine kayıtlı istasyon
  /// ve kabin varsa kullanıcıya geri yüklemeyi önerir, yoksa sihirbazı açar.
  Future<void> checkInstallation() async {
    state = const WizardCheckingInstallation();

    final result = await ref.read(getStationInstallationUseCaseProvider).call();

    switch (result) {
      case Ok(value: final installation):
        if (installation.isRestorable) {
          MedLogger.info(
            unit: 'SW-UNIT-SETUP',
            swreq: 'SWREQ-SETUP-RESTORE-003',
            message: 'Bu cihaza kayıtlı kurulum bulundu',
            context: {
              'stationId': installation.station?.id,
              'cabinIds': installation.cabins.map((c) => c.cabin.id).toList(),
            },
          );
          state = WizardInstallationFound(installation: installation);
        } else {
          startNewSetup();
        }
      case Error(error: final error):
        state = WizardInstallationCheckError(message: error.message);
    }
  }

  /// [SWREQ-SETUP-RESTORE-004]
  /// Bulunan kurulumu yerel kayda yazar: kabin tipi, ana kabin (`no = a`),
  /// istasyon ve COM port. Çekmece tasarımı dashboard'da kabin ID'siyle çekilir.
  Future<void> restoreInstallation() async {
    final current = state;
    if (current is! WizardInstallationFound || current.isRestoring) return;

    final installation = current.installation;
    final primary = installation.primaryCabin?.cabin;
    final cabinId = primary?.id;
    final cabinType = primary?.type;
    if (primary == null || cabinId == null || cabinType == null) return;

    state = WizardInstallationFound(installation: installation, isRestoring: true);

    await appSettingsCache.markSetupComplete(deviceMode: cabinType.name);
    await appSettingsCache.saveCurrentCabinId(cabinId, stationId: installation.station?.id);
    final comPort = primary.comPort;
    if (comPort != null) await appSettingsCache.saveComPort(comPort.label);

    ref.invalidate(cachedDeviceModeProvider);
    ref.invalidate(deviceModeProvider);

    MedLogger.info(
      unit: 'SW-UNIT-SETUP',
      swreq: 'SWREQ-SETUP-RESTORE-004',
      message: 'Kayıtlı kurulum geri yüklendi',
      context: {'stationId': installation.station?.id, 'cabinId': cabinId, 'deviceMode': cabinType.name},
    );

    state = WizardSaved(cabinId: cabinId, cabinName: primary.name ?? '');
  }

  /// Kayıtlı kurulumu kullanmadan sihirbazı ilk adımdan açar.
  void startNewSetup() {
    state = WizardActive(currentStep: 1, completedSteps: {});
  }

  WizardActive? get _active => state is WizardActive ? state as WizardActive : null;

  void goToStep(int step) {
    final current = _active;
    if (current == null) return;
    if (step < 1 || step > 5) return;

    final completed = Set<int>.from(current.completedSteps);
    if (step > current.currentStep) completed.add(current.currentStep);

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

  /// [SWREQ-SETUP-UC-001]
  /// Tüm step notifier'lardan veri toplayıp CabinSetupConfig oluşturur
  /// ve kaydeder.
  Future<void> finish() async {
    final current = _active;
    if (current == null) return;

    // Her adımdan veri topla
    final cabinType = ref.read(step1NotifierProvider);
    final step2 = ref.read(step2NotifierProvider);
    final step3 = ref.read(step3NotifierProvider);
    final step4Mobile = ref.read(step4MobileNotifierProvider);
    final step4Master = ref.read(step4MasterNotifierProvider);

    // Zorunlu alanları doğrula
    if (cabinType == null || step2.basicInfo == null || step3.serviceScope == null) {
      return;
    }

    final mobileLayout = cabinType == CabinType.mobile ? step4Mobile.mobileLayout : null;
    final scannedLayout = cabinType == CabinType.master ? step4Master.scannedLayout : null;

    if (cabinType == CabinType.mobile && mobileLayout == null) return;
    if (cabinType == CabinType.master && (scannedLayout == null || scannedLayout.isEmpty)) return;

    final config = CabinSetupConfig(
      cabinType: cabinType,
      basicInfo: step2.basicInfo!,
      stationScope: step3.serviceScope!,
      mobileLayout: mobileLayout,
      scannedLayout: scannedLayout,
    );

    state = WizardSaving(currentStep: current.currentStep);

    final result = await ref.read(finishCabinSetupUseCaseProvider).call(config);

    switch (result) {
      case Ok(value: final cabinId):
        await appSettingsCache.markSetupComplete(deviceMode: config.cabinType.name);
        await appSettingsCache.saveCurrentCabinId(cabinId, stationId: config.stationScope.station.id);

        final comPort = config.basicInfo.comPort;
        if (comPort != null && comPort.isNotEmpty) {
          await appSettingsCache.saveComPort(comPort);
        }
        ref.invalidate(cachedDeviceModeProvider);
        ref.invalidate(deviceModeProvider);
        state = WizardSaved(cabinId: cabinId, cabinName: config.basicInfo.cabinName);

      case Error(error: final error):
        state = WizardSaveError(message: error.message, currentStep: current.currentStep);
    }
  }

  void retryFromError() {
    if (state case WizardSaveError(:final currentStep)) {
      state = WizardActive(currentStep: currentStep, completedSteps: {1, 2, 3, 4});
    }
  }
}
