import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';
import '../../../auth/presentation/notifier/auth_notifier.dart';
import '../../../medicine_management/domain/entity/cabin_operation_item.dart';

import '../../domain/mapper/withdraw_item_mapper.dart';

import '../../domain/utils/withdraw_check_status.dart';

class WithdrawNotifier extends ChangeNotifier with ApiRequestMixin {
  late WithdrawType _type;
  final AuthNotifier _authPersistence;
  final Hospitalization? _hospitalization;
  final GetWithdrawItemsUseCase _getWithdrawItemsUseCase;
  final CheckWithdrawUseCase _checkWithdrawUseCase;
  final CompleteWithdrawUseCase _completeWithdrawUseCase;
  final GetCurrentStationUseCase _getCurrentStationUseCase;

  /// Tüm kontroller tamamlandığında ve alım başlatılabilir duruma gelindiğinde
  /// tetiklenen callback. Çekmece açma işlemi bu callback üzerinden yapılır.
  final Future<void> Function(WithdrawNotifier notifier) onChecksCompleted;

  WithdrawNotifier({
    required this.onChecksCompleted,
    required WithdrawType type,
    Hospitalization? hospitalization,
    required GetWithdrawItemsUseCase getWithdrawItemsUseCase,
    required CheckWithdrawUseCase checkWithdrawUseCase,
    required CompleteWithdrawUseCase completeWithdrawUseCase,
    required GetCurrentStationUseCase getCurrentStationUseCase,
    required AuthNotifier authPersistence,
  }) : _checkWithdrawUseCase = checkWithdrawUseCase,
       _getWithdrawItemsUseCase = getWithdrawItemsUseCase,
       _completeWithdrawUseCase = completeWithdrawUseCase,
       _authPersistence = authPersistence,
       _hospitalization = hospitalization,
       _getCurrentStationUseCase = getCurrentStationUseCase,
       _type = type;

  // Operation Keys
  OperationKey fetchItemsOp = OperationKey.fetch();
  OperationKey refreshAssignmentsOp = OperationKey.custom('refresh_assignments');
  OperationKey initOp = OperationKey.fetch();
  OperationKey fetchDrugOp = OperationKey.fetch();
  OperationKey loginOp = OperationKey.custom('login');
  OperationKey checkOp = OperationKey.custom('check');
  OperationKey completeOp = OperationKey.custom('complete');

  bool get isFetching => isLoading(fetchItemsOp);

  Station? _currentStation;
  Station? get currentStation => _currentStation;

  // ---------------------------------------------------------------------------
  // Data — artık CabinOperationItem tutuyor
  // ---------------------------------------------------------------------------

  List<CabinOperationItem> _items = [];
  List<CabinOperationItem> get items => _items;

  List<CabinOperationItem> _selectedItems = [];
  List<CabinOperationItem> get selectedItems => _selectedItems;

  final Set<int> _completedItems = {};
  Set<int> get completedItems => _completedItems;

  final Set<int> _failedItems = {};
  Set<int> get failedItems => _failedItems;

  final Set<int> _canceledItems = {};
  Set<int> get canceledItems => _canceledItems;

  Map<int, WithdrawCheckStatus> _checkStatuses = {};
  Map<int, WithdrawCheckStatus> get checkStatuses => _checkStatuses;

  Map<int, List<WithdrawDetail>> _withdrawPlans = {};
  Map<int, List<WithdrawDetail>> get withdrawPlans => _withdrawPlans;

  /// Anlık olarak işlem yapılan ilaç.
  CabinOperationItem? get currentItem => _selectedItems.isNotEmpty ? _selectedItems.first : null;

  /// Anlık olarak işlem yapılan ilacın kabin ataması.
  MedicineAssignment? get currentAssignment => currentItem?.assignment;

  WithdrawType get type => _type;

  void initialize() async {
    await execute(
      initOp,
      operation: () => _getCurrentStationUseCase.call(),
      onData: (station) {
        _currentStation = station;
        getItems();
      },
      onFailed: (error) => getItems(),
    );
  }

  Future<void> getItems({bool refreshAssignments = false}) async {
    if (_hospitalization == null && _type != WithdrawType.free) return;
    return execute(
      refreshAssignments ? refreshAssignmentsOp : fetchItemsOp,
      operation: () => _getWithdrawItemsUseCase.call(
        GetWithdrawItemsParams(
          type: _type,
          hospitalizationId: _hospitalization?.id,
          refreshAssignments: refreshAssignments,
        ),
      ),
      onData: (data) {
        _items = (data).map((e) => e.toCabinOperationItem()).toList();
        _selectedItems = _selectedItems.map((selected) {
          final updated = _items.firstWhereOrNull((i) => i.id == selected.id);
          return updated != null ? selected.copyWith(assignment: updated.assignment) : selected;
        }).toList();
        notifyListeners();
      },
    );
  }

