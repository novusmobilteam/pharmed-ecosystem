import 'package:flutter/material.dart';

import '../../../../core/core.dart';

class RoleDrugAuthNotifier extends ChangeNotifier with ApiRequestMixin {
  final GetRoleDrugAuthorizationUseCase _getAuthUseCase;
  final SaveRoleDrugAuthorizationUseCase _saveAuthUseCase;
  final Role _role;

  RoleDrugAuthNotifier({
    required GetRoleDrugAuthorizationUseCase getAuthUseCase,
    required SaveRoleDrugAuthorizationUseCase saveAuthUseCase,
    required Role role,
  }) : _getAuthUseCase = getAuthUseCase,
       _saveAuthUseCase = saveAuthUseCase,
       _role = role;

  OperationKey fetchOp = OperationKey.fetch();
  OperationKey submitOp = OperationKey.update();

  List<Medicine> _medicines = [];
  List<Medicine> get medicines => _medicines;

  List<RoleDrugAuthorization> _items = [];
  List<RoleDrugAuthorization> get items => _items;

  bool get isFetching => isLoading(fetchOp);
  bool get isSubmitting => isLoading(submitOp);

  // Değişiklik var mı?
  bool get hasChanges => _items.any((auth) => auth.isDirty);

  String _searchQuery = '';

  Future<void> fetch() async {
    await execute(
      fetchOp,
      operation: () => _getAuthUseCase.call(_role),
      onData: (data) {
        _items = data;
        notifyListeners();
      },
    );
  }

  // Değişiklikleri kaydet
  Future<void> submit({Function(String? msg)? onSuccess, Function(String? msg)? onFailed}) async {
    if (!hasChanges) return;

    await executeVoid(
      submitOp,
      operation: () async {
        final roleAuths = _items.where((auth) => auth.role?.id == _role.id && auth.isDirty).toList();

        for (int i = 0; i < roleAuths.length; i++) {
          final committedAuth = roleAuths[i].commit();
          _items[_items.indexWhere((a) => a.medicine?.id == committedAuth.medicine?.id)] = committedAuth;
        }

        return await _saveAuthUseCase.call(_items);
      },
      onFailed: (error) => onFailed?.call(error.message),
      onSuccess: () => onSuccess?.call(null),
    );
  }

  // Belirli bir ilaç için operasyon toggle et
  void toggleDrugOperation(int drugId, DrugOp operation) {
    final index = _items.indexWhere((auth) => auth.medicine?.id == drugId);
    if (index != -1) {
      final currentAuth = _items[index];
      _items[index] = currentAuth.toggle(operation);
      notifyListeners();
    }
  }

  // Belirli bir ilaç için tüm operasyonları seç
  void selectAllOperationsForDrug(int drugId) {
    final index = _items.indexWhere((auth) => auth.medicine?.id == drugId);
    if (index != -1) {
      final currentAuth = _items[index];
      _items[index] = currentAuth.copyWith(pendingOps: {DrugOp.pull, DrugOp.fill, DrugOp.returnOp, DrugOp.dispose});
      notifyListeners();
    }
  }

  // Belirli bir ilaç için tüm operasyonları kaldır
  void clearAllOperationsForDrug(int drugId) {
    final index = _items.indexWhere((auth) => auth.medicine?.id == drugId);
    if (index != -1) {
      final currentAuth = _items[index];
      _items[index] = currentAuth.copyWith(pendingOps: {});
      notifyListeners();
    }
  }

  // Belirli bir operasyonu tüm ilaçlar için toggle et
  void toggleOperationForAllDrugs(DrugOp operation) {
    final shouldSelect = !_items.every((auth) => auth.pendingOps.contains(operation));

    _items = _items.map((auth) {
      final newOps = shouldSelect
          ? {...auth.pendingOps, operation}
          : auth.pendingOps.where((op) => op != operation).toSet();
      return auth.copyWith(pendingOps: newOps);
    }).toList();

    notifyListeners();
  }

  // Belirli bir ilaç için operasyonun seçili olup olmadığını kontrol et
  bool isOperationSelected(int drugId, DrugOp operation) {
    final auth = _items.firstWhere(
      (auth) => auth.medicine?.id == drugId,
      orElse: () => RoleDrugAuthorization(
        role: Role(id: _role.id, name: ''),
        medicine: Drug(id: drugId, name: ''),
        originalOps: {},
        pendingOps: {},
      ),
    );
    return auth.pendingOps.contains(operation);
  }

  // İlaç için herhangi bir operasyon seçili mi?
  bool hasAnyOperationSelected(int drugId) {
    final auth = _items.firstWhere(
      (auth) => auth.medicine?.id == drugId,
      orElse: () => RoleDrugAuthorization(
        role: Role(id: _role.id, name: ''),
        medicine: Drug(id: drugId, name: ''),
        originalOps: {},
        pendingOps: {},
      ),
    );
    return auth.pendingOps.isNotEmpty;
  }

  // Tüm ilaçlar için tüm operasyonları seç
  void selectAllForAllDrugs() {
    _items = _items
        .map((auth) => auth.copyWith(pendingOps: {DrugOp.pull, DrugOp.fill, DrugOp.returnOp, DrugOp.dispose}))
        .toList();
    notifyListeners();
  }

  // Tüm ilaçlar için tüm operasyonları kaldır
  void clearAllForAllDrugs() {
    _items = _items.map((auth) => auth.copyWith(pendingOps: {})).toList();
    notifyListeners();
  }

  // Değişiklikleri iptal et
  void cancelChanges() {
    _items = _items.map((auth) => auth.resetPending()).toList();
    notifyListeners();
  }

  void onSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<RoleDrugAuthorization> get filteredAuths {
    if (_searchQuery.isEmpty) return _items;
    final query = _searchQuery.toLowerCase();
    return _items.where((auth) {
      final name = auth.medicine?.name?.toLowerCase() ?? '';
      //final code = auth.medicine?.code?.toLowerCase() ?? '';
      return name.contains(query);
    }).toList();
  }
}
