// [SWREQ-CLI-MUNLOAD-001] [IEC 62304 §5.5]
// Master kabin boşaltmasının seçim fazı: istasyondaki tüm kabinlerin
// atamalarını çeker (kabin seçim adımı yok), stoklu gözlerin seçimini
// kabinler arası yönetir, atama silme/değiştirme işlemlerini yürütür ve
// kuyruğu kabin sırasıyla hazırlayıp execution notifier'a devreder.
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../core/hardware/hardware.dart';
import '../../../../core/mixins/mixins.dart';
import '../../../../core/providers/providers.dart';
import '../../../dashboard/dashboard.dart';

final masterUnloadSelectionNotifierProvider = ChangeNotifierProvider.autoDispose<MasterUnloadSelectionNotifier>((ref) {
  return MasterUnloadSelectionNotifier(
    getAssignments: ref.read(getStationAssignmentsUseCaseProvider),
    deleteAssignment: ref.read(deleteAssignmentUseCaseProvider),
    updateAssignment: ref.read(updateMedicineAssignmentUseCaseProvider),
  );
});

class MasterUnloadSelectionNotifier extends ChangeNotifier with ApiRequestMixin {
  MasterUnloadSelectionNotifier({
    required GetStationAssignmentsUseCase getAssignments,
    required DeleteMedicineAssignmentUseCase deleteAssignment,
    required UpdateMedicineAssignmentUseCase updateAssignment,
  }) : _getAssignments = getAssignments,
       _deleteAssignment = deleteAssignment,
       _updateAssignment = updateAssignment;

  final GetStationAssignmentsUseCase _getAssignments;
  final DeleteMedicineAssignmentUseCase _deleteAssignment;
  final UpdateMedicineAssignmentUseCase _updateAssignment;

  final OperationKey fetchAssignmentsOp = OperationKey.fetch();

  final StationCabinScope scope = StationCabinScope();

  List<MedicineAssignment> _assignments = [];
  final AssignmentSelection _selection = AssignmentSelection();
  String _search = '';

  /// Silme/değiştirme isteği süren atamalar — normal gözde (false, göz id),
  /// serum avadanlığında (true, atama id; yoksa avadanlık id). Açık Raf'ta
  /// aynı avadanlıkta birden çok atama olduğundan serumda atama id'si esas.
  final Set<(bool, int)> _pendingKeys = {};

  (bool, int)? _keyOf(MedicineAssignment a) {
    final cellId = a.cabinDrawerDetailId;
    if (cellId != null) return (true, a.id ?? cellId);
    final unitId = a.cabinDrawerId;
    return unitId == null ? null : (false, unitId);
  }

  List<MedicineAssignment> get assignments => _assignments;
  Set<int> get selectedUnitIds => _selection.unitIds;
  Set<int> get selectedSerumCellIds => _selection.serumCellIds;
  String get search => _search;

  bool get isLoadingAssignments => isLoading(fetchAssignmentsOp);
  bool get isError => isFailed(fetchAssignmentsOp);

  bool isPending(MedicineAssignment a) => _pendingKeys.contains(_keyOf(a));

  List<MedicineAssignment> get visibleAssignments {
    final q = _search.trim().toLowerCase();
    final byCabin = scope.filtered(_assignments);
    if (q.isEmpty) return byCabin;
    return byCabin.where((a) {
      final name = a.medicine?.name?.toLowerCase() ?? '';
      final barcode = a.medicine?.barcode?.toLowerCase() ?? '';
      return name.contains(q) || barcode.contains(q);
    }).toList();
  }

  List<MedicineAssignment> get selectedAssignments => _selection.selectedFrom(_assignments);

  Map<int, int> get selectedCountByCabin => scope.countByCabin(selectedAssignments);

  bool get canStart => _selection.isNotEmpty;

  /// Boşaltılacak bir şey olmalı — stoğu olmayan göz seçilemez.
  bool canSelect(MedicineAssignment a) => a.cabinDrawerId != null && a.totalQuantity > 0;

  Future<void> init(StationCabinsContext ctx) {
    scope.attach(ctx);
    return _fetchAssignments();
  }

  Future<void> refreshAfterQueue() => _fetchAssignments();

  Future<void> _fetchAssignments() async {
    if (!scope.hasCabins) return;

    await execute(
      fetchAssignmentsOp,
      operation: () => _getAssignments.call(),
      onData: (list) {
        _assignments = scope.stationAssignments(list);
        _selection.clear();
        notifyListeners();
      },
    );
  }

  void viewCabin(int cabinId) {
    if (scope.view(cabinId)) notifyListeners();
  }

  void setCabinFilter(int? cabinId) {
    if (scope.setFilter(cabinId)) notifyListeners();
  }

  void onSearchChanged(String value) {
    _search = value;
    notifyListeners();
  }

  /// Seçili değilse yalnızca stoklu göz eklenir; seçiliyse her zaman
  /// kaldırılabilir (yenileme sonrası stok sıfıra düşmüş olabilir).
  void toggleUnit(int cabinDrawerId) =>
      _toggleAssignment(AssignmentSelection.unitAssignment(cabinDrawerId, _assignments));

  /// Serum avadanlığı — normal gözle aynı kurallar.
  void toggleSerumTray(int cellId) => _toggleAssignment(AssignmentSelection.serumAssignment(cellId, _assignments));