  void selectItem(CabinOperationItem item) {
    if (_selectedItems.any((s) => s.id == item.id)) {
      _selectedItems.removeWhere((s) => s.id == item.id);
    } else {
      // dosePiece 0 veya null ise 1 yap
      final updatedItem = (item.dosePiece == null || item.dosePiece == 0) ? item.copyWith(dosePiece: 1) : item;
      final index = _items.indexWhere((i) => i.id == item.id);
      if (index != -1) _items[index] = updatedItem;

      _selectedItems.add(updatedItem);
    }
    notifyListeners();
  }

  /// Şahit havuzuna yeni bir kullanıcı ekler ve ilgili alım kalemlerini günceller.
  ///
  /// 1. [selectedItem] için [user]'ı doğrudan şahit olarak atar.
  /// 2. Listedeki diğer kalemler için witnesses listesi boşsa veya user listede
  ///    varsa ve henüz şahit atanmamışsa otomatik olarak şahit atar.
  /// 3. _items güncellendikten sonra _selectedItems referansları senkronize edilir.
  void addWitness(CabinOperationItem selectedItem, User user) {
    _items = _items.map((item) {
      if (item.id == selectedItem.id) {
        return item.copyWith(witness: user);
      }

      final canWitness = item.witnesses.isEmpty || item.witnesses.any((w) => w.id == user.id);

      if (canWitness && item.witness == null) {
        return item.copyWith(witness: user);
      }

      return item;
    }).toList();

    _selectedItems = _items.where((item) => _selectedItems.any((s) => s.id == item.id)).toList();

    notifyListeners();
  }

  void startWithdraw({Function(String? msg)? onFailed, Function(String? msg)? onSuccess}) {
    if (selectedItems.isEmpty) return;

    final userId = _authPersistence.currentUser?.id ?? 0;
    final item = _selectedItems.first;

    // Şahitlik kontrolü.
    if (item.needsWitness(currentStation: _currentStation) && item.witness == null) {
      _checkStatuses[item.id] = const CheckFailed(message: 'Şahit girişi yapılması gerekmektedir.');
      notifyListeners();
      onFailed?.call('Şahit girişi yapılması gerekmektedir.');
      return;
    }

    // Seçili itemin kontrol işlemi
    checkCurrentItem(
      item,
      userId,
      onFailed: (msg) {
        // Hatalı item'ı seçilenlerden çıkar
        _selectedItems.removeWhere((a) => a.id == item.id);
        notifyListeners();

        // Hala seçili item varsa sıradakine geç
        if (_selectedItems.isNotEmpty) {
          startWithdraw(onFailed: onFailed, onSuccess: onSuccess);
        } else {
          onFailed?.call(msg);
        }
      },
      onSuccess: (details) async {
        _prepareCounting(item, details);
        await onChecksCompleted(this);
      },
    );
  }

  Future<void> checkCurrentItem(
    CabinOperationItem item,
    int userId, {
    Function(String? msg)? onFailed,
    Function(List<WithdrawDetail> details)? onSuccess,
  }) async {
    _checkStatuses[item.id] = const CheckLoading();
    notifyListeners();

    await execute(
      checkOp,
      operation: () => _checkWithdrawUseCase.call(
        CheckWithdrawParams(
          type: _type,
          prescriptionDetailId: item.prescriptionItem?.id,
          hospitalizationId: _hospitalization?.id,
          assignment: item.assignment ?? MedicineAssignment(),
          dosePiece: item.dosePiece ?? 0,
          userId: userId,
        ),
      ),
      onData: (details) {
        _checkStatuses[item.id] = const CheckSuccess();
        _withdrawPlans[item.id] = details;
        onSuccess?.call(details);
      },
      onFailed: (error) {
        _checkStatuses[item.id] = CheckFailed(message: error.message);
        onFailed?.call(error.message);
      },
    );
  }

  Future<void> completeWithdraw({
    bool isCancelled = false,
    Function(String? message)? onSuccess,
    Function(String? message)? onFailed,
  }) async {
    if (currentItem == null) return;

    final plan = _withdrawPlans[currentItem!.id] ?? [];

    if (isCancelled) {
      _handleNextStep(isCancelled: isCancelled, onFailed: onFailed, onSuccess: onSuccess);

      return;
    }

    await executeVoid(
      completeOp,
      operation: () => _completeWithdrawUseCase.call(
        WithdrawParams(
          type: _type,
          prescriptionDetailId: currentItem?.prescriptionItem?.id,
          hospitalizationId: _hospitalization?.id,
          userId: currentItem?.witness?.id,
          details: plan,
        ),
      ),
      onSuccess: () {
        _handleNextStep(isFailed: false, onFailed: onFailed, onSuccess: onSuccess);
      },
      onFailed: (error) {
        _handleNextStep(isFailed: true, onFailed: onFailed, onSuccess: onSuccess);
      },
    );
  }

