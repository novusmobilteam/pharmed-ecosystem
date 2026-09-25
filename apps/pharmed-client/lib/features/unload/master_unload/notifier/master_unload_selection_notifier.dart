// [SWREQ-CLI-MUNLOAD-001] [IEC 62304 §5.5]
// Master kabin boşaltmasının seçim fazı: seçilen kabinin atamalarını çeker,
// stoklu gözlerin seçimini yönetir, atama silme/değiştirme işlemlerini
// yürütür ve kuyruğu hazırlayıp execution notifier'a devreder.
//
// Sınıf: Class B

import 'package:collection/collection.dart';
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
  List<MedicineAssignment> _assignments = [];
  final Set<int> _selectedUnitIds = {};
  String _search = '';

  /// Silme/değiştirme isteği süren gözler (göz kimliği — liste satırları
  /// bu kimlikle tanınır).
  final Set<int> _pendingUnitIds = {};

  List<MedicineAssignment> get assignments => _assignments;
  Set<int> get selectedUnitIds => Set.unmodifiable(_selectedUnitIds);
  String get search => _search;

  bool get isLoadingAssignments => isLoading(fetchAssignmentsOp);
  bool get isError => isFailed(fetchAssignmentsOp);

  bool isPending(MedicineAssignment a) => _pendingUnitIds.contains(a.cabinDrawerId);

  List<MedicineAssignment> get visibleAssignments {
    final q = _search.trim().toLowerCase();
    if (q.isEmpty) return _assignments;
    return _assignments.where((a) {
      final name = a.medicine?.name?.toLowerCase() ?? '';
      final barcode = a.medicine?.barcode?.toLowerCase() ?? '';
      return name.contains(q) || barcode.contains(q);
    }).toList();
  }

  List<MedicineAssignment> get selectedAssignments =>
      _assignments.where((a) => _selectedUnitIds.contains(a.cabinDrawerId)).toList();

  bool get canStart => _selectedUnitIds.isNotEmpty;

  /// Boşaltılacak bir şey olmalı — stoğu olmayan göz seçilemez.
  bool canSelect(MedicineAssignment a) => a.cabinDrawerId != null && a.totalQuantity > 0;

  Future<void> init(CabinRouteContext ctx) {
    _cabinId = ctx.cabin?.id;
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
        _selectedUnitIds.clear();
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
  void toggleUnit(int cabinDrawerId) {
    if (_selectedUnitIds.remove(cabinDrawerId)) {
      notifyListeners();
      return;
    }
    final assignment = _assignments.firstWhereOrNull((a) => a.cabinDrawerId == cabinDrawerId);
    if (assignment == null || !canSelect(assignment)) return;
    _selectedUnitIds.add(cabinDrawerId);
    notifyListeners();
  }

  void toggleDrawer(DrawerGroup group) {
    final unitIdsInGroup = group.units.map((u) => u.id).whereType<int>().toSet();
    final selectableIds = _assignments
        .where((a) => unitIdsInGroup.contains(a.cabinDrawerId) && canSelect(a))
        .map((a) => a.cabinDrawerId!)
        .toSet();
    if (selectableIds.isEmpty) return;

    selectableIds.every(_selectedUnitIds.contains)
        ? _selectedUnitIds.removeAll(selectableIds)
        : _selectedUnitIds.addAll(selectableIds);
    notifyListeners();
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
    final unitId = assignment.cabinDrawerId;
    if (unitId == null) return;

    _pendingUnitIds.add(unitId);
    notifyListeners();

    // DİKKAT: Eski davranış korunarak GÖZ kimliği gönderiliyor. Use case
    // ATAMA kimliği (assignment.id) bekliyorsa bu, başka bir atamanın
    // silinmesine yol açar — doğrulanmalı.
    final result = await _deleteAssignment.call(unitId);

    _pendingUnitIds.remove(unitId);
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
    final unitId = assignment.cabinDrawerId;
    if (unitId == null || assignment.id == null) return;

    _pendingUnitIds.add(unitId);
    notifyListeners();

    // NOT: Gözdeki stoğa dokunulmaz — stoklu gözde ilaç değiştirilirse stok
    // yeni ilacınmış gibi görünür. Yalnızca boş gözde mi izin verilmeli?
    final result = await _updateAssignment.call(assignment.copyWith(medicine: newMedicine));

    _pendingUnitIds.remove(unitId);
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
