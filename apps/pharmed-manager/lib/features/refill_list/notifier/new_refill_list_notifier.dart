import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../../../core/core.dart';

import '../../auth/notifier/auth_notifier.dart';

class NewRefillListNotifier extends ChangeNotifier with ApiRequestMixin, SearchMixin<RefillObject> {
  final AuthNotifier _auth;
  final GetRefillCandidatesUseCase _getRefillCandidates;
  final CreateRefillListUseCase _createRefillList;
  final GetRefillListDetailUseCase _getRefillListDetail;
  final UpdateRefillListUseCase _updateRefillList;

  NewRefillListNotifier({
    required GetRefillCandidatesUseCase getRefillCandidates,
    required CreateRefillListUseCase createRefillList,
    required GetRefillListDetailUseCase getRefillListDetail,
    required UpdateRefillListUseCase updateRefillList,
    required AuthNotifier auth,
    Station? station,
    User? user,
    RefillList? initial,
  }) : _getRefillCandidates = getRefillCandidates,
       _createRefillList = createRefillList,
       _getRefillListDetail = getRefillListDetail,
       _updateRefillList = updateRefillList,
       _auth = auth {
    _user = user ?? UserMapper().fromAppUserOrNull(_auth.currentUser);
    _selectedStation = station;
    _initial = initial;
  }

  RefillList? _initial;

  // Dolum Tipi
  FillingType _fillingType = FillingType.all;
  FillingType get fillingType => _fillingType;

  // Operation Keys
  OperationKey fetchOp = OperationKey.fetch();
  OperationKey submitOp = OperationKey.custom('submit');
  OperationKey fetchDetailOp = OperationKey.fetch();

  User? _user;
  User? get user => _user;

  // Dolum listesi oluşturma işlemi istasyon bazlı yapılan bir işlem.
  // Ayrıca malzemeler de istasyon bazlı geliyor servisten.
  Station? _selectedStation;

  List<RefillObject> _objects = [];
  List<RefillObject> get objects => _objects;

  bool get isCreate => _initial == null;

  void initalize() {
    if (_initial != null) {
      getFillingListDetail();
    } else {
      getRefillCandidates();
    }
  }

  void getFillingListDetail() async {
    if (_initial == null) return;
    final fillingListId = _initial?.id ?? 0;
    await execute(
      fetchDetailOp,
      operation: () => _getRefillListDetail.call(fillingListId),
      onData: (detailObjects) {
        _objects
          ..clear()
          ..addAll(detailObjects);
        getRefillCandidates();
        notifyListeners();
      },
    );
  }

  Future<void> getRefillCandidates() async {
    if (_selectedStation == null) return;

    await execute(
      fetchOp,
      operation: () =>
          _getRefillCandidates.call(GetRefillCandidatesParams(type: _fillingType, stationId: _selectedStation!.id!)),
      onData: (candidates) {
        allItems = candidates;

        // Edit modunda: detail'den gelen miktarları candidates'ın
        // objelerine yansıt. Bu sayede allItems'daki zengin obje
        // yapısı korunur, sadece quantity güncellenir.
        if (!isCreate) {
          _mergeDetailIntoObjects();
        }

        notifyListeners();
      },
    );
  }

  /// Detail'den gelen [_objects]'taki medicine id'lere göre
  /// allItems içindeki karşılıklarını bulur ve _objects listesini
  /// candidates'ın objesiyle (doğru assignment/limit bilgileriyle)
  /// yeniden oluşturur.
  void _mergeDetailIntoObjects() {
    final mergedObjects = <RefillObject>[];

    for (final detailObj in _objects) {
      final matchedCandidate = allItems.firstWhereOrNull((c) => c.medicine?.id == detailObj.medicine?.id);

      if (matchedCandidate != null) {
        mergedObjects.add(matchedCandidate.copyWith(quantity: detailObj.quantity));
      } else {
        mergedObjects.add(detailObj);
      }
    }

    // Eşleşenler (candidates'da var) başa, olmayanlar sona
    mergedObjects.sort((a, b) {
      final aMatched = allItems.any((c) => c.medicine?.id == a.medicine?.id);
      final bMatched = allItems.any((c) => c.medicine?.id == b.medicine?.id);
      if (aMatched && !bMatched) return -1;
      if (!aMatched && bMatched) return 1;
      return 0;
    });

    _objects
      ..clear()
      ..addAll(mergedObjects);
  }

  void selectUser(User? user) {
    _user = user;
    notifyListeners();
  }

  void selectFillingType(FillingType type) {
    _fillingType = type;
    _objects.clear();
    notifyListeners();
    getRefillCandidates();
  }

  void autoFill() {
    for (var item in allItems) {
      final currentStock = item.medicine?.fromFillingBackendValue(item.quantity) ?? 0;
      final limits = item.assignment;
      num targetFillAmount = 0;

      // Seçili olan FillingType'a göre hedef miktar hesaplama
      if (_fillingType == FillingType.min) {
        targetFillAmount = (limits?.minQuantityFromBackend ?? 0) - currentStock;
      } else if (_fillingType == FillingType.max) {
        targetFillAmount = (limits?.maxQuantityFromBackend ?? 0) - currentStock;
      } else if (_fillingType == FillingType.critic) {
        targetFillAmount = (limits?.critQuantityFromBackend ?? 0) - currentStock;
      }

      // Eğer bir dolum ihtiyacı varsa (hedef > 0)
      if (targetFillAmount > 0) {
        updateSelectedQuantity(item, targetFillAmount.toDouble());
      }
    }
  }

  void toggleSelection(RefillObject stock) {
    final isSelected = _objects.any((m) => m.medicine?.id == stock.medicine?.id);
    if (isSelected) {
      removeMaterial(stock);
    } else {
      // İlk tıklamada varsayılan olarak 1 adet veya eksik kadar ekle
      updateSelectedQuantity(stock, 1);
    }
  }

  Future<void> submit({Function(String? msg)? onFailed, Function(String? msg)? onSuccess}) async {
    final stationId = _selectedStation?.id ?? 0;
    final data = _objects
        .map(
          (s) => SubmitRefillListParams(
            userId: _user?.id ?? 0,
            stationId: stationId,
            medicineId: s.medicine?.id ?? 0,
            quantity: s.quantity,
            fillingListId: _initial?.id,
          ),
        )
        .toList();

    await executeVoid(
      submitOp,
      operation: () => isCreate ? _createRefillList.call(data) : _updateRefillList.call(data),
      onFailed: (error) => onFailed?.call(error.message),
      onSuccess: () => onSuccess?.call(null),
    );
  }

  void updateSelectedQuantity(RefillObject object, double newQuantity) {
    final index = _objects.indexWhere((m) => m.medicine?.id == object.medicine?.id);

    if (newQuantity > 0) {
      if (index != -1) {
        _objects[index] = _objects[index].copyWith(quantity: newQuantity);
      } else {
        _objects.add(object.copyWith(quantity: newQuantity));
      }
    } else {
      if (index != -1) {
        _objects.removeAt(index);
      }
    }
    notifyListeners();
  }

  void removeMaterial(RefillObject object) {
    _objects.removeWhere((m) => m.medicine?.id == object.medicine?.id);
    notifyListeners();
  }
}
