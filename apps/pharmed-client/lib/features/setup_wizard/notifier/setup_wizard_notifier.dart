// // [SWREQ-SETUP-UI-002] [IEC 62304 §5.5]
// // Setup Wizard ana state yöneticisi.
// //
// // SORUMLULUK:
// //   - Adım navigasyonu (currentStep, completedSteps)
// //   - finish() — tüm step notifier'lardan veri toplayıp kayıt
// //
// // HER ADIMIN KENDİ NOTIFIER'I VAR:
// //   Step1Notifier  → cabinType
// //   Step2Notifier  → basicInfo, rfid/kart testi
// //   Step3Notifier  → istasyon, servis, oda seçimi
// //   Step4MasterNotifier → cihaz taraması
// //   Step4MobileNotifier → çekmece config + port tarama
// //
// // Sınıf: Class B

// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:pharmed_core/pharmed_core.dart';
// import 'package:pharmed_ui/pharmed_ui.dart';
// import 'package:pharmed_utils/pharmed_utils.dart';

// import '../../../core/cache/app_settings_cache.dart';
// import '../../../core/providers/providers.dart';
// import '../setup_wizard.dart';

// final setupWizardNotifierProvider = NotifierProvider<SetupWizardNotifier, SetupWizardState>(SetupWizardNotifier.new);

// class SetupWizardNotifier extends Notifier<SetupWizardState> {
//   String? macAddress;

//   @override
//   SetupWizardState build() {
//     init();
//     return WizardActive(currentStep: 1, completedSteps: {});
//   }

//   Future<void> init() async {
//     macAddress = await DeviceInfo.getMacAddress();
//   }

//   WizardActive? get _active => state is WizardActive ? state as WizardActive : null;

//   void goToStep(int step) {
//     final current = _active;
//     if (current == null) return;
//     if (step < 1 || step > 5) return;

//     final completed = Set<int>.from(current.completedSteps);
//     if (step > current.currentStep) completed.add(current.currentStep);

//     state = current.copyWith(currentStep: step, completedSteps: completed);
//   }

//   void nextStep() {
//     final current = _active;
//     if (current == null) return;
//     if (current.currentStep < 5) goToStep(current.currentStep + 1);
//   }

//   void previousStep() {
//     final current = _active;
//     if (current == null) return;
//     if (current.currentStep > 1) {
//       state = current.copyWith(currentStep: current.currentStep - 1);
//     }
//   }

//   /// [SWREQ-SETUP-UC-001]
//   /// Tüm step notifier'lardan veri toplayıp CabinSetupConfig oluşturur
//   /// ve kaydeder.
//   Future<void> finish() async {
//     final current = _active;
//     if (current == null) return;

//     // Her adımdan veri topla
//     final cabinType = ref.read(step1NotifierProvider);
//     final step2 = ref.read(step2NotifierProvider);
//     final step3 = ref.read(step3NotifierProvider);
//     final step4Mobile = ref.read(step4MobileNotifierProvider);
//     final step4Master = ref.read(step4MasterNotifierProvider);

//     // Zorunlu alanları doğrula
//     if (cabinType == null || step2.basicInfo == null || step3.serviceScope == null) {
//       return;
//     }

//     final mobileLayout = cabinType == CabinType.mobile ? step4Mobile.mobileLayout : null;
//     final scannedLayout = cabinType == CabinType.master ? step4Master.scannedLayout : null;

//     if (cabinType == CabinType.mobile && mobileLayout == null) return;
//     if (cabinType == CabinType.master && (scannedLayout == null || scannedLayout.isEmpty)) return;

//     final config = CabinSetupConfig(
//       cabinType: cabinType,
//       basicInfo: step2.basicInfo!,
//       stationScope: step3.serviceScope!,
//       mobileLayout: mobileLayout,
//       scannedLayout: scannedLayout,
//     );

//     MedLogger.info(
//       unit: 'SW-UNIT-SETUP',
//       swreq: 'SWREQ-SETUP-UC-001',
//       message: 'Kabin kurulumu kaydediliyor',
//       context: {'cabinName': config.basicInfo.cabinName, 'type': config.cabinType.name},
//     );

//     state = WizardSaving(currentStep: current.currentStep);

//     final result = await ref.read(finishCabinSetupUseCaseProvider).call(config);

//     switch (result) {
//       case Ok(value: final cabinId):
//         MedLogger.info(
//           unit: 'SW-UNIT-SETUP',
//           swreq: 'SWREQ-SETUP-UC-001',
//           message: 'Kabin kurulumu tamamlandı',
//           context: {'cabinId': cabinId},
//         );
//         await appSettingsCache.markSetupComplete(deviceMode: config.cabinType.name);
//         await appSettingsCache.saveCurrentCabinId(cabinId);

//         final comPort = config.basicInfo.comPort;
//         if (comPort != null && comPort.isNotEmpty) {
//           await appSettingsCache.saveComPort(comPort);
//         }
//         ref.invalidate(cachedDeviceModeProvider);
//         ref.invalidate(deviceModeProvider);
//         state = WizardSaved(cabinId: cabinId, cabinName: config.basicInfo.cabinName);

//       case Error(error: final error):
//         MedLogger.error(
//           unit: 'SW-UNIT-SETUP',
//           swreq: 'SWREQ-SETUP-UC-001',
//           message: 'Kabin kurulum hatası',
//           error: error,
//         );
//         state = WizardSaveError(message: error.message, currentStep: current.currentStep);
//     }
//   }

//   void retryFromError() {
//     if (state case WizardSaveError(:final currentStep)) {
//       state = WizardActive(currentStep: currentStep, completedSteps: {1, 2, 3, 4});
//     }
//   }
// }
