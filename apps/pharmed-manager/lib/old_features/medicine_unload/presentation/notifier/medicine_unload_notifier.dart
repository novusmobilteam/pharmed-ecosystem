import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

import '../../../cabin/domain/entity/cabin_input_data.dart';
import '../../domain/usecase/unload_medicine_usecase.dart';

enum UnloadType { basic, deleteAssignment, changeAssignment }

class MedicineUnloadNotifier extends ChangeNotifier with ApiRequestMixin {
  final UnloadMedicineUseCase _unloadMedicineUseCase;
  //final DeleteAssignmentUseCase _deleteAssignmentUseCase;

  MedicineUnloadNotifier({
    required UnloadMedicineUseCase unloadMedicineUseCase,
    //required DeleteAssignmentUseCase deleteAssignmentUseCase,
  }) : _unloadMedicineUseCase = unloadMedicineUseCase;

  OperationKey unloadOp = OperationKey.custom('unload');
  OperationKey deleteOp = OperationKey.custom('delete-assignment');
  OperationKey changeOp = OperationKey.custom('change-assignment');

  UnloadType? _completedType;
  UnloadType? get completedType => _completedType;

  Future<void> completeUnload(
    UnloadType type,
    List<CabinInputData> inputs, {
    Function(String? msg)? onFailed,
    Function(String? msg)? onSuccess,
  }) async {
    // Her zaman önce boşalt
    await unloadCabin(inputs);
    if (hasError(unloadOp)) return;

    // Sadece sil tipinde atamayı sil
    if (type == UnloadType.deleteAssignment) {
      await deleteAssignment(inputs, onFailed: onFailed, onSuccess: onSuccess);
      if (hasError(deleteOp)) return;
    }

    _completedType = type;
    notifyListeners();
  }

  Future unloadCabin(
    List<CabinInputData> inputs, {
    Function(String? msg)? onFailed,
    Function(String? msg)? onSuccess,
  }) async {
    await executeVoid(
      unloadOp,
      operation: () {
        final data = inputs.map((e) {
          return UnloadMedicineParams(
            materialId: e.materialId,
            cabinDrawerDetailId: e.cabinDrawerDetailId ?? 0,
            countQuantity: e.censusQuantity,
            quantity: e.quantity,
            miadDate: e.miadDate,
            shelfNo: e.shelfNo ?? 0,
            compartmentNo: e.compartmentNo ?? 0,
          );
        }).toList();

        return _unloadMedicineUseCase.call(data);
      },
      onFailed: (error) => onFailed?.call(error.message),
      onSuccess: () => onSuccess?.call('İlaç boşaltma işlemi başarıyla tamamlandı.'),
    );
  }

  Future deleteAssignment(
    List<CabinInputData> inputs, {
    Function(String? msg)? onFailed,
    Function(String? msg)? onSuccess,
  }) async {
    //final id = inputs.first.assignment?.cabinDrawerId ?? 0;
    // await executeVoid(
    //   deleteOp,
    //   operation: () => _deleteAssignmentUseCase.call(id),
    //   onFailed: (error) => onFailed?.call(error.message),
    //   onSuccess: () => onSuccess?.call('İlaç ataması silme işlemi başarıyla tamamlandı.'),
    // );
  }
}