  void _handleNextStep({
    bool isCancelled = false,
    bool isFailed = false,
    Function(String? message)? onSuccess,
    Function(String? message)? onFailed,
  }) {
    final currentId = currentItem!.id;
    _selectedItems.removeWhere((a) => a.id == currentId);
    _withdrawPlans.remove(currentId);

    if (isCancelled) {
      _canceledItems.add(currentId);
      onFailed?.call('Alım işlemi kullanıcı tarafından iptal edildi');
      return;
    } else {
      if (isFailed) {
        _failedItems.add(currentId);
        onFailed?.call('Alım işlemi sırasında bir hata oluştu.');
      } else {
        _completedItems.add(currentId);
        if (_selectedItems.isNotEmpty) {
          onSuccess?.call('İşlem kaydedildi. Sıradaki ilaç için çekmecenin kapanması bekleniyor...');
        } else {
          onSuccess?.call('Alım işlemi tamamlandı.');
        }
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Miktar güncelleme
  // ---------------------------------------------------------------------------

  /// Seçili item için alım miktarını güncelleyen metod.
  ///
  /// [MedicalConsumable] için:
  /// - Miktar 1'in altına düşemez.
  /// - Kabindeki fiziksel stok miktarını aşamaz.
  ///
  /// [Drug] için:
  /// - Reçeteli alımda canLower false ise miktar reçete dozundan aşağı düşemez.
  /// - Üst limit; reçete dozu, fiziksel stok ve günlük maks. kullanımın
  ///   en küçüğü olarak hesaplanır.
  void updateWithdrawAmount(CabinOperationItem item, double newAmount) {
    final medicine = item.medicine;
    double validatedAmount = newAmount;

    if (medicine is MedicalConsumable) {
      final stockLimit = item.assignment?.toDisplayQuantity(item.assignment?.totalQuantity ?? 0) ?? 0.0;
      if (validatedAmount < 1) validatedAmount = 1;
      if (validatedAmount > stockLimit) validatedAmount = stockLimit;
    } else if (medicine is Drug) {
      final bool isOrdered = _type == WithdrawType.ordered;
      final bool canLower = medicine.isCanLowerDose;
      final double upperLimitFromOrder = item.prescriptionDose ?? 0.0;

      final double minLimit = (isOrdered && !canLower) ? upperLimitFromOrder : 1.0;

      final double physicalLimit = item.assignment?.toDisplayQuantity(item.assignment?.totalQuantity ?? 0) ?? 0.0;
      final double dailyMax = (medicine.dailyMaxUsage ?? 0) > 0 ? medicine.dailyMaxUsage!.toDouble() : physicalLimit;
      final double safetyLimit = physicalLimit < dailyMax ? physicalLimit : dailyMax;
      final double finalUpperLimit = isOrdered
          ? (upperLimitFromOrder < safetyLimit ? upperLimitFromOrder : safetyLimit)
          : safetyLimit;

      if (validatedAmount < minLimit) validatedAmount = minLimit;
      if (validatedAmount > finalUpperLimit) validatedAmount = finalUpperLimit;
    }

    final index = _items.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      _items[index] = _items[index].copyWith(dosePiece: validatedAmount);
    }

    // _selectedItems referansını da güncelle
    final selectedIndex = _selectedItems.indexWhere((i) => i.id == item.id);
    if (selectedIndex != -1) {
      _selectedItems[selectedIndex] = _selectedItems[selectedIndex].copyWith(dosePiece: validatedAmount);
    }

    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Sayım
  // ---------------------------------------------------------------------------

  void updateCountAmount(int index, String? val) {
    if (val == null || currentItem == null) return;
    final amount = double.tryParse(val);
    if (amount == null) return;

    _withdrawPlans[currentItem!.id]?[index].censusQuantity = amount;
    notifyListeners();
  }

  /// Sayım tipine göre her çekmece gözü için başlangıç sayım değerini belirler.
  ///
  /// - [CountType.noCount]: censusQuantity null kalır, UI'da girdi gösterilmez.
  /// - [CountType.normalCount]: Mevcut stok başlangıç değeri olarak set edilir.
  /// - [CountType.blindCount]: censusQuantity null başlar, kullanıcı girer.
  void _prepareCounting(CabinOperationItem item, List<WithdrawDetail> details) {
    final drug = item.medicine as Drug?;
    final countType = drug?.countType;

    for (final detail in details) {
      if (countType == CountType.noCount) {
        detail.censusQuantity = null;
      } else if (countType == CountType.normalCount) {
        final rawStock =
            item.assignment?.stocks?.firstWhereOrNull((s) => s.id == detail.stockId)?.quantity?.toDouble() ?? 0.0;
        detail.censusQuantity = item.assignment?.toDisplayQuantity(rawStock) ?? rawStock;
      } else if (countType == CountType.blindCount) {
        detail.censusQuantity = null;
      }
    }
  }
}
