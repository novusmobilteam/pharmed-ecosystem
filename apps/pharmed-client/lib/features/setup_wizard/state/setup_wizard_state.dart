// [SWREQ-SETUP-UI-001] [IEC 62304 §5.5]
// Setup Wizard ana state — sadece navigasyon ve kayıt durumu.
// Her adımın detay state'i kendi notifier'ında.
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

sealed class SetupWizardState {
  const SetupWizardState();
}

/// [SWREQ-SETUP-RESTORE-003] Sihirbaz açılmadan önce bu cihazın MAC adresine
/// kayıtlı bir kurulum olup olmadığı kontrol ediliyor.
final class WizardCheckingInstallation extends SetupWizardState {
  const WizardCheckingInstallation();
}

/// [SWREQ-SETUP-RESTORE-003] Kayıtlı kurulum bulundu — kullanıcı geri yüklemeyi
/// ya da yeni kurulumu seçer.
final class WizardInstallationFound extends SetupWizardState {
  const WizardInstallationFound({required this.installation, this.isRestoring = false});

  final StationInstallation installation;
  final bool isRestoring;
}

/// [SWREQ-SETUP-RESTORE-003] Kayıtlı kurulum kontrol edilemedi.
final class WizardInstallationCheckError extends SetupWizardState {
  const WizardInstallationCheckError({required this.message});

  final String message;
}

/// Wizard aktif — kullanıcı adımları dolduruyor
final class WizardActive extends SetupWizardState {
  const WizardActive({required this.currentStep, required this.completedSteps});

  final int currentStep; // 1–5
  final Set<int> completedSteps;

  WizardActive copyWith({int? currentStep, Set<int>? completedSteps}) {
    return WizardActive(
      currentStep: currentStep ?? this.currentStep,
      completedSteps: completedSteps ?? this.completedSteps,
    );
  }
}

/// Kayıt işlemi devam ediyor
final class WizardSaving extends SetupWizardState {
  const WizardSaving({required this.currentStep});

  final int currentStep;
}

/// Kayıt başarılı
final class WizardSaved extends SetupWizardState {
  const WizardSaved({required this.cabinId, required this.cabinName});

  final int cabinId;
  final String cabinName;
}

/// Kayıt hatası
final class WizardSaveError extends SetupWizardState {
  const WizardSaveError({required this.message, required this.currentStep});

  final String message;
  final int currentStep;
}
