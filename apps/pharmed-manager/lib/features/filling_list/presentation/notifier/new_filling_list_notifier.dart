import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../../../../core/core.dart';

import '../../../../core/storage/auth/auth.dart';
import '../../../medicine/domain/entity/medicine.dart';
import '../../domain/entity/filling_list.dart';
import '../../../station/domain/entity/station.dart';
import '../../../user/user.dart';
import '../../domain/entity/filling_object.dart';
import '../../domain/useacase/create_filling_list_usecase.dart';
import '../../domain/useacase/get_filling_list_detail_usecase.dart';
import '../../domain/useacase/get_refill_candidates_usecase.dart';
import '../../domain/useacase/update_filling_list_usecase.dart';

class NewFillingListNotifier extends ChangeNotifier with ApiRequestMixin, SearchMixin<FillingObject> {
  final AuthPersistence _authPersistence;
  final GetRefillCandidatesUseCase _getRefillCandidatesUseCase;
  final CreateFillingListUseCase _createFillingListUseCase;
  final GetFillingListDetailUseCase _getFillingListDetailUseCase;
  final UpdateFillingListUseCase _updateFillingListUseCase;

  NewFillingListNotifier({
    required GetRefillCandidatesUseCase getRefillCandidatesUseCase,
    required CreateFillingListUseCase createFillingListUseCase,
    required GetFillingListDetailUseCase getFillingListDetailUseCase,
    required UpdateFillingListUseCase updateFillingListUseCase,
    required AuthPersistence authPersistence,
    required Station station,
    User? user,
    FillingList? initial,
  }) : _getRefillCandidatesUseCase = getRefillCandidatesUseCase,
       _createFillingListUseCase = createFillingListUseCase,
       _getFillingListDetailUseCase = getFillingListDetailUseCase,
       _updateFillingListUseCase = updateFillingListUseCase,
       _authPersistence = authPersistence {
    _user = user ?? _authPersistence.user;
    _selectedStation = station;
    _initial = initial;

    print(user?.fullName);
    print(_user?.fullName);
  }

  FillingList? _initial;

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

  List<FillingObject> _objects = [];
  List<FillingObject> get objects => _objects;

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
      operation: () => _getFillingListDetailUseCase.call(fillingListId),
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
      operation: () => _getRefillCandidatesUseCase.call(
        GetRefillCandidatesParams(type: _fillingType, stationId: _selectedStation!.id!),
      ),
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
    final mergedObjects = <FillingObject>[];

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

  void toggleSelection(FillingObject stock) {
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
          (s) => SubmitFillingListParams(
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
      operation: () => isCreate ? _createFillingListUseCase.call(data) : _updateFillingListUseCase.call(data),
      onFailed: (error) => onFailed?.call(error.message),
      onSuccess: () => onSuccess?.call('İşleminiz başarıyla tamamlandı.'),
    );
  }

  void updateSelectedQuantity(FillingObject object, double newQuantity) {
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

  void removeMaterial(FillingObject object) {
    _objects.removeWhere((m) => m.medicine?.id == object.medicine?.id);
    notifyListeners();
  }
}
