import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

import '../../../hospitalization/domain/entity/hospitalization.dart';

import '../../../medicine_management/domain/entity/cabin_operation_item.dart';

import '../../domain/usecase/dispose_medicine_usecase.dart';
import '../../domain/usecase/get_disposables_usecase.dart';

enum DisposeType {
  wastage('Fire'),
  destruction('İmha');

  final String label;
  const DisposeType(this.label);
}

class DisposalNotifier extends ChangeNotifier with ApiRequestMixin {
  final Hospitalization? _hospitalization;
  final GetDisposablesUseCase _getDisposablesUseCase;
  final GetCurrentStationUseCase _getCurrentStationUseCase;
  final DisposeMedicineUseCase _disposeMedicineUseCase;

  /// Doğrulama tamamlandığında (şahit onaylandı veya şahit gerekmiyorsa)
  /// tetiklenen callback. DisposalInputView bu callback üzerinden açılır.
  final Future<void> Function(DisposalNotifier notifier) onVerificationCompleted;

  DisposalNotifier({
    required GetDisposablesUseCase getDisposablesUseCase,
    required GetCurrentStationUseCase getCurrentStationUseCase,
    required DisposeMedicineUseCase disposeMedicineUseCase,
    required this.onVerificationCompleted,
    Hospitalization? hospitalization,
  }) : _getDisposablesUseCase = getDisposablesUseCase,
       _getCurrentStationUseCase = getCurrentStationUseCase,
       _disposeMedicineUseCase = disposeMedicineUseCase,
       _hospitalization = hospitalization;

  OperationKey fetchOp = OperationKey.fetch();
  OperationKey fetchStationOp = OperationKey.fetch();
  OperationKey submitOp = OperationKey.custom('submit');

  bool get isFetching => isLoading(fetchOp);
  bool get isEmpty => _items.isEmpty;

  Station? _currentStation;
  Station? get currentStation => _currentStation;

  List<CabinOperationItem> _items = [];
  List<CabinOperationItem> get items => _items;

  CabinOperationItem? _selectedItem;
  CabinOperationItem? get selectedItem => _selectedItem;

  Set<int> _completedItemIds = {};
  Set<int> get completedItemIds => _completedItemIds;

  DisposeType _type = DisposeType.wastage;
  DisposeType get type => _type;
  int get selectedTypeIndex => DisposeType.values.indexOf(_type);

  double? _disposableAmount;
  double? get disposableAmount => _disposableAmount ?? _selectedItem?.dosePiece;

  String get doseUnit => (_selectedItem?.medicine as Drug?)?.doseUnit?.name ?? 'Adet';

  String? get destructionNote => (_selectedItem?.medicine as Drug?)?.destructionNote;

  void initialize() async {
    await execute(
      fetchStationOp,
      operation: () => _getCurrentStationUseCase.call(),
      onData: (station) {
        _currentStation = station;
        _getDisposables();
      },
      onFailed: (_) => _getDisposables(),
    );
  }

  void _getDisposables() async {
    await execute(
      fetchOp,
      operation: () => _getDisposablesUseCase.call(_hospitalization?.id ?? 0),
      onData: (data) {
        // GetDisposablesUseCase artık List<CabinOperationItem> döndürüyor
        _items = data;
        notifyListeners();
      },
    );
  }

  void selectItem(CabinOperationItem item) {
    if (_selectedItem?.id == item.id) {
      _selectedItem = null;
    } else {
      _selectedItem = item;
    }
    notifyListeners();
  }

  /// Şahit havuzuna yeni bir kullanıcı ekler.
  /// WithdrawNotifier.addWitness ile aynı mantık:
  /// - Seçili item'a doğrudan atar
  /// - Diğer itemlara witnesses listesi uygunsa otomatik atar
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

    // selectedItem referansını güncelle
    _selectedItem = _items.firstWhere((i) => i.id == selectedItem.id, orElse: () => selectedItem);

    notifyListeners();
  }

  /// Fire/imha işlemini başlatan metod.
  /// - İstasyon bu işlem için yetkisizse hata döner.
  /// - Şahit gerekiyorsa ve henüz atanmamışsa hata döner.
  /// - Her şey uygunsa [onVerificationCompleted] tetiklenir.
  void startOperation({Function(String msg)? onFailed}) async {
    if (_selectedItem == null) return;

    // İstasyon kontrolü
    final stations = _selectedItem!.stations;
    final stationAllowed = stations.isEmpty || stations.any((s) => s.id == _currentStation?.id);

    if (!stationAllowed) {
      onFailed?.call('Seçili ilaç için istasyonun Fire/İmha yetkisi bulunmamaktadır.');
      return;
    }

    // Şahit kontrolü
    if (_selectedItem!.needsWitness(currentStation: _currentStation) && _selectedItem!.witness == null) {
      onFailed?.call('Şahit girişi yapılması gerekmektedir.');
      return;
    }

    _disposableAmount = null;
    await onVerificationCompleted(this);
  }

  Future<void> submit({Function(String? message)? onSuccess, Function(String? message)? onFailed}) async {
    if (disposableAmount == null || disposableAmount == 0) {
      onFailed?.call('Lütfen geçerli bir miktar giriniz.');
      return;
    }

    await executeVoid(
      submitOp,
      operation: () => _disposeMedicineUseCase.call(
        DisposeMedicineParams(
          type: type,
          prescriptionDetailId: _selectedItem?.id ?? 0,
          witnessId: _selectedItem?.witness?.id,
          dosePiece: disposableAmount ?? 0.0,
        ),
      ),
      onSuccess: () {
        onSuccess?.call('Fire/İmha işlemi başarılı.');
        if (_selectedItem != null) {
          _completedItemIds.add(_selectedItem!.id);
        }
        _selectedItem = null;
        _disposableAmount = null;
        _getDisposables();
      },
      onFailed: (error) => onFailed?.call(error.message),
    );
  }

  void changeType(int index) {
    _type = DisposeType.values.elementAt(index);
    notifyListeners();
  }

  void changeAmount(String? value, {Function(String msg)? onFailed}) {
    if (value == null) return;
    final parsed = double.tryParse(value);
    if (parsed == null) return;

    final dosePiece = _selectedItem?.dosePiece;
    if (parsed > (dosePiece ?? 1000000)) {
      onFailed?.call('${_type.label} edilecek miktar alım miktarından fazla olamaz.');
      return;
    }
    if (parsed <= 0) {
      onFailed?.call('Miktar 0 olamaz.');
      return;
    }

    _disposableAmount = parsed;
    notifyListeners();
  }
}
