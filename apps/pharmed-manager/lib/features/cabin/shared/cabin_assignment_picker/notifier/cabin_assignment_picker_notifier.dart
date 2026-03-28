import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

import '../../../../cabin_assignment/domain/entity/cabin_assignment.dart';
import '../../../../cabin_assignment/domain/usecase/get_cabin_assignments_usecase.dart';
import '../../cabin_inventory/notifier/cabin_inventory_notifier.dart';

class CabinAssignmentPickerNotifier extends ChangeNotifier with ApiRequestMixin, SearchMixin<CabinAssignment> {
  final GetCabinAssignmentsUseCase _getCabinAssignmetsUseCase;
  final CabinOperationCallback onSave;
  final List<CabinAssignment>? externalAssignments;
  Function(CabinAssignment assignment)? onExecuteNext;

  CabinAssignmentPickerNotifier({
    required GetCabinAssignmentsUseCase getCabinAssignmetsUseCase,
    required this.onSave,
    this.externalAssignments,
  }) : _getCabinAssignmetsUseCase = getCabinAssignmetsUseCase {
    if (externalAssignments != null && externalAssignments!.isNotEmpty) {
      allItems = externalAssignments!;
    }
  }

  OperationKey fetchOp = OperationKey.fetch();
  bool get isFetching => isLoading(fetchOp);

  int? _expandedMedicineId;
  int? get expandedMedicineId => _expandedMedicineId;

  // --- Selection & Tracking ---
  final Set<int> _selectedAssignmentIds = {};
  final Set<int> _completedAssignmentIds = {};
  final Set<int> _cancelledAssignmentIds = {}; // İptal edilenleri takip için

  Set<int> get selectedAssignmentIds => _selectedAssignmentIds;
  Set<int> get completedAssignmentIds => _completedAssignmentIds;
  Set<int> get cancelledAssignmentIds => _cancelledAssignmentIds;

  List<CabinAssignment> get selectedAssignments =>
      allItems.where((item) => _selectedAssignmentIds.contains(item.id)).toList();

  // --- Sequential Process ---
  List<CabinAssignment> _queue = [];
  bool _isAutoProcessing = false;
  bool get isAutoProcessing => _isAutoProcessing;

  /// Wrapper'dan gelen sonuç: true (kaydedildi), false (vazgeçildi)
  bool _isProcessCompleted = false;
  bool get isProcessCompleted => _isProcessCompleted;
  set isProcessCompleted(bool val) {
    _isProcessCompleted = val;
    notifyListeners();
  }

  // --- Search ---
  @override
  List<CabinAssignment> get filteredItems {
    return _groupMedicines(super.filteredItems);
  }

  // --- Methods ---

  Future<void> getAssignments() async {
    if (externalAssignments != null && externalAssignments!.isNotEmpty) return;

    await execute(fetchOp, operation: () => _getCabinAssignmetsUseCase.call(), onData: (data) => allItems = data);
  }

  void toggleExpansion(int medicineId) {
    _expandedMedicineId = (_expandedMedicineId == medicineId) ? null : medicineId;
    notifyListeners();
  }

  void toggleDrawerSelection(int drawerId) {
    if (_selectedAssignmentIds.contains(drawerId)) {
      _selectedAssignmentIds.remove(drawerId);
      _completedAssignmentIds.remove(drawerId);
      _cancelledAssignmentIds.remove(drawerId);
    } else {
      _selectedAssignmentIds.add(drawerId);
    }
    notifyListeners();
  }

  void startSequentialProcess() {
    // Sadece henüz tamamlanmamış olanları kuyruğa al
    _queue = selectedAssignments.where((a) => !_completedAssignmentIds.contains(a.id)).toList();
    if (_queue.isNotEmpty) {
      _isAutoProcessing = true;
      _executeNext();
    }
  }

  /// İşlem başarılı bittiyse "Done", iptal edildiyse "Cancelled" olarak işaretle
  void markCurrentAsDone(CabinAssignment assignment, {required bool isSuccess}) {
    if (assignment.id == null) return;

    if (isSuccess) {
      _completedAssignmentIds.add(assignment.id!);
      _cancelledAssignmentIds.remove(assignment.id!); // Başarılıysa iptal listesinden çıkar
    } else {
      _cancelledAssignmentIds.add(assignment.id!);
      // Başarısız olsa bile completed listesinde değil ki tekrar işlem yapılabilsin
    }

    // Her durumda kuyruktan çıkar (kuyruk o anki "akışı" temsil eder)
    _queue.removeWhere((a) => a.id == assignment.id);
    notifyListeners();
  }

  void proceedToNext() {
    // Burada isProcessCompleted (yani showDialog'un sonucu) false olsa bile
    // eğer kuyrukta eleman varsa devam ediyoruz.
    if (_isAutoProcessing && _queue.isNotEmpty) {
      _executeNext();
    } else {
      _isAutoProcessing = false;
      getAssignments(); // Liste tazeleme
    }
  }

  void _executeNext() {
    if (_queue.isEmpty) {
      _isAutoProcessing = false;
      notifyListeners();
      getAssignments();
      return;
    }
    final currentTask = _queue.first;
    onExecuteNext?.call(currentTask);
  }

  List<CabinAssignment> _groupMedicines(List<CabinAssignment> items) {
    final Map<int, CabinAssignment> uniqueMedicines = {};
    for (var item in items) {
      final mId = item.medicine?.id;
      if (mId != null && !uniqueMedicines.containsKey(mId)) {
        uniqueMedicines[mId] = item;
      }
    }
    return uniqueMedicines.values.toList();
  }

  List<CabinAssignment> getAssignmentsForMedicine(int medicineId) {
    return allItems.where((item) => item.medicine?.id == medicineId).toList();
  }
}
