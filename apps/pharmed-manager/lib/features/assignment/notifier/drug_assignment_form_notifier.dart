import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

class DrugAssignmentFormNotifier extends ChangeNotifier with ApiRequestMixin {
  final CreateMedicineAssignmentUseCase _createAssignmentUseCase;
  final UpdateMedicineAssignmentUseCase _updateAssignmentUseCase;
  int? _cabinId;
  int? _unitId;

  DrugAssignmentFormNotifier({
    required CreateMedicineAssignmentUseCase createAssignmentUseCase,
    required UpdateMedicineAssignmentUseCase updateAssignmentUseCase,
    MedicineAssignment? assignment,
    int? cabinId,
    int? unitId,
  }) : _createAssignmentUseCase = createAssignmentUseCase,
       _updateAssignmentUseCase = updateAssignmentUseCase,
       _cabinId = cabinId,
       _unitId = unitId {
    if (assignment != null) {
      _assignment = assignment;
      return;
    }
    if (assignment == null && _cabinId != null && _unitId != null) {
      _assignment = MedicineAssignment.empty(cabinId: _cabinId!, cabinDrawerId: _unitId!);
      return;
    }
  }

  MedicineAssignment? _assignment;
  MedicineAssignment? get assignment => _assignment;

  final OperationKey _submitOp = OperationKey.submit();

  bool get isCreate => assignment?.id == null;
  bool get isSubmitting => isLoading(_submitOp);

  bool get canSave =>
      _assignment?.medicine != null &&
      _assignment?.minQuantity != null &&
      _assignment?.maxQuantity != null &&
      _assignment?.criticalQuantity != null;

  void updateMedicine(Medicine? medicine) {
    _assignment = _assignment?.copyWith(medicine: medicine);
    notifyListeners();
  }

  void updateMinQuantity(String? value) {
    if (value == null) return;
    final min = int.tryParse(value);
    _assignment = _assignment?.copyWith(minQuantity: min);
    notifyListeners();
  }

  void updateMaxQuantity(String? value) {
    if (value == null) return;
    final max = int.tryParse(value);
    _assignment = _assignment?.copyWith(maxQuantity: max);
    notifyListeners();
  }

  void updateCritQuantity(String? value) {
    if (value == null) return;
    final crit = int.tryParse(value);
    _assignment = _assignment?.copyWith(criticalQuantity: crit);
    notifyListeners();
  }

  Future<void> submit({VoidCallback? onSuccess, void Function(String? msg)? onFailed}) async {
    if (_assignment == null) return;
    await executeVoid(
      _submitOp,
      operation: () =>
          isCreate ? _createAssignmentUseCase.call(_assignment!) : _updateAssignmentUseCase.call(_assignment!),
      onFailed: (error) => onFailed?.call(error.message),
      onSuccess: () => onSuccess?.call(),
    );
  }
}
