import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../../../core/core.dart';

import '../../auth/notifier/auth_notifier.dart';

class RefillListFormNotifier extends ChangeNotifier with ApiRequestMixin {
  final AuthNotifier _auth;
  final GetRefillCandidatesUseCase _getRefillCandidates;
  final CreateRefillListUseCase _createRefillList;
  final GetRefillListDetailUseCase _getRefillListDetail;
  final UpdateRefillListUseCase _updateRefillList;

  RefillListFormNotifier({
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
  RefillType _fillingType = RefillType.all;
  RefillType get fillingType => _fillingType;

  // Operation Keys
  OperationKey fetchOp = OperationKey.fetch();
  OperationKey submitOp = OperationKey.custom('submit');
  OperationKey fetchDetailOp = OperationKey.fetch();

  User? _user;
  User? get user => _user;

  Station? _selectedStation;

  /// Sunucudan gelen, tipe göre filtrelenmiş aday listesi.
  /// SADECE görüntüleme amaçlıdır — quantity alanı "mevcut stok"tur,
  /// asla dolum miktarı ile ezilmez.
  List<RefillObject> _candidates = [];
  List<RefillObject> get objects => _candidates;

  /// Kullanıcının seçtiği / miktar girdiği item'lar. Key: medicine.id
  /// quantity alanı burada "dolum miktarı" anlamına gelir.
  Map<int, RefillObject> _selections = {};

  bool get isCreate => _initial == null;

  void initalize() {
    if (_initial != null) {
      getRefillListDetail();
    } else {
      getRefillCandidates();
    }
  }

  void getRefillListDetail() async {
    if (_initial == null) return;
    final fillingListId = _initial?.id ?? 0;
    await execute(
      fetchDetailOp,
      operation: () => _getRefillListDetail.call(fillingListId),
      onData: (detailObjects) {
        _selections = {
          for (final d in detailObjects)
            if (d.medicine?.id != null) d.medicine!.id!: d,
        };
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
        _candidates = candidates;

        if (!isCreate) {
          _mergeDetailIntoSelections();
        } else {
          // Otomatik dolum hesaplaması sadece yeni liste oluştururken çalışır.
          // Edit modunda tip değiştirmek sadece görünümü filtreler,
          // kayıtlı seçimlere otomatik yeni öneri eklenmez.
          _autoCalculateFillQuantities();
        }

        notifyListeners();
      },
    );
  }

  /// Edit modunda: daha önce kaydedilmiş [_selections] içindeki item'ları
  /// güncel [_candidates] verisiyle (assignment/stock limitleri değişmiş
  /// olabilir) tazeler. quantity (dolum miktarı) ve detailIds korunur.
  void _mergeDetailIntoSelections() {
    final updated = <int, RefillObject>{};
    _selections.forEach((medicineId, selection) {
      final candidate = _candidates.firstWhereOrNull((c) => c.medicine?.id == medicineId);
      updated[medicineId] = candidate != null
          ? candidate.copyWith(quantity: selection.quantity, detailIds: selection.detailIds)
          : selection;
    });
    _selections = updated;
  }

  /// Tip min/max/critic ise, henüz seçilmemiş her candidate için
  /// hedef değer - mevcut stok kadar otomatik dolum miktarı önerir.
  /// Zaten _selections'ta olan bir item asla ezilmez.
  void _autoCalculateFillQuantities() {
    if (_fillingType == RefillType.all) return;

    for (final candidate in _candidates) {
      final id = candidate.medicine?.id;
      if (id == null || _selections.containsKey(id)) continue;

      final current = candidate.medicine?.fromFillingBackendValue(candidate.quantity.toDouble()) ?? 0.0;
      final limits = candidate.assignment;
      num target = 0;

      switch (_fillingType) {
        case RefillType.min:
          target = (limits?.minQuantityFromBackend ?? 0) - current;
        case RefillType.max:
          target = (limits?.maxQuantityFromBackend ?? 0) - current;
        case RefillType.critic:
          target = (limits?.critQuantityFromBackend ?? 0) - current;
        case RefillType.all:
          break;
      }

      if (target > 0) {
        _setSelection(candidate, target.toDouble());
      }
    }
  }

  void selectUser(User? user) {
    _user = user;
    notifyListeners();
  }

  void selectFillingType(RefillType type) {
    if (_fillingType == type) return;
    _fillingType = type;
    _candidates = [];
    notifyListeners();
    getRefillCandidates();
  }

  /// Mevcut görünümdeki seçilmemiş item'lar için manuel yeniden hesap
  /// (ör. bir "yeniden hesapla" aksiyonu istenirse kullanılabilir).
  void autoFill() {
    _autoCalculateFillQuantities();
    notifyListeners();
  }

  double selectedQuantity(RefillObject candidate) {
    final id = candidate.medicine?.id;
    if (id == null) return 0.0;
    return (_selections[id]?.quantity ?? 0).toDouble();
  }

  bool isSelected(RefillObject candidate) {
    final id = candidate.medicine?.id;
    return id != null && _selections.containsKey(id);
  }

  void toggleSelection(RefillObject candidate) {
    final id = candidate.medicine?.id;
    if (id == null) return;

    if (_selections.containsKey(id)) {
      _selections.remove(id);
    } else {
      _setSelection(candidate, 1);
    }
    notifyListeners();
  }

  void updateSelectedQuantity(RefillObject candidate, double newQuantity) {
    _setSelection(candidate, newQuantity);
    notifyListeners();
  }

  void _setSelection(RefillObject candidate, double newQuantity) {
    final id = candidate.medicine?.id;
    if (id == null) return;

    if (newQuantity > 0) {
      final existing = _selections[id];
      _selections[id] = candidate.copyWith(quantity: newQuantity, detailIds: existing?.detailIds);
    } else {
      _selections.remove(id);
    }
  }

  void removeMaterial(RefillObject candidate) {
    final id = candidate.medicine?.id;
    if (id == null) return;
    _selections.remove(id);
    notifyListeners();
  }

  Future<void> submit({Function(String? msg)? onFailed, Function(String? msg)? onSuccess}) async {
    final stationId = _selectedStation?.id ?? 0;
    final data = _selections.values
        .map(
          (s) => SubmitRefillListParams(
            userId: _user?.id ?? 0,
            stationId: stationId,
            medicineId: s.medicine?.id ?? 0,
            quantity: s.medicine?.toFillingBackendValue(s.quantity.toDouble()) ?? s.quantity,
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
}
