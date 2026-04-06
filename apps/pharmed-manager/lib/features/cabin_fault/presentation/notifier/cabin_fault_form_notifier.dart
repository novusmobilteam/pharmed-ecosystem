import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

class CabinFaultFormNotifier extends ChangeNotifier with ApiRequestMixin {
  final CreateFaultRecordUseCase _createUseCase;
  final ClearFaultRecordUseCase _clearUseCase;
  final int slotId;

  CabinFaultFormNotifier({
    required CreateFaultRecordUseCase createUseCase,
    required ClearFaultRecordUseCase clearUseCase,
    required this.slotId,
    Fault? activeFault,
  }) : _createUseCase = createUseCase,
       _clearUseCase = clearUseCase {
    if (activeFault != null && activeFault.id != null) {
      // Mevcut aktif arıza varsa onu kullan
      _activeFault = activeFault;
      _isNewRecord = false;
      _selectedStatusIndex = activeFault.workingStatus == CabinWorkingStatus.maintenance ? 1 : 0;
    } else {
      _isNewRecord = true;
      _activeFault = Fault(
        slotId: slotId,
        startDate: DateTime.now(),
        workingStatus: CabinWorkingStatus.faulty, // Default: Arıza
      );
      _selectedStatusIndex = 0;
    }
  }

  OperationKey submitOp = OperationKey.submit();

  late Fault _activeFault;
  Fault get activeFault => _activeFault;

  late bool _isNewRecord;
  bool get isNewRecord => _isNewRecord;

  int _selectedStatusIndex = 0;
  int get selectedStatusIndex => _selectedStatusIndex;

  void setStatusIndex(int index) {
    if (!_isNewRecord) return;

    _selectedStatusIndex = index;
    final status = index == 0 ? CabinWorkingStatus.faulty : CabinWorkingStatus.maintenance;

    _activeFault = _activeFault.copyWith(workingStatus: status);

    notifyListeners();
  }

  void updateDescription(String? value) {
    _activeFault = _activeFault.copyWith(description: value);
  }

  Future<void> submit({Function(String? message)? onSuccess, Function(String? message)? onFailed}) async {
    // Kapatma işlemiyse endDate'i şimdiye set et ki effectiveStatus 'working' dönsün
    if (!_isNewRecord) {
      _activeFault = _activeFault.copyWith(endDate: DateTime.now());
    }

    // UseCase'in beklediği ortak parametre objesi
    final params = CreateFaultRecordParams(
      fault: _activeFault,
      slotId: slotId,
      status: _activeFault.workingStatus ?? CabinWorkingStatus.faulty,
    );

    await executeVoid(
      submitOp,
      operation: () async {
        if (!_isNewRecord) {
          return await _clearUseCase.call(params);
        } else {
          return await _createUseCase.call(params);
        }
      },
      onSuccess: () {
        final msg = _isNewRecord ? 'Kayıt başarıyla oluşturuldu.' : 'Arıza/Bakım kaydı başarıyla kapatıldı.';
        onSuccess?.call(msg);
      },
      onFailed: (error) => onFailed?.call(error.message),
    );
  }
}
