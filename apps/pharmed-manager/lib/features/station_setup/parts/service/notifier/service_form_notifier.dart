import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../../../core/core.dart';

class ServiceFormNotifier extends ChangeNotifier with ApiRequestMixin {
  final CreateServiceUseCase _createServiceUseCase;
  final UpdateServiceUseCase _updateServiceUseCase;
  final DeleteRoomUseCase _deleteRoomUseCase;
  final DeleteBedUseCase _deleteBedUseCase;
  HospitalService _service;
  final List<_RoomEntry> _roomEntries;

  ServiceFormNotifier({
    required CreateServiceUseCase createServiceUseCase,
    required UpdateServiceUseCase updateServiceUseCase,
    required DeleteRoomUseCase deleteRoomUseCase,
    required DeleteBedUseCase deleteBedUseCase,
    HospitalService? service,
  }) : _createServiceUseCase = createServiceUseCase,
       _updateServiceUseCase = updateServiceUseCase,
       _deleteBedUseCase = deleteBedUseCase,
       _deleteRoomUseCase = deleteRoomUseCase,
       _service = service ?? HospitalService(isActive: true),
       _roomEntries = (service?.rooms ?? []).map((room) {
         final entry = _RoomEntry(localId: const Uuid().v4(), room: room);
         for (final bed in room.beds) {
           entry.bedMap[const Uuid().v4()] = bed;
         }
         return entry;
       }).toList();

  OperationKey submitOp = OperationKey.submit();

  HospitalService get service => _service;
  bool get isCreate => _service.id == null;

  bool get isSubmitting => isLoading(submitOp);
  String? get statusMessage => message(submitOp);

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

  Future<void> removeRoom(String localId) async {
    final entry = _entryOf(localId);
    if (entry == null) return;

    final roomId = entry.room.id;
    if (roomId != null) {
      await executeVoid(
        OperationKey(OperationType.delete, customKey: 'deleteRoom_$localId'),
        operation: () => _deleteRoomUseCase.call(roomId),
        onSuccess: () {
          _roomEntries.removeWhere((e) => e.localId == localId);
          notifyListeners();
        },
        onFailed: (e) => notifyListeners(),
      );
    } else {
      _roomEntries.removeWhere((e) => e.localId == localId);
      notifyListeners();
    }
  }

  void updateRoomName(String localId, String name) {
    final entry = _entryOf(localId);
    if (entry == null) return;
    entry.room = entry.room.copyWith(name: name);
    notifyListeners();
  }

  void addBed(String roomLocalId) {
    final entry = _entryOf(roomLocalId);
    if (entry == null) return;
    final bedLocalId = const Uuid().v4();
    entry.bedMap[bedLocalId] = Bed(name: '${entry.room.name}-${entry.bedCount + 1}');
    notifyListeners();
  }

  Future<void> removeBed(String roomLocalId, String bedLocalId) async {
    final entry = _entryOf(roomLocalId);
    if (entry == null) return;

    final bedId = entry.bedMap[bedLocalId]?.id;
    if (bedId != null) {
      await executeVoid(
        OperationKey(OperationType.delete, customKey: 'deleteBed_$bedLocalId'),
        operation: () => _deleteBedUseCase.call(bedId),
        onSuccess: () {
          entry.bedMap.remove(bedLocalId);
          notifyListeners();
        },
        onFailed: (e) => notifyListeners(),
      );
    } else {
      entry.bedMap.remove(bedLocalId);
      notifyListeners();
    }
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
    final service = _service.copyWith(rooms: rooms);

    await executeVoid(
      submitOp,
      operation: () => isCreate ? _createServiceUseCase.call(service) : _updateServiceUseCase.call(service),
      onSuccess: () {
        if (isCreate) resetForm();
      },
      successMessage: 'Servis başarıyla ${isCreate ? 'oluşturuldu' : 'güncellendi'}',
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
