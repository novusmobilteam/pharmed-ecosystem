// [SWREQ-MGR-REFILLLIST-001] [IEC 62304 §5.5]
//
// Dolum listesi oluşturma / düzenleme formu. İki bölümlüdür:
//   • Aday ilaçlar (sol): istasyonun seçilen tipe (min/kritik/maks/tümü) göre
//     doldurulması gereken ilaçları. Kullanıcı arar, işaretler ve "Ekle" ile
//     listeye aktarır. Önerilen miktar = hedef eşik − mevcut stok.
//   • Listedeki ilaçlar (sağ): kaydedilecek ilaçlar ve dolum miktarları;
//     miktar değiştirilir, ilaç silinir.
//
// Düzenlemede sağ taraf kayıtlı listenin ilaçlarıyla dolu açılır; sol taraf
// yalnızca yeni ilaç eklemek içindir (tip değiştirmek listedeki ilaçlara
// dokunmaz).
//
// Sınıf: Class B

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
    RefillList? initial,
  }) : _getRefillCandidates = getRefillCandidates,
       _createRefillList = createRefillList,
       _getRefillListDetail = getRefillListDetail,
       _updateRefillList = updateRefillList,
       _auth = auth {
    _initial = initial;
    _station = station ?? initial?.station;
    _user = initial?.user ?? UserMapper().fromAppUserOrNull(_auth.currentUser);
    // Yeni listede en sık kullanılan senaryo: maksimuma tamamlamak.
    _fillingType = initial == null ? RefillType.max : RefillType.all;
  }

  RefillList? _initial;
  Station? _station;

  final OperationKey fetchCandidatesOp = OperationKey.custom('fetch-candidates');
  final OperationKey fetchDetailOp = OperationKey.custom('fetch-detail');
  final OperationKey submitOp = OperationKey.custom('submit');

  bool get isCreate => _initial == null;

  bool get isLoadingCandidates => isLoading(fetchCandidatesOp);
  bool get isLoadingDetail => isLoading(fetchDetailOp);
  bool get isSubmitting => isLoading(submitOp);

  // ── Kullanıcı ───────────────────────────────────────────────────────────

  User? _user;
  User? get user => _user;

  void selectUser(User? user) {
    _user = user;
    notifyListeners();
  }

  // ── Aday ilaçlar (sol) ──────────────────────────────────────────────────

  late RefillType _fillingType;
  RefillType get fillingType => _fillingType;

  /// Sunucudan gelen, tipe göre filtrelenmiş adaylar. quantity = MEVCUT stok.
  List<RefillObject> _candidates = [];

  String _search = '';
  String get search => _search;

  /// Eklemek için işaretlenmiş adaylar (medicine.id).
  final Set<int> _checked = {};

  /// Arama uygulanmış adaylar — listede olanlar dahil (onlar "Listede"
  /// olarak gösterilir, işaretlenemez).
  List<RefillObject> get visibleCandidates {
    final q = _search.trim().toLowerCase();
    if (q.isEmpty) return _candidates;
    return _candidates.where((c) {
      final name = c.medicine?.name?.toLowerCase() ?? '';
      final barcode = c.medicine?.barcode?.toLowerCase() ?? '';
      return name.contains(q) || barcode.contains(q);
    }).toList();
  }

  /// İşaretlenebilir (henüz listede olmayan) görünür adaylar.
  List<RefillObject> get _addableVisible => visibleCandidates.where((c) => !isInList(c)).toList();

  int get checkedCount => _checked.length;

  bool isChecked(RefillObject c) => _idOf(c) != null && _checked.contains(_idOf(c));

  bool get allVisibleChecked {
    final addable = _addableVisible;
    return addable.isNotEmpty && addable.every(isChecked);
  }

  void selectFillingType(RefillType type) {
    if (_fillingType == type) return;
    _fillingType = type;
    _candidates = [];
    _checked.clear();
    notifyListeners();
    _fetchCandidates();
  }

  void onSearchChanged(String value) {
    _search = value;
    notifyListeners();
  }

  void toggleChecked(RefillObject c) {
    final id = _idOf(c);
    if (id == null || isInList(c)) return;
    _checked.contains(id) ? _checked.remove(id) : _checked.add(id);
    notifyListeners();
  }

  void toggleAllVisible() {
    final addable = _addableVisible;
    if (allVisibleChecked) {
      for (final c in addable) {
        _checked.remove(_idOf(c));
      }
    } else {
      _checked.addAll(addable.map(_idOf).whereType<int>());
    }
    notifyListeners();
  }

  /// İşaretli adayları önerilen miktarla listeye ekler.
  void addChecked() {
    for (final c in _candidates) {
      final id = _idOf(c);
      if (id == null || !_checked.contains(id) || _selections.containsKey(id)) continue;
      _selections[id] = c.copyWith(quantity: suggestedQuantity(c));
    }
    _checked.clear();
    notifyListeners();
  }

  /// Önerilen dolum miktarı: seçili tipin eşiği − mevcut stok. "Tümü"
  /// tipinde maksimum hedeflenir. En az 1.
  num suggestedQuantity(RefillObject c) {
    final limits = c.assignment;
    if (limits == null) return 1;
    final threshold = switch (_fillingType) {
      RefillType.min => limits.minQuantity,
      RefillType.critic => limits.criticalQuantity,
      RefillType.max || RefillType.all => limits.maxQuantity,
    };
    final need = threshold - c.quantity;
    return need > 0 ? need : 1;
  }

  // ── Listedeki ilaçlar (sağ) ─────────────────────────────────────────────

  /// Kaydedilecek ilaçlar (eklenme sırasıyla). quantity = DOLUM miktarı.
  final Map<int, RefillObject> _selections = {};

  List<RefillObject> get selections => _selections.values.toList();

  bool isInList(RefillObject c) => _idOf(c) != null && _selections.containsKey(_idOf(c));

  num get totalQuantity => _selections.values.fold<num>(0, (sum, s) => sum + s.quantity);

  /// Listedeki ilacın mevcut stoku — aday verisinden (güncel) okunur.
  num? currentStockOf(RefillObject selection) {
    final candidate = _candidates.firstWhereOrNull((c) => _idOf(c) == _idOf(selection));
    if (candidate != null) return candidate.quantity;
    // Aday listesinde yoksa (ör. eşiğin üstünde) kayıtlı detaydaki göz stokları.
    return refillCurrentStock(selection);
  }

  void updateQuantity(RefillObject selection, double quantity) {
    final id = _idOf(selection);
    if (id == null) return;
    if (quantity <= 0) {
      _selections.remove(id);
    } else {
      _selections[id] = selection.copyWith(quantity: quantity);
    }
    notifyListeners();
  }

  void remove(RefillObject selection) {
    final id = _idOf(selection);
    if (id == null) return;
    _selections.remove(id);
    notifyListeners();
  }

  void clearList() {
    if (_selections.isEmpty) return;
    _selections.clear();
    notifyListeners();
  }

  bool get canSave => _selections.isNotEmpty && _user?.id != null && !isSubmitting;

  // ── Yükleme ─────────────────────────────────────────────────────────────

  void initialize() {
    if (!isCreate) _fetchDetail();
    _fetchCandidates();
  }

  Future<void> _fetchDetail() async {
    final id = _initial?.id;
    if (id == null) return;
    await execute(
      fetchDetailOp,
      operation: () => _getRefillListDetail.call(id),
      onData: (objects) {
        _selections
          ..clear()
          ..addEntries([
            for (final o in objects)
              if (_idOf(o) case final id?) MapEntry(id, o),
          ]);
        notifyListeners();
      },
    );
  }

  Future<void> _fetchCandidates() async {
    final stationId = _station?.id;
    if (stationId == null) return;
    final type = _fillingType;

    await execute(
      fetchCandidatesOp,
      operation: () => _getRefillCandidates.call(GetRefillCandidatesParams(type: type, stationId: stationId)),
      onData: (candidates) {
        if (type != _fillingType) return; // bu arada tip değişti
        _candidates = candidates;
        // Yeni listede tip seçilince eşiğin altındaki tüm ilaçlar işaretli
        // gelir — kullanıcı tek tıkla ekler ya da ayıklar.
        if (isCreate && _fillingType != RefillType.all) {
          _checked
            ..clear()
            ..addAll(_addableVisible.map(_idOf).whereType<int>());
        }
        notifyListeners();
      },
    );
  }

  Future<void> submit({Function(String? msg)? onFailed, Function(String? msg)? onSuccess}) async {
    if (!canSave) return;
    final stationId = _station?.id ?? 0;
    final data = _selections.values
        .map(
          (s) => SubmitRefillListParams(
            userId: _user?.id ?? 0,
            stationId: stationId,
            medicineId: _idOf(s) ?? 0,
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

  int? _idOf(RefillObject o) => o.medicine?.id;
}

/// Detaydan gelen göz stoklarının toplamı; stok bilgisi yoksa null.
num? refillCurrentStock(RefillObject o) {
  final stocks = o.stocks;
  if (stocks == null || stocks.isEmpty) return null;
  return stocks.fold<num>(0, (sum, s) => sum + (s.quantity ?? 0));
}
