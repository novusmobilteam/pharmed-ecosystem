import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../../../core/core.dart';

class ServiceFormNotifier extends ChangeNotifier with ApiRequestMixin {
  final CreateServiceUseCase _createServiceUseCase;
  final UpdateServiceUseCase _updateServiceUseCase;
  HospitalService _service;

  ServiceFormNotifier({
    required CreateServiceUseCase createServiceUseCase,
    required UpdateServiceUseCase updateServiceUseCase,
    HospitalService? service,
  }) : _createServiceUseCase = createServiceUseCase,
       _updateServiceUseCase = updateServiceUseCase,
       _service = service ?? HospitalService(isActive: true);

  OperationKey submitOp = OperationKey.submit();

  HospitalService get service => _service;
  bool get isCreate => _service.id == null;

  bool get isSubmitting => isLoading(submitOp);
  String? get statusMessage => message(submitOp);

  final List<_RoomEntry> _roomEntries = [];
  List<({String localId, Room room})> get roomEntries =>
      _roomEntries.map((e) => (localId: e.localId, room: e.asRoom)).toList();

  List<Room> get rooms => _roomEntries.map((e) => e.asRoom).toList();

  int get totalBedCount => _roomEntries.fold(0, (s, e) => s + e.bedCount);
  List<({String localId, Bed bed})> bedEntries(String roomLocalId) =>
      _entryOf(roomLocalId)?.bedMap.entries.map((e) => (localId: e.key, bed: e.value)).toList() ?? [];

  void updateName(String? value) {
    _service = _service.copyWith(name: value);
    notifyListeners();
  }

  void updateStatus(Status? value) {
    _service = _service.copyWith(isActive: value?.isActive);
    notifyListeners();
  }

  void updateBranch(Branch? value) {
    _service = _service.copyWith(branch: value);
    notifyListeners();
  }

  void updateUser(User? value) {
    _service = _service.copyWith(user: value);
    notifyListeners();
  }

  void addRoom() {
    _roomEntries.add(
      _RoomEntry(
        localId: const Uuid().v4(),
        room: Room(name: 'Oda ${_roomEntries.length + 1}'),
      ),
    );
    notifyListeners();
  }

  void removeRoom(String localId) {
    _roomEntries.removeWhere((e) => e.localId == localId);
    notifyListeners();
  }

  void updateRoomName(String localId, String name) {
    _entryOf(localId)?.room = _entryOf(localId)!.room.copyWith(name: name);
    notifyListeners();
  }

  void addBed(String roomLocalId) {
    final entry = _entryOf(roomLocalId);
    if (entry == null) return;
    final bedLocalId = const Uuid().v4();
    entry.bedMap[bedLocalId] = Bed(name: '${entry.room.name}-${entry.bedCount + 1}');
    notifyListeners();
  }

  void removeBed(String roomLocalId, String bedLocalId) {
    _entryOf(roomLocalId)?.bedMap.remove(bedLocalId);
    notifyListeners();
  }

  void updateBedName(String roomLocalId, String bedLocalId, String name) {
    final entry = _entryOf(roomLocalId);
    if (entry == null) return;
    final bed = entry.bedMap[bedLocalId];
    if (bed == null) return;
    entry.bedMap[bedLocalId] = bed.copyWith(name: name);
    notifyListeners();
  }

  Future<void> submit() async {
    await executeVoid(
      submitOp,
      operation: () => isCreate ? _createServiceUseCase.call(_service) : _updateServiceUseCase.call(_service),
      onSuccess: () {
        if (isCreate) resetForm();
      },
      successMessage: 'Firma başarıyla ${isCreate ? 'oluşturuldu' : 'güncellendi'}',
    );
  }

  void resetForm() {
    _service = HospitalService(isActive: true);
    notifyListeners();
  }

  _RoomEntry? _entryOf(String localId) {
    try {
      return _roomEntries.firstWhere((e) => e.localId == localId);
    } catch (_) {
      return null;
    }
  }
}

class _RoomEntry {
  final String localId;
  Room room;
  final Map<String, Bed> bedMap; // bedLocalId → Bed

  _RoomEntry({required this.localId, required this.room}) : bedMap = {};

  List<Bed> get beds => List.unmodifiable(bedMap.values);
  int get bedCount => bedMap.length;

  Room get asRoom => room.copyWith(beds: beds);
}
