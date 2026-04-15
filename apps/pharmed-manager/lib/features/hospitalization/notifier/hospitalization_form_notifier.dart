import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

class HospitalizationFormNotifier extends ChangeNotifier with ApiRequestMixin {
  final CreateHospitalizationUseCase _createHospitalizationUseCase;
  final UpdateHospitalizationUseCase _updateHospitalizationUseCase;
  final GetRoomsUseCase _getRoomsUseCase;
  final GetBedsUseCase _getBedsUseCase;

  HospitalizationFormNotifier({
    Patient? patient,
    Hospitalization? hospitalization,
    required GetRoomsUseCase getRoomsUseCase,
    required GetBedsUseCase getBedsUseCase,
    required CreateHospitalizationUseCase createHospitalizationUseCase,
    required UpdateHospitalizationUseCase updateHospitalizationUseCase,
  }) : _createHospitalizationUseCase = createHospitalizationUseCase,
       _updateHospitalizationUseCase = updateHospitalizationUseCase,
       _getRoomsUseCase = getRoomsUseCase,
       _getBedsUseCase = getBedsUseCase {
    _patient = patient;
    if (hospitalization == null) {
      _hospitalization = Hospitalization(patient: _patient, code: createRandomText(9), admissionDate: DateTime.now());
    } else {
      _hospitalization = hospitalization;
      // Düzenleme modu — servis seçiliyse oda/yatak listelerini yükle ve restore et
      if (hospitalization.physicalService?.id != null) {
        _selectedService = hospitalization.physicalService;
        _loadRoomsAndRestoreBed(
          serviceId: hospitalization.physicalService!.id!,
          roomId: hospitalization.roomId,
          bedId: hospitalization.bedId,
        );
      }
    }
  }

  final OperationKey submitOp = OperationKey.submit();
  final OperationKey _roomsOp = OperationKey.fetch();
  final OperationKey _bedsOp = OperationKey.fetch();

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

  List<Room> _rooms = [];
  List<Room> get rooms => _rooms;

  List<Bed> _beds = [];
  List<Bed> get beds => _beds;

  User? get doctor => _hospitalization?.doctor;
  bool get hasPatient => _patient != null;
  bool get isCreate => _hospitalization?.id == null;

  bool get isRoomEnabled => _selectedService != null && !isLoading(_roomsOp);
  bool get isBedEnabled => _selectedRoom != null && !isLoading(_bedsOp);
  bool get isLoadingRooms => isLoading(_roomsOp);
  bool get isLoadingBeds => isLoading(_bedsOp);

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

  Future<void> selectPhysicalService(HospitalService? service) async {
    _selectedService = service;
    _selectedRoom = null;
    _selectedBed = null;
    _rooms = [];
    _beds = [];
    _hospitalization = _hospitalization?.copyWith(physicalService: service, roomId: null, bedId: null);
    notifyListeners();

    if (service?.id != null) {
      await _loadRooms(service!.id!);
    }
  }

  void selectInpatientService(HospitalService? service) {
    _hospitalization = _hospitalization?.copyWith(inpatientService: service);
    notifyListeners();
  }

  Future<void> selectRoom(Room? room) async {
    _selectedRoom = room;
    _selectedBed = null;
    _beds = [];
    _hospitalization = _hospitalization?.copyWith(roomId: room?.id, bedId: null);
    notifyListeners();

    if (room?.id != null) {
      await _loadBeds(room!.id!);
    }
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

  Future<void> _loadRooms(int serviceId) async {
    await executeVoid(
      _roomsOp,
      operation: () async {
        final result = await _getRoomsUseCase.call(serviceId);
        return result.when(
          ok: (rooms) {
            _rooms = rooms ?? [];
            notifyListeners();
            return Result.ok(null);
          },
          error: Result.error,
        );
      },
    );
  }

  Future<void> _loadBeds(int roomId) async {
    await executeVoid(
      _bedsOp,
      operation: () async {
        final result = await _getBedsUseCase.call(roomId);
        return result.when(
          ok: (beds) {
            _beds = beds ?? [];
            notifyListeners();
            return Result.ok(null);
          },
          error: Result.error,
        );
      },
    );
  }

  Future<void> _loadRoomsAndRestoreBed({required int serviceId, int? roomId, int? bedId}) async {
    await _loadRooms(serviceId);

    if (roomId != null) {
      _selectedRoom = _rooms.firstWhereOrNull((r) => r.id == roomId);
      _hospitalization = _hospitalization?.copyWith(roomId: _selectedRoom?.id);
      notifyListeners();

      if (_selectedRoom != null && bedId != null) {
        await _loadBeds(_selectedRoom!.id!);
        _selectedBed = _beds.firstWhereOrNull((b) => b.id == bedId);
        _hospitalization = _hospitalization?.copyWith(bedId: _selectedBed?.id);
        notifyListeners();
      }
    }
  }
}
