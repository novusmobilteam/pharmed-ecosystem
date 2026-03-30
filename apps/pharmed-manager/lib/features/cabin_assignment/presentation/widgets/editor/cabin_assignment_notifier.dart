import 'package:flutter/material.dart';
import '../../../../../core/core.dart';

import '../../../../cabin/shared/widgets/cabin_editor/cabin_editor_mixin.dart';

class CabinAssignmentNotifier extends ChangeNotifier with ApiRequestMixin, CabinEditorMixin {
  @override
  final GetCabinsUseCase cabinsUseCase;
  @override
  final GetCabinLayoutUseCase layoutUseCase;

  final GetAssignmentsUseCase _getAssignmentsUseCase;
  final GetCabinsByStationUseCase _getCabinsByStationUseCase;

  final UpdateAssignmentUseCase _updateAssignmentUseCase;
  final DeleteAssignmentUseCase _deleteAssignmentUseCase;

  CabinAssignmentNotifier({
    required this.cabinsUseCase,
    required this.layoutUseCase,
    required GetCabinsByStationUseCase getCabinsByStationUseCase,
    required GetAssignmentsUseCase getAssignmentsUseCase,
    required UpdateAssignmentUseCase updateAssignmentUseCase,
    required DeleteAssignmentUseCase deleteAssignmentUseCase,
  }) : _getCabinsByStationUseCase = getCabinsByStationUseCase,
       _getAssignmentsUseCase = getAssignmentsUseCase,
       _updateAssignmentUseCase = updateAssignmentUseCase,
       _deleteAssignmentUseCase = deleteAssignmentUseCase;

  // Operation Keys
  OperationKey deleteOp = OperationKey.delete();

  List<CabinAssignment> _assignments = [];
  List<CabinAssignment> get assignments => _assignments;

  @override
  void onLayoutRefreshed(List<DrawerGroup> groups) {
    _fetchAssignments();
  }

  Future<void> initialize({int? stationId}) async {
    await executeVoid(
      fetchCabinOp,
      operation: () async {
        final res = stationId != null ? await _getCabinsByStationUseCase.call(stationId) : await cabinsUseCase.call();

        return res.when(
          error: (e) => Result.error(e),
          ok: (data) async {
            setCabins(data);
            if (data.isNotEmpty) {
              selectCabin(data.first);
              await refreshLayout();
            } else {
              selectCabin(null);
              _assignments = [];
              notifyListeners();
            }
            return Result.ok(null);
          },
        );
      },
    );
  }

  Future<void> _fetchAssignments() async {
    if (selectedCabin == null) return;

    final res = await _getAssignmentsUseCase.call(selectedCabin!.id!);
    res.when(
      ok: (data) {
        _assignments = data;
        notifyListeners();
      },
      error: (e) => debugPrint("Atama çekme hatası: $e"),
    );
  }

  CabinAssignment getAssignmentForUnit(int? unitId) {
    if (unitId == null) {
      return CabinAssignment.empty(cabinId: selectedCabin?.id ?? 0, cabinDrawerId: unitId ?? 0);
    }

    try {
      // Listede bu unitId'ye ait bir atama kaydı var mı?
      return _assignments.firstWhere((a) => a.cabinDrawerId == unitId);
    } catch (e) {
      // Eğer atama yoksa (boş hücre), boş bir atama nesnesi dön
      return CabinAssignment.empty(cabinId: selectedCabin?.id ?? 0, cabinDrawerId: unitId);
    }
  }

  /// Sayfa ilk açıldığında
  Future<void> updateAssignment(int unitId, CabinAssignment newAssignment) async {
    final updateKey = OperationKey.custom('update_assignment_$unitId');

    await executeVoid(
      updateKey,
      operation: () => _updateAssignmentUseCase.call(newAssignment),
      onSuccess: () => _fetchAssignments(),
    );
  }

  Future<void> deleteAssignment(
    CabinAssignment assignment, {
    Function(String? message)? onSuccess,
    Function(String? message)? onFailed,
  }) async {
    await executeVoid(
      deleteOp,
      operation: () => _deleteAssignmentUseCase.call(assignment.cabinDrawerId ?? 0),
      onSuccess: () {
        _fetchAssignments();
        onSuccess?.call('Atama kaydı başarıyla kaldırıldı.');
      },
      onFailed: (error) => onFailed?.call(error.message),
    );
  }

  Future<void> refreshCabinData() async {
    if (selectedCabin?.id != null) {
      await _fetchAssignments();
    }
  }
}
