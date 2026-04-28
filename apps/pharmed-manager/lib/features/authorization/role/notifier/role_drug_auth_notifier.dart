import 'package:flutter/material.dart';

import '../../../../core/core.dart';

class RoleDrugAuthNotifier extends ChangeNotifier with ApiRequestMixin, SearchMixin<RoleDrugAuthorization> {
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

  bool get isFetching => isLoading(fetchOp);
  bool get isSubmitting => isLoading(submitOp);

  // Değişiklik var mı?
  bool get hasChanges => allItems.any((auth) => auth.isDirty);

  String _searchQuery = '';

  /// Verileri Yükle (Initialize)
  Future<void> initialize() async {
    await execute(
      fetchOp,
      operation: () => _getAuthUseCase.call(_role),
      onData: (data) {
        allItems = data;
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
        final roleAuths = allItems.where((auth) => auth.role?.id == _role.id && auth.isDirty).toList();

        for (int i = 0; i < roleAuths.length; i++) {
          final committedAuth = roleAuths[i].commit();
          allItems[allItems.indexWhere((a) => a.medicine?.id == committedAuth.medicine?.id)] = committedAuth;
        }

        return await _saveAuthUseCase.call(allItems);
      },
      onFailed: (error) => onFailed?.call(error.message),
      onSuccess: () => onSuccess?.call('İşleminiz başarıyla tamamlandı.'),
    );
  }

  // Belirli bir ilaç için operasyon toggle et
  void toggleDrugOperation(int drugId, DrugOp operation) {
    final index = allItems.indexWhere((auth) => auth.medicine?.id == drugId);
    if (index != -1) {
      final currentAuth = allItems[index];
      allItems[index] = currentAuth.toggle(operation);
      notifyListeners();
    }
  }

  // Belirli bir ilaç için tüm operasyonları seç
  void selectAllOperationsForDrug(int drugId) {
    final index = allItems.indexWhere((auth) => auth.medicine?.id == drugId);
    if (index != -1) {
      final currentAuth = allItems[index];
      allItems[index] = currentAuth.copyWith(pendingOps: {DrugOp.pull, DrugOp.fill, DrugOp.returnOp, DrugOp.dispose});
      notifyListeners();
    }
  }

  // Belirli bir ilaç için tüm operasyonları kaldır
  void clearAllOperationsForDrug(int drugId) {
    final index = allItems.indexWhere((auth) => auth.medicine?.id == drugId);
    if (index != -1) {
      final currentAuth = allItems[index];
      allItems[index] = currentAuth.copyWith(pendingOps: {});
      notifyListeners();
    }
  }

  // Belirli bir operasyonu tüm ilaçlar için toggle et
  void toggleOperationForAllDrugs(DrugOp operation) {
    final shouldSelect = !allItems.every((auth) => auth.pendingOps.contains(operation));

    allItems = allItems.map((auth) {
      final newOps = shouldSelect
          ? {...auth.pendingOps, operation}
          : auth.pendingOps.where((op) => op != operation).toSet();
      return auth.copyWith(pendingOps: newOps);
    }).toList();

    notifyListeners();
  }

  // Belirli bir ilaç için operasyonun seçili olup olmadığını kontrol et
  bool isOperationSelected(int drugId, DrugOp operation) {
    final auth = allItems.firstWhere(
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
    final auth = allItems.firstWhere(
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
    allItems = allItems
        .map((auth) => auth.copyWith(pendingOps: {DrugOp.pull, DrugOp.fill, DrugOp.returnOp, DrugOp.dispose}))
        .toList();
    notifyListeners();
  }

  // Tüm ilaçlar için tüm operasyonları kaldır
  void clearAllForAllDrugs() {
    allItems = allItems.map((auth) => auth.copyWith(pendingOps: {})).toList();
    notifyListeners();
  }

  // Değişiklikleri iptal et
  void cancelChanges() {
    allItems = allItems.map((auth) => auth.resetPending()).toList();
    notifyListeners();
  }

  void onSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<RoleDrugAuthorization> get filteredAuths {
    if (_searchQuery.isEmpty) return allItems;
    final query = _searchQuery.toLowerCase();
    return allItems.where((auth) {
      final name = auth.medicine?.name?.toLowerCase() ?? '';
      //final code = auth.medicine?.code?.toLowerCase() ?? '';
      return name.contains(query);
    }).toList();
  }
}
