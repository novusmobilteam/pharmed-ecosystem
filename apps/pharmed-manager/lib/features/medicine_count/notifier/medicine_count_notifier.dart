import 'package:flutter/material.dart';

import '../../../core/core.dart';
import 'package:pharmed_manager/core/core.dart';
import '../../cabin_assignment/domain/entity/cabin_assignment.dart';

import '../../cabin/domain/entity/cabin_input_data.dart';
import '../../cabin_stock/domain/usecase/count_medicine_usecase.dart';

enum MedicineCountType {
  // İlaç Bazlı
  medicine('İlaç Bazlı'),
  // Çekmece Bazlı
  drawer('Çekmece Bazlı'),
  // Kabin Bazlı
  cabin('Kabin Bazlı');

  final String title;

  const MedicineCountType(this.title);
}

class MedicineCountNotifier extends ChangeNotifier with ApiRequestMixin, SearchMixin<CabinAssignment> {
  final CountMedicineUseCase _countMedicineUseCase;
  final Future<void> Function(CabinAssignment assignment)? onOperationRequired;

  MedicineCountNotifier({required CountMedicineUseCase countMedicineUseCase, this.onOperationRequired})
    : _countMedicineUseCase = countMedicineUseCase;

  MedicineCountType _countType = MedicineCountType.medicine;
  MedicineCountType get countType => _countType;
  int get countTypeIndex => MedicineCountType.values.indexOf(_countType);

  List<CabinAssignment> _selectedAssignments = [];
  List<CabinAssignment> get selectedAssignments => _selectedAssignments;

  List<CabinAssignment> _allAssignments = [];
  List<CabinAssignment> get allAssignments => _allAssignments;
  List<CabinAssignment> _currentQueue = [];

  bool _isProcessing = false;

  bool get showStartCountButton =>
      (_countType == MedicineCountType.drawer && _selectedAssignments.isNotEmpty) ||
      _countType == MedicineCountType.cabin;

  Future<Result<void>> count(List<CabinInputData> inputs) async {
    final data = inputs.map((e) {
      return CountMedicineParams(
        e.materialId,
        e.cabinDrawerDetailId ?? 0,
        e.censusQuantity,
        e.miadDate,
        e.shelfNo ?? 0,
        e.compartmentNo ?? 0,
      );
    }).toList();

    return await _countMedicineUseCase.call(data);
  }

  void startCount() {
    List<CabinAssignment> targetList;
    if (_countType == MedicineCountType.drawer) {
      targetList = _selectedAssignments;
    } else if (_countType == MedicineCountType.cabin) {
      targetList = _allAssignments;
    } else {
      return;
    }

    if (targetList.isNotEmpty) {
      _currentQueue = List.from(targetList);
      _isProcessing = true;
      _triggerNextFromQueue();
    }
  }

  void _triggerNextFromQueue() {
    if (_currentQueue.isEmpty) {
      _isProcessing = false;
      notifyListeners();
      return;
    }

    final next = _currentQueue.first;
    onOperationRequired?.call(next); // Çekmeceyi aç
  }

  // Wrapper'ın "Bitti, sıradakini ver" dediği yer burası olacak
  void proceedToNext() {
    if (_currentQueue.isNotEmpty) {
      _currentQueue.removeAt(0); // Biteni kuyruktan at
      _triggerNextFromQueue(); // Sıradakini aç
    } else {
      _isProcessing = false;
    }
  }

  Future<void> _processNext(List<CabinAssignment> assignments) async {
    if (assignments.isEmpty || onOperationRequired == null || _isProcessing) {
      return;
    }

    _isProcessing = true;

    try {
      final nextAssignment = assignments.first;
      await onOperationRequired!(nextAssignment);
    } finally {
      _isProcessing = false;
    }
  }

  Future<Result<void>> drawerBasedCount(
    List<CabinInputData> inputs,
    CabinAssignment currentAssignment, {
    Function(String? message)? onSuccess,
    Function(String? message)? onFailed,
  }) async {
    final data = inputs.map((e) {
      return CountMedicineParams(
        e.materialId,
        e.cabinDrawerDetailId ?? 0,
        e.censusQuantity,
        e.miadDate,
        e.shelfNo ?? 0,
        e.compartmentNo ?? 0,
      );
    }).toList();

    final result = await _countMedicineUseCase.call(data);
    result.when(
      ok: (_) async {
        _selectedAssignments.removeWhere((element) => element.id == currentAssignment.id);

        // 2. Başarı mesajını UI'a bildir
        onSuccess?.call("${currentAssignment.medicine?.name} sayımı kaydedildi.");

        // 3. Eğer hala stok varsa bir sonrakine geç
        if (_selectedAssignments.isNotEmpty) {
          await Future.delayed(const Duration(milliseconds: 400));
          await _processNext(_selectedAssignments);
        } else {
          onSuccess?.call("COMPLETED");
        }
      },
      error: (error) => onFailed?.call(error.message),
    );

    return result;
  }

  Future<Result<void>> cabinBasedCount(
    List<CabinInputData> inputs,
    CabinAssignment currentAssignment, {
    Function(String? message)? onSuccess,
    Function(String? message)? onFailed,
  }) async {
    final data = inputs.map((e) {
      return CountMedicineParams(
        e.materialId,
        e.cabinDrawerDetailId ?? 0,
        e.censusQuantity,
        e.miadDate,
        e.shelfNo ?? 0,
        e.compartmentNo ?? 0,
      );
    }).toList();

    final result = await _countMedicineUseCase.call(data);
    result.when(
      ok: (_) async {
        // 1. Listeden temizle
        _allAssignments.removeWhere((element) => element.id == currentAssignment.id);

        // 2. Başarı mesajını UI'a bildir
        onSuccess?.call("${currentAssignment.medicine?.name} sayımı kaydedildi.");

        // 3. Eğer hala stok varsa bir sonrakine geç
        if (_allAssignments.isNotEmpty) {
          await Future.delayed(const Duration(milliseconds: 400));
          await _processNext(_allAssignments);
        } else {
          onSuccess?.call("COMPLETED");
        }
      },
      error: (error) => onFailed?.call(error.message),
    );

    return result;
  }

  void changeCountType(int index) {
    _countType = MedicineCountType.values.elementAt(index);

    notifyListeners();
  }

  void setAllAssignments(List<CabinAssignment> assignments) {
    _allAssignments = List.from(assignments);

    notifyListeners();
  }

  void setSelectedAssignments(List<CabinAssignment> assignments) {
    _selectedAssignments = List.from(assignments);
    notifyListeners();
  }

  void selectAssignment(CabinAssignment assignment) {
    if (_selectedAssignments.contains(assignment)) {
      _selectedAssignments.remove(assignment);
    } else {
      _selectedAssignments.add(assignment);
    }

    notifyListeners();
  }
}
