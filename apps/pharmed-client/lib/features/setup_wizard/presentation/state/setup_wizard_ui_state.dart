// lib/features/setup_wizard/presentation/state/setup_wizard_ui_state.dart
//
// [SWREQ-SETUP-UI-001] [IEC 62304 §5.5]
// Setup Wizard UiState — 5 adımlı ilk kurulum akışı.
// Sınıf: Class B

import '../../domain/model/wizard_draft.dart';

// ─────────────────────────────────────────────────────────────────
// SetupWizardUiState
// ─────────────────────────────────────────────────────────────────

sealed class SetupWizardUiState {
  const SetupWizardUiState();
}

/// Wizard aktif — kullanıcı adımları dolduryor
final class WizardActive extends SetupWizardUiState {
  const WizardActive({
    required this.currentStep,
    required this.draft,
    required this.completedSteps,
    this.scanState = DrawerScanState.idle,
    this.availablePorts = const [],
  });

  final int currentStep; // 1–5
  final WizardDraft draft;
  final Set<int> completedSteps; // Tamamlanan adımlar (yeşil)
  final DrawerScanState scanState; // Adım 4 tarama durumu
  final List<String> availablePorts;

  WizardActive copyWith({
    int? currentStep,
    WizardDraft? draft,
    Set<int>? completedSteps,
    DrawerScanState? scanState,
    List<String>? availablePorts,
  }) {
    return WizardActive(
      currentStep: currentStep ?? this.currentStep,
      draft: draft ?? this.draft,
      completedSteps: completedSteps ?? this.completedSteps,
      scanState: scanState ?? this.scanState,
      availablePorts: availablePorts ?? this.availablePorts,
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
// Çekmece tarama alt-durumu (Adım 4 — Standart kabin)
// ─────────────────────────────────────────────────────────────────

enum DrawerScanState {
  idle, // Henüz başlamadı
  scanning, // Taranıyor (animasyon gösterilir)
  found, // Cihaz bulundu, yapı okundu
  error, // Tarama başarısız
}
