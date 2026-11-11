// [SWREQ-CLI-MREFILL-001] [IEC 62304 §5.5]
// Master kabin dolumunun seçim fazı: istasyondaki tüm kabinlerin atamalarını
// çeker (kabin seçim adımı yok), göz/çekmece seçimini kabinler arası yönetir,
// kuyruğu kabin sırasıyla hazırlayıp execution notifier'a devreder.
// Serum avadanlıkları (cabinDrawerDetailId'li atamalar) göz bazında seçilir.
// Hangi kabinin iç yerleşiminin gösterileceği StationCabinScope'tadır.
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
  return MasterRefillSelectionNotifier(getAssignments: ref.read(getStationAssignmentsUseCaseProvider));
});

class MasterRefillSelectionNotifier extends ChangeNotifier with ApiRequestMixin {
  MasterRefillSelectionNotifier({required GetStationAssignmentsUseCase getAssignments})
    : _getAssignments = getAssignments;

  final GetStationAssignmentsUseCase _getAssignments;

  final OperationKey fetchAssignmentsOp = OperationKey.fetch();

  final StationCabinScope scope = StationCabinScope();

  List<MedicineAssignment> _assignments = [];
  final AssignmentSelection _selection = AssignmentSelection();
  String _search = '';

  /// İstasyondaki tüm (işlem yapılabilir kabinlerdeki) atamalar.
  List<MedicineAssignment> get assignments => _assignments;
  Set<int> get selectedUnitIds => _selection.unitIds;
  Set<int> get selectedSerumCellIds => _selection.serumCellIds;
  String get search => _search;

  bool get isLoadingAssignments => isLoading(fetchAssignmentsOp);
  bool get isError => isFailed(fetchAssignmentsOp);

  /// Sağ liste: arama + kabin filtresi uygulanmış atamalar.
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

  Future<void> init(StationCabinsContext ctx) {
    scope.attach(ctx);
    return _fetchAssignments();
  }

  /// Kuyruk bittiğinde/durdurulduğunda — stoklar değişti, baştan çekilir.
  Future<void> refreshAfterQueue() => _fetchAssignments();

  Future<void> _fetchAssignments() async {
    if (!scope.hasCabins) return;

    await execute(
      fetchAssignmentsOp,
      operation: () => _getAssignments.call(),
      onData: (list) {
        _assignments = scope.stationAssignments(list);
        _selection.clear(); // doldurulan gözler işaretli kalmasın
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

  void toggleUnit(int cabinDrawerId) =>
      _toggle(AssignmentSelection.unitAssignment(cabinDrawerId, _assignments));

  /// Serum avadanlığı — yalnızca ataması olan avadanlık seçilebilir.
  void toggleSerumTray(int cellId) => _toggle(AssignmentSelection.serumAssignment(cellId, _assignments));

  /// Atama bazında seçim — Açık Raf'ta aynı avadanlıktaki ilaçlar ayrı seçilir.
  void toggleAssignment(MedicineAssignment assignment) => _toggle(assignment);

  bool isSelected(MedicineAssignment assignment) => _selection.contains(assignment);

  /// Listeden başka bir kabinin kalemi seçilince iç yerleşim o kabine geçer —
  /// kullanıcı açılacak gözü hemen görür.
  void _toggle(MedicineAssignment? assignment) {
    if (assignment == null) return;
    final wasSelected = _selection.contains(assignment);
    _selection.toggle(assignment);
    if (!wasSelected) scope.view(scope.cabinIdOf(assignment));
    notifyListeners();
  }

  void toggleDrawer(DrawerGroup group) {
    if (_selection.toggleAll(AssignmentSelection.inGroup(group, _assignments))) notifyListeners();
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
      cabinOrder: scope.cabinOrder,
      // Kilitli serum raflarının avadanlık kilit adresleri buradan çözülür.
      groups: scope.allGroups,
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

    onQueueReady(scope.withCabinIds(result.jobs), result.skipped.length);
  }
}
