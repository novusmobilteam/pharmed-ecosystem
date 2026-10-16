// [SWREQ-CLI-MREFILL-001] [IEC 62304 §5.5]
// Master kabin dolumunun seçim fazı: seçilen kabinin atamalarını çeker,
// göz/çekmece seçimini yönetir, kuyruğu hazırlayıp execution notifier'a devreder.
// Serum avadanlıkları (cabinDrawerDetailId'li atamalar) göz bazında seçilir.
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

final masterRefillSelectionNotifierProvider = ChangeNotifierProvider.autoDispose<MasterRefillSelectionNotifier>((ref) {
  return MasterRefillSelectionNotifier(getAssignments: ref.read(getCabinAssignmentsWitCabinUseCaseProvider));
});

class MasterRefillSelectionNotifier extends ChangeNotifier with ApiRequestMixin {
  MasterRefillSelectionNotifier({required GetCabinAssignmentsWithCabinUseCase getAssignments})
    : _getAssignments = getAssignments;

  final GetCabinAssignmentsWithCabinUseCase _getAssignments;

  final OperationKey fetchAssignmentsOp = OperationKey.fetch();

  int? _cabinId;
  List<MedicineAssignment> _assignments = [];
  final AssignmentSelection _selection = AssignmentSelection();
  String _search = '';

  List<MedicineAssignment> get assignments => _assignments;
  Set<int> get selectedUnitIds => _selection.unitIds;
  Set<int> get selectedSerumCellIds => _selection.serumCellIds;
  String get search => _search;

  bool get isLoadingAssignments => isLoading(fetchAssignmentsOp);
  bool get isError => isFailed(fetchAssignmentsOp);

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

  Future<void> init(CabinRouteContext ctx) {
    _cabinId = ctx.cabin?.id;
    return _fetchAssignments();
  }

  /// Kuyruk bittiğinde/durdurulduğunda — stoklar değişti, baştan çekilir.
  Future<void> refreshAfterQueue() => _fetchAssignments();

  Future<void> _fetchAssignments() async {
    final cabinId = _cabinId;
    if (cabinId == null) return;

    await execute(
      fetchAssignmentsOp,
      operation: () => _getAssignments.call(cabinId),
      onData: (list) {
        _assignments = list;
        _selection.clear(); // doldurulan gözler işaretli kalmasın
        notifyListeners();
      },
    );
  }

  void onSearchChanged(String value) {
    _search = value;
    notifyListeners();
  }

  void toggleUnit(int cabinDrawerId) {
    final assignment = AssignmentSelection.unitAssignment(cabinDrawerId, _assignments);
    if (assignment == null) return;
    _selection.toggle(assignment);
    notifyListeners();
  }

  /// Serum avadanlığı — yalnızca ataması olan avadanlık seçilebilir.
  void toggleSerumTray(int cellId) {
    final assignment = AssignmentSelection.serumAssignment(cellId, _assignments);
    if (assignment == null) return;
    _selection.toggle(assignment);
    notifyListeners();
  }

  void toggleDrawer(DrawerGroup group) {
    if (_selection.toggleAll(AssignmentSelection.inGroup(group, _assignments))) notifyListeners();
  }

  /// [groups]: kabin görsel verisi — kilitli serum raflarının avadanlık
  /// kilit adresleri buradan çözülür.
  void startRefill({
    required List<DrawerGroup> groups,
    required void Function(List<CabinOperationDrawerJob> jobs, int skippedCount) onQueueReady,
    required void Function(CabinOperationFailure failure) onFailed,
  }) {
    if (!canStart) return;

    final result = CabinOperationQueueBuilder.build(
      items: selectedAssignments,
      assignmentOf: (a) => a,
      targetOf: (_, a) => CabinOperationTarget.fromAssignment(a, CabinOperationMode.refill),
      groups: groups,
    );

    if (result.jobs.isEmpty) {
      onFailed(const CabinValidationFailure(reason: CabinValidationReason.noValidTargets));
      return;
    }

    if (result.skipped.isNotEmpty) {
      MedLogger.warn(
        unit: 'MasterRefill',
        swreq: 'SWREQ-CLI-MREFILL-002',
        message: 'Bazı seçimler fiziksel çekmece kimliği çözülemediği için kuyruğa alınamadı',
        context: {
          'skippedCount': result.skipped.length,
          'skippedMedicineIds': result.skipped.map((a) => a.medicine?.id).toList(),
        },
      );
    }

    onQueueReady(result.jobs, result.skipped.length);
  }
}
