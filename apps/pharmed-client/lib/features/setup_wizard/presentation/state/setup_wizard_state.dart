// [SWREQ-SETUP-UI-001] [IEC 62304 §5.5]
// Setup Wizard ana state — sadece navigasyon ve kayıt durumu.
// Her adımın detay state'i kendi notifier'ında.
// Sınıf: Class B

sealed class SetupWizardState {
  const SetupWizardState();
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
