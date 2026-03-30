import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/usecase/create_stock_transaction_usecase.dart';

import '../../../../../core/core.dart';

import '../../domain/entity/stock_transaction.dart';

/// Stok işlem formu ViewModel'i.
class StockTransactionFormNotifier extends ChangeNotifier with ApiRequestMixin {
  final CreateStockTransactionUseCase _createStockTransactionUseCase;

  final Warehouse _warehouse;
  final StockTransactionType _transactionType;

  StockTransactionFormNotifier({
    required CreateStockTransactionUseCase createStockTransactionUseCase,
    required Warehouse warehouse,
    required StockTransactionType transactionType,
  }) : _createStockTransactionUseCase = createStockTransactionUseCase,
       _warehouse = warehouse,
       _transactionType = transactionType {
    _transaction = StockTransaction(
      isSend: true,
      warehouseId: _warehouse.id,
      sendDate: DateTime.now(),
      transactionType: _transactionType,
      transactionKind: _transactionType == StockTransactionType.entry
          ? StockTransactionKind.materialPurchasing
          : StockTransactionKind.materialUse,
    );
  }

  OperationKey submitOp = OperationKey.submit();

  StockTransaction? _transaction;
  StockTransaction? get transaction => _transaction;

  bool get isSubmitting => isLoading(submitOp);
  String? get statusMessage => message(submitOp);

  Future<bool> submit() async {
    if (_warehouse.id == null) return false;

    bool success = false;

    await executeVoid(
      submitOp,
      operation: () => _createStockTransactionUseCase.call(_transaction!),
      successMessage: 'İşleminiz başarıyla tamamlanmıştır.',
    );

    return success;
  }

  void updateMaterial(Medicine? value) {
    _transaction = _transaction?.copyWith(medicine: value);
    notifyListeners();
  }

  void updateQuantity(int? value) {
    _transaction = _transaction?.copyWith(quantity: value);
    notifyListeners();
  }

  void updateService(HospitalService? value) {
    _transaction = _transaction?.copyWith(service: value);
    notifyListeners();
  }

  void updateExpirationDate(String? value) {
    if (value == null) return;
    final err = Validators.validateDate(value);
    if (err != null) return;
    final parsed = DateFormat('dd/MM/yyyy').parseStrict(value);
    _transaction = _transaction?.copyWith(expirationDate: parsed);
    notifyListeners();
  }
}