  /// Atama bazında seçim — Açık Raf'ta aynı avadanlıktaki ilaçlar ayrı seçilir.
  void toggleAssignment(MedicineAssignment assignment) => _toggleAssignment(assignment);

  bool isSelected(MedicineAssignment assignment) => _selection.contains(assignment);

  void _toggleAssignment(MedicineAssignment? assignment) {
    if (assignment == null) return;
    if (_selection.remove(assignment)) {
      notifyListeners();
      return;
    }
    if (!canSelect(assignment)) return;
    _selection.add(assignment);
    // Listeden başka bir kabinin kalemi seçilince iç yerleşim o kabine geçer.
    scope.view(scope.cabinIdOf(assignment));
    notifyListeners();
  }

  void toggleDrawer(DrawerGroup group) {
    final selectable = AssignmentSelection.inGroup(group, _assignments).where(canSelect);
    if (_selection.toggleAll(selectable)) notifyListeners();
  }

  void startUnload({
    required void Function(List<CabinOperationDrawerJob> jobs, int skippedCount) onQueueReady,
    required void Function(CabinOperationFailure failure) onFailed,
  }) {
    if (!canStart) return;

    final result = CabinOperationQueueBuilder.build(
      items: selectedAssignments,
      assignmentOf: (a) => a,
      targetOf: (_, a) => CabinOperationTarget.fromAssignment(a, CabinOperationMode.unload),
      cabinOrder: scope.cabinOrder,
      groups: scope.allGroups,
    );

    if (result.jobs.isEmpty) {
      onFailed(const CabinValidationFailure(reason: CabinValidationReason.noDrawerFound));
      return;
    }

    if (result.skipped.isNotEmpty) {
      MedLogger.warn(
        unit: 'MasterUnload',
        swreq: 'SWREQ-CLI-MUNLOAD-002',
        message: 'Bazı seçimler fiziksel çekmece kimliği çözülemediği için kuyruğa alınamadı',
        context: {
          'skippedCount': result.skipped.length,
          'skippedMedicineIds': result.skipped.map((a) => a.medicine?.id).toList(),
        },
      );
    }

    onQueueReady(scope.withCabinIds(result.jobs), result.skipped.length);
  }

  // ── Atama işlemleri ───────────────────────────────────────────────────

  /// Atamayı tamamen kaldırır ve listeyi yeniden çeker.
  Future<void> deleteAssignment(
    MedicineAssignment assignment, {
    VoidCallback? onSuccess,
    ValueChanged<String?>? onFailed,
  }) async {
    final key = _keyOf(assignment);
    if (key == null) return;

    _pendingKeys.add(key);
    notifyListeners();

    // Serum avadanlığı ataması avadanlık kimliğiyle silinir. Normal gözde
    // eski davranış korunarak GÖZ kimliği gönderiliyor. Use case ATAMA
    // kimliği (assignment.id) bekliyorsa bu, başka bir atamanın silinmesine
    // yol açar — doğrulanmalı.
    final serumCellId = assignment.cabinDrawerDetailId;
    final result = serumCellId != null
        ? await _deleteSerumAssignment(assignment, serumCellId)
        : await _deleteAssignment.call(key.$2);

    _pendingKeys.remove(key);
    await result.when(
      ok: (_) async {
        onSuccess?.call();
        await _fetchAssignments();
      },
      error: (e) async {
        notifyListeners();
        onFailed?.call(e.message);
      },
    );
  }

  /// Serum ataması avadanlık kimliğiyle silinir. Açık Raf'ta aynı avadanlıkta
  /// başka ilaç da varsa avadanlık bazlı silme hepsini etkileyebileceği için
  /// (backend davranışı doğrulanana kadar) reddedilir.
  Future<Result<void>> _deleteSerumAssignment(MedicineAssignment assignment, int cellId) async {
    final others = AssignmentSelection.serumAssignments(cellId, _assignments).where((a) => a.id != assignment.id);
    if (others.isNotEmpty) {
      return Result.error(
        BusinessRuleException(
          message: contextlessL10n().cabinOperation_openShelfDeleteNotSupported,
          ruleCode: 'OPEN_SHELF_SINGLE_DELETE',
        ),
      );
    }
    return _deleteAssignment.serumTray(cellId);
  }

  /// Atamanın ilacını değiştirir (muadil ya da tüm ilaç listesinden).
  Future<void> replaceAssignment(
    MedicineAssignment assignment,
    Medicine newMedicine, {
    VoidCallback? onSuccess,
    ValueChanged<String?>? onFailed,
  }) async {
    final key = _keyOf(assignment);
    if (key == null || assignment.id == null) return;

    _pendingKeys.add(key);
    notifyListeners();

    // NOT: Gözdeki stoğa dokunulmaz — stoklu gözde ilaç değiştirilirse stok
    // yeni ilacınmış gibi görünür. Yalnızca boş gözde mi izin verilmeli?
    final result = await _updateAssignment.call(assignment.copyWith(medicine: newMedicine));

    _pendingKeys.remove(key);
    await result.when(
      ok: (_) async {
        onSuccess?.call();
        await _fetchAssignments();
      },
      error: (e) async {
        notifyListeners();
        onFailed?.call(e.message);
      },
    );
  }
}
