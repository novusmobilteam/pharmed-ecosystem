import 'package:flutter/material.dart';
import '../../../domain/usecase/update_assignment_usecase.dart';
import '../../../../../core/core.dart';

import '../../../domain/entity/cabin_assignment.dart';
import '../../../domain/usecase/create_assignment_usecase.dart';

enum StockType {
  drug('İlaç Atama'),
  material('Tıbbi Sarf Atama');

  final String label;

  const StockType(this.label);
}

class CabinAssignmentFormNotifier extends ChangeNotifier with ApiRequestMixin {
  final CabinAssignment initial;
  final CreateAssignmentUseCase _createAssignmentUseCase;
  final UpdateAssignmentUseCase _updateAssignmentUseCase;

  CabinAssignmentFormNotifier({
    required this.initial,
    required CreateAssignmentUseCase createAssignmentUseCase,
    required UpdateAssignmentUseCase updateAssignmentUseCase,
  }) : _createAssignmentUseCase = createAssignmentUseCase,
       _updateAssignmentUseCase = updateAssignmentUseCase {
    _assignment = initial;
  }

  OperationKey submitOp = OperationKey.custom('submit');

  late CabinAssignment _assignment;
  CabinAssignment get assignment => _assignment;

  StockType _stockType = StockType.drug;
  StockType get stockType => _stockType;

  bool _isValid = false;
  bool get isValid => _isValid;

  bool get isCreate => initial.id == null;

  // Eşdeğer ilaç seçebilir mi?
  bool get canSelectEquivalent => !isCreate && _assignment.medicine != null && _stockType == StockType.drug;

  String get label {
    if (_assignment.medicine != null) {
      return _stockType == StockType.drug ? 'Eşdeğer İlaçlar' : 'Tıbbi Sarf';
    }
    return _stockType == StockType.drug ? 'İlaç' : 'Tıbbi Sarf';
  }

  int get selectedIndex => _stockType == StockType.drug ? 0 : 1;

  Future<void> submit({Function(String? msg)? onFailed, Function(String? msg)? onSuccess}) async {
    final validationError = validateQuantities();

    await executeVoid(
      submitOp,
      operation: () async {
        if (validationError != null) {
          return Result.error(CustomException(message: validationError));
        }

        final res = initial.medicine == null
            ? await _createAssignmentUseCase.call(_assignment)
            : await _updateAssignmentUseCase.call(_assignment);

        return res;
      },
      onFailed: (error) => onFailed?.call(error.message),
      onSuccess: () => onSuccess?.call('İşleminiz başarıyla tamamlandı.'),
    );
  }

  String? validateQuantities() {
    final min = _assignment.minQuantity ?? 0;
    final max = _assignment.maxQuantity ?? 0;
    final critical = _assignment.criticalQuantity ?? 0;

    // Min-Max kontrolü
    if (min > max) {
      return "Minimum miktar, maksimum miktardan büyük olamaz";
    }

    // Kritik miktar kontrolü
    if (critical < min || critical > max) {
      return "Kritik miktar, minimum ve maksimum miktarlar arasında olmalıdır";
    }

    // Negatif değer kontrolü
    if (min < 0 || max < 0 || critical < 0) {
      return "Miktarlar negatif olamaz";
    }

    return null; // Hata yok
  }

  void setMaterial(Medicine? medicine) {
    _assignment = _assignment.copyWith(medicine: medicine);
    notifyListeners();
  }

  void setMinQuantity(String? value) {
    int? assignment = int.tryParse(value ?? "");
    _assignment = _assignment.copyWith(minQuantity: assignment);
    notifyListeners();
  }

  void setMaxQuantity(String? value) {
    int? assignment = int.tryParse(value ?? "");
    _assignment = _assignment.copyWith(maxQuantity: assignment);
    notifyListeners();
  }

  void setCriticQuantity(String? value) {
    int? assignment = int.tryParse(value ?? "");
    _assignment = _assignment.copyWith(criticalQuantity: assignment);
    notifyListeners();
  }

  void setStockType(StockType type) {
    _stockType = type;
    notifyListeners();
  }
}
