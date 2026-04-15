// lib/features/assignment/presentation/state/patient_assignment_ui_state.dart
//
// [SWREQ-UI-CAB-006]
// PatientAssignmentView için sealed UI state.
// Sadece mobil kabinde kullanılır — DrawerGroup değil
// MobileSlotVisual + MobileCellCoord bazlıdır.
//
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

import '../../../../widgets/widgets.dart';

sealed class PatientAssignmentUiState {
  const PatientAssignmentUiState();
}

/// init() çağrılana kadar geçici state.
final class PatientAssignmentUninitialized extends PatientAssignmentUiState {
  const PatientAssignmentUninitialized();
}

/// Atamalar yükleniyor.
final class PatientAssignmentLoading extends PatientAssignmentUiState {
  const PatientAssignmentLoading({required this.slots});

  final List<MobileSlotVisual> slots;
}

/// Kabin verisi yüklendi, slot seçilmedi.
final class PatientAssignmentIdle extends PatientAssignmentUiState {
  const PatientAssignmentIdle({required this.slots});

  final List<MobileSlotVisual> slots;
}

/// Slot (çekmece) seçildi, hücre seçilmedi.
final class PatientAssignmentSlotSelected extends PatientAssignmentUiState {
  const PatientAssignmentSlotSelected({required this.slots, required this.selectedSlot});

  final List<MobileSlotVisual> slots;
  final MobileSlotVisual selectedSlot;

  int get selectedSlotId => selectedSlot.slotId;
}

/// Hücre seçildi — sağ panel aktif.
///
/// [selectedHospitalization] null → yatış henüz seçilmedi.
/// [isAssigned] true → bu hücrede daha önce atama yapılmış.
final class PatientAssignmentCellSelected extends PatientAssignmentUiState {
  const PatientAssignmentCellSelected({
    required this.slots,
    required this.selectedSlot,
    required this.selectedCell,
    this.selectedHospitalization,
    this.isAssigned = false,
  });

  final List<MobileSlotVisual> slots;
  final MobileSlotVisual selectedSlot;
  final MobileCellCoord selectedCell;
  final Hospitalization? selectedHospitalization;
  final bool isAssigned;

  int get selectedSlotId => selectedSlot.slotId;

  bool get canSave => selectedHospitalization != null;

  PatientAssignmentCellSelected copyWith({Hospitalization? selectedHospitalization, bool? isAssigned}) {
    return PatientAssignmentCellSelected(
      slots: slots,
      selectedSlot: selectedSlot,
      selectedCell: selectedCell,
      selectedHospitalization: selectedHospitalization ?? this.selectedHospitalization,
      isAssigned: isAssigned ?? this.isAssigned,
    );
  }
}

/// Kayıt / silme işlemi devam ediyor.
final class PatientAssignmentSaving extends PatientAssignmentUiState {
  const PatientAssignmentSaving({required this.slots, required this.selectedSlot});

  final List<MobileSlotVisual> slots;
  final MobileSlotVisual selectedSlot;

  int get selectedSlotId => selectedSlot.slotId;
}

/// İşlem hatası — previousState'e dönülür.
final class PatientAssignmentError extends PatientAssignmentUiState {
  const PatientAssignmentError({required this.message, required this.previousState});

  final String message;
  final PatientAssignmentUiState previousState;
}
