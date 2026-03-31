import 'package:flutter/material.dart';

import '../../../../core/core.dart';

class UserFormNotifier extends ChangeNotifier with ApiRequestMixin {
  final CreateUserUseCase _createUserUseCase;
  final UpdateUserUseCase _updateUserUseCase;
  final IStationRepository _stationRepository;
  User _user;

  UserFormNotifier({
    required CreateUserUseCase createUserUseCase,
    required UpdateUserUseCase updateUserUseCase,
    required IStationRepository stationRepository,
    User? user,
  }) : _createUserUseCase = createUserUseCase,
       _updateUserUseCase = updateUserUseCase,
       _stationRepository = stationRepository,
       _user =
           user ??
           User(
             isActive: true,
             type: UserType.normal,
             isNotOrdered: true,
             kitPurchase: true,
             isWitnessedStationEntry: true,
           ) {
    _loadStations();
  }

  OperationKey submitOp = OperationKey.submit();

  User get user => _user;

  List<Station> _stations = [];
  List<Station> get stations => _stations;

  List<Station> _selectedStations = [];
  List<Station> get selectedStations => _selectedStations;

  bool get isCreate => _user.id == null;

  Future<void> submit({Function(String? msg)? onFailed, Function(String? msg)? onSuccess}) async {
    await executeVoid(
      submitOp,
      operation: () => isCreate ? _createUserUseCase.call(_user) : _updateUserUseCase.call(user),
      onFailed: (error) => onFailed?.call(error.message),
      onSuccess: () => onSuccess?.call('İşleminiz başarıyla tamamlandı.'),
    );
  }

  Future<void> _loadStations() async {
    final res = await _stationRepository.getStations();

    res.when(
      ok: (response) {
        final data = response.data ?? [];
        _stations = data;
        final idSet = (_user.stationIds ?? const <int>[]).toSet();
        _selectedStations = data.where((s) => idSet.contains(s.id)).toList();
        notifyListeners();
      },
      error: (err) {
        _stations = [];
        _selectedStations = [];
        notifyListeners();
      },
    );
  }

  void changeRegistrationNumber(String? value) {
    _user = _user.copyWith(registrationNumber: value);
    notifyListeners();
  }

  void changeName(String? value) {
    _user = _user.copyWith(name: value);
    notifyListeners();
  }

  void changeSurname(String? value) {
    _user = _user.copyWith(surname: value);
    notifyListeners();
  }

  void changeRole(Role? value) {
    _user = _user.copyWith(role: value);
    notifyListeners();
  }

  void changeStatus(bool isActive) {
    _user = _user.copyWith(isActive: isActive);
    notifyListeners();
  }

  void changeUserType(UserType value) {
    _user = _user.copyWith(type: value);
    notifyListeners();
  }

  void changeEmail(String? value) {
    _user = _user.copyWith(email: value);
    notifyListeners();
  }

  void changeOrderPermission(bool value) {
    _user = _user.copyWith(isNotOrdered: value);
    notifyListeners();
  }

  void changeWitnessedEntry(bool value) {
    _user = _user.copyWith(isWitnessedStationEntry: value);
    notifyListeners();
  }

  void changeKitPurchase(bool value) {
    _user = _user.copyWith(kitPurchase: value);
    notifyListeners();
  }

  void changeUsername(String? value) {
    _user = _user.copyWith(userName: value);
    notifyListeners();
  }

  void changePassword(String? value) {
    _user = _user.copyWith(password: value);
    notifyListeners();
  }

  void changeStations(List<Station> stations) {
    _selectedStations = List.from(stations);
    final ids = stations.map((s) => s.id).whereType<int>().toList();
    _user = _user.copyWith(stationIds: ids);
    notifyListeners();
  }

  void changeValidUntil(DateTime? value) {
    _user = _user.copyWith(validUntil: value);
    notifyListeners();
  }
}
