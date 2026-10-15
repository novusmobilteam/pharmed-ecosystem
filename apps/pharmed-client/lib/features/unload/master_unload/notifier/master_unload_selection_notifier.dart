// [SWREQ-CLI-MUNLOAD-001] [IEC 62304 §5.5]
// Master kabin boşaltmasının seçim fazı: seçilen kabinin atamalarını çeker,
// stoklu gözlerin seçimini yönetir, atama silme/değiştirme işlemlerini
// yürütür ve kuyruğu hazırlayıp execution notifier'a devreder.
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
    getAssignments: ref.read(getCabinAssignmentsWitCabinUseCaseProvider),
    deleteAssignment: ref.read(deleteAssignmentUseCaseProvider),
    updateAssignment: ref.read(updateMedicineAssignmentUseCaseProvider),
  );
});

class MasterUnloadSelectionNotifier extends ChangeNotifier with ApiRequestMixin {
  MasterUnloadSelectionNotifier({
    required GetCabinAssignmentsWithCabinUseCase getAssignments,
    required DeleteMedicineAssignmentUseCase deleteAssignment,
    required UpdateMedicineAssignmentUseCase updateAssignment,
  }) : _getAssignments = getAssignments,
       _deleteAssignment = deleteAssignment,
       _updateAssignment = updateAssignment;

  final GetCabinAssignmentsWithCabinUseCase _getAssignments;
  final DeleteMedicineAssignmentUseCase _deleteAssignment;
  final UpdateMedicineAssignmentUseCase _updateAssignment;

  final OperationKey fetchAssignmentsOp = OperationKey.fetch();

  int? _cabinId;

  /// Kabin görsel verisi — serum avadanlıklarının kilit adresleri için.
  List<DrawerGroup> _groups = const [];

  List<MedicineAssignment> _assignments = [];
  final AssignmentSelection _selection = AssignmentSelection();
  String _search = '';

  /// Silme/değiştirme isteği süren atamalar — normal gözde (false, göz id),
  /// serum avadanlığında (true, avadanlık id).
  final Set<(bool, int)> _pendingKeys = {};

  (bool, int)? _keyOf(MedicineAssignment a) {
    final cellId = a.cabinDrawerDetailId;
    if (cellId != null) return (true, cellId);
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
    if (q.isEmpty) return _assignments;
    return _assignments.where((a) {
      final name = a.medicine?.name?.toLowerCase() ?? '';
      final barcode = a.medicine?.barcode?.toLowerCase() ?? '';
      return name.contains(q) || barcode.contains(q);
    }).toList();
  }

  List<MedicineAssignment> get selectedAssignments => _selection.selectedFrom(_assignments);

  bool get canStart => _selection.isNotEmpty;

  /// Boşaltılacak bir şey olmalı — stoğu olmayan göz seçilemez.
  bool canSelect(MedicineAssignment a) => a.cabinDrawerId != null && a.totalQuantity > 0;

  Future<void> init(CabinRouteContext ctx) {
    _cabinId = ctx.cabin?.id;
    _groups = ctx.cabinData?.groups ?? const <DrawerGroup>[];
    return _fetchAssignments();
  }

  Future<void> refreshAfterQueue() => _fetchAssignments();

  Future<void> _fetchAssignments() async {
    final cabinId = _cabinId;
    if (cabinId == null) return;

    await execute(
      fetchAssignmentsOp,
      operation: () => _getAssignments.call(cabinId),
      onData: (list) {
        _assignments = list;
        _selection.clear();
        notifyListeners();
      },
    );
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

  void _toggleAssignment(MedicineAssignment? assignment) {
    if (assignment == null) return;
    if (_selection.remove(assignment)) {
      notifyListeners();
      return;
    }
    if (!canSelect(assignment)) return;
    _selection.add(assignment);
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
      groups: _groups,
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

    onQueueReady(result.jobs, result.skipped.length);
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
    final (isSerumTray, id) = key;
    final result = isSerumTray ? await _deleteAssignment.serumTray(id) : await _deleteAssignment.call(id);

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
