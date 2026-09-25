// [SWREQ-CLI-MREFILL-001] [IEC 62304 §5.5]
// Master kabin dolumunun seçim fazı: seçilen kabinin atamalarını çeker,
// göz/çekmece seçimini yönetir, kuyruğu hazırlayıp execution notifier'a devreder.
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
  final Set<int> _selectedUnitIds = {};
  String _search = '';

  List<MedicineAssignment> get assignments => _assignments;
  Set<int> get selectedUnitIds => Set.unmodifiable(_selectedUnitIds);
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

  List<MedicineAssignment> get selectedAssignments =>
      _assignments.where((a) => _selectedUnitIds.contains(a.cabinDrawerId)).toList();

  bool get canStart => _selectedUnitIds.isNotEmpty;

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
        _selectedUnitIds.clear(); // doldurulan gözler işaretli kalmasın
        notifyListeners();
      },
    );
  }

  void onSearchChanged(String value) {
    _search = value;
    notifyListeners();
  }

  void toggleUnit(int cabinDrawerId) {
    _selectedUnitIds.contains(cabinDrawerId)
        ? _selectedUnitIds.remove(cabinDrawerId)
        : _selectedUnitIds.add(cabinDrawerId);
    notifyListeners();
  }

  void toggleDrawer(DrawerGroup group) {
    final unitIdsInGroup = group.units.map((u) => u.id).whereType<int>().toSet();
    final drawerUnitIds = _assignments
        .map((a) => a.cabinDrawerId)
        .whereType<int>()
        .where(unitIdsInGroup.contains)
        .toSet();
    if (drawerUnitIds.isEmpty) return;

    drawerUnitIds.every(_selectedUnitIds.contains)
        ? _selectedUnitIds.removeAll(drawerUnitIds)
        : _selectedUnitIds.addAll(drawerUnitIds);
    notifyListeners();
  }

  void startRefill({
    required void Function(List<CabinOperationDrawerJob> jobs, int skippedCount) onQueueReady,
    required void Function(CabinOperationFailure failure) onFailed,
  }) {
    if (!canStart) return;

    final result = CabinOperationQueueBuilder.build(
      items: selectedAssignments,
      assignmentOf: (a) => a,
      targetOf: (_, a) => CabinOperationTarget.fromAssignment(a, CabinOperationMode.refill),
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
