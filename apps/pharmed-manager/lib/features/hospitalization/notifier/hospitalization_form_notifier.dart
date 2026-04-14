import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

class HospitalizationFormNotifier extends ChangeNotifier with ApiRequestMixin {
  final CreateHospitalizationUseCase _createHospitalizationUseCase;
  final UpdateHospitalizationUseCase _updateHospitalizationUseCase;

  HospitalizationFormNotifier({
    Patient? patient,
    Hospitalization? hospitalization,
    required CreateHospitalizationUseCase createHospitalizationUseCase,
    required UpdateHospitalizationUseCase updateHospitalizationUseCase,
  }) : _createHospitalizationUseCase = createHospitalizationUseCase,
       _updateHospitalizationUseCase = updateHospitalizationUseCase {
    _patient = patient;
    if (hospitalization == null) {
      _hospitalization = Hospitalization(patient: _patient, code: createRandomText(9), admissionDate: DateTime.now());
    } else {
      _hospitalization = hospitalization;
      // Düzenleme modu — mevcut servis/oda/yatak seçimlerini geri yükle
      if (hospitalization.physicalService != null) {
        _selectedService = hospitalization.physicalService;
        _selectedRoom = hospitalization.physicalService?.rooms.firstWhereOrNull((r) => r.id == hospitalization.roomId);
        if (_selectedRoom != null) {
          _selectedBed = _selectedRoom!.beds.firstWhereOrNull((b) => b.id == hospitalization.bedId);
        }
      }
    }
  }

  OperationKey submitOp = OperationKey.submit();

  Hospitalization? _hospitalization;
  Hospitalization? get hospitalization => _hospitalization;

  Patient? _patient;
  Patient? get patient => _patient;

  HospitalService? _selectedService;
  HospitalService? get selectedService => _selectedService;

  Room? _selectedRoom;
  Room? get selectedRoom => _selectedRoom;

  Bed? _selectedBed;
  Bed? get selectedBed => _selectedBed;

  /// Seçili servise ait odalar — servis seçilmemişse boş liste
  List<Room> get rooms => _selectedService?.rooms ?? [];

  /// Seçili odaya ait yataklar — oda seçilmemişse boş liste
  List<Bed> get beds => _selectedRoom?.beds ?? [];

  User? get doctor => _hospitalization?.doctor;
  bool get hasPatient => _patient != null;
  bool get isCreate => _hospitalization?.id == null;

  bool get isRoomEnabled => _selectedService != null;
  bool get isBedEnabled => _selectedRoom != null;

  Future<void> submit({Function(String? msg)? onFailed, Function(String? msg)? onSuccess}) async {
    await executeVoid(
      submitOp,
      operation: () async => isCreate
          ? await _createHospitalizationUseCase.call(_hospitalization!)
          : await _updateHospitalizationUseCase.call(_hospitalization!),
      onFailed: (error) => onFailed?.call(error.message),
      onSuccess: () => onSuccess?.call('İşleminiz başarıyla tamamlandı'),
    );
  }

  void selectPhysicalService(HospitalService? service) {
    _selectedService = service;
    _selectedRoom = null;
    _selectedBed = null;
    _hospitalization = _hospitalization?.copyWith(physicalService: service, roomId: null, bedId: null);
    notifyListeners();
  }

  void selectInpatientService(HospitalService? service) {
    _hospitalization = _hospitalization?.copyWith(inpatientService: service);
    notifyListeners();
  }

  void selectRoom(Room? room) {
    _selectedRoom = room;
    _selectedBed = null;
    _hospitalization = _hospitalization?.copyWith(roomId: room?.id, bedId: null);
    notifyListeners();
  }

  void selectBed(Bed? bed) {
    _selectedBed = bed;
    _hospitalization = _hospitalization?.copyWith(bedId: bed?.id);
    notifyListeners();
  }

  void selectDoctor(User? user) {
    _hospitalization = _hospitalization?.copyWith(doctor: user);
    notifyListeners();
  }

  void selectPatient(Patient? patient) {
    _hospitalization = _hospitalization?.copyWith(patient: patient);
    notifyListeners();
  }

  void updateAdmissionDate(DateTime? value) {
    _hospitalization = _hospitalization?.copyWith(admissionDate: value);
    notifyListeners();
  }

  void updateExitDate(DateTime? value) {
    _hospitalization = _hospitalization?.copyWith(exitDate: value);
    notifyListeners();
  }

  void updateDescription(String? value) {
    _hospitalization = _hospitalization?.copyWith(description: value);
    notifyListeners();
  }

  void toggleIsBaby() {
    _hospitalization = _hospitalization?.copyWith(isBaby: !(_hospitalization?.isBaby ?? false));
    notifyListeners();
  }
}
