// [SWREQ-CLI-MCENSUS-001] [IEC 62304 §5.5]
// Master kabin sayımının seçim fazı: istasyondaki tüm kabinlerin atamalarını
// çeker (kabin seçim adımı yok), sayım modunu (tüm kabin / çekmece / ilaç) ve
// kabinler arası seçimi yönetir, kuyruğu kabin sırasıyla hazırlayıp
// execution notifier'a devreder. "Tüm kabin" modu GÖRÜNTÜLENEN kabinin tüm
// atamalarını seçer; diğer kabinlerdeki seçim korunur.
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

enum CensusMode { byMedicine, byDrawer, allCabin }

final masterCensusSelectionNotifierProvider = ChangeNotifierProvider.autoDispose<MasterCensusSelectionNotifier>((ref) {
  return MasterCensusSelectionNotifier(getAssignments: ref.read(getStationAssignmentsUseCaseProvider));
});

class MasterCensusSelectionNotifier extends ChangeNotifier with ApiRequestMixin {
  MasterCensusSelectionNotifier({required GetStationAssignmentsUseCase getAssignments})
    : _getAssignments = getAssignments;

  final GetStationAssignmentsUseCase _getAssignments;

  final OperationKey fetchAssignmentsOp = OperationKey.fetch();

  final StationCabinScope scope = StationCabinScope();

  List<MedicineAssignment> _assignments = [];
  final AssignmentSelection _selection = AssignmentSelection();
  String _search = '';

  CensusMode get censusMode => _censusMode;
  CensusMode _censusMode = CensusMode.byMedicine;

  // ── Getterlar ─────────────────────────────────────────────────────────

  List<MedicineAssignment> get assignments => _assignments;
  Set<int> get selectedUnitIds => _selection.unitIds;
  Set<int> get selectedSerumCellIds => _selection.serumCellIds;
  String get search => _search;

  bool get isLoadingAssignments => isLoading(fetchAssignmentsOp);
  bool get isError => isFailed(fetchAssignmentsOp);

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

  /// Görüntülenen kabinin tüm atamalarını seçime ekler.
  void _selectViewedCabin() => _selection.addAll(scope.ofCabin(_assignments, scope.viewedCabinId));

  // ── Akış ──────────────────────────────────────────────────────────────

  Future<void> init(StationCabinsContext ctx) {
    scope.attach(ctx);
    return _fetchAssignments();
  }

  /// Kuyruk bittiğinde/durdurulduğunda — stoklar değişti, baştan çekilir ve
  /// "ilaç" moduna dönülür.
  Future<void> refreshAfterQueue() => _fetchAssignments();

  Future<void> _fetchAssignments() async {
    if (!scope.hasCabins) return;

    await execute(
      fetchAssignmentsOp,
      operation: () => _getAssignments.call(),
      onData: (all) {
        // Yalnızca işlem yapılabilir kabinlere bağlanan atamalar.
        _assignments = scope.stationAssignments(all);
        _censusMode = CensusMode.byMedicine;
        // Önceki davranışla aynı: açılışta (görüntülenen) kabinin tamamı seçili.
        _selection.clear();
        _selectViewedCabin();
        notifyListeners();
      },
    );
  }

  /// "Tüm kabin" modunda yeni görüntülenen kabinin tamamı da seçime eklenir.
  void viewCabin(int cabinId) {
    if (!scope.view(cabinId)) return;
    if (_censusMode == CensusMode.allCabin) _selectViewedCabin();
    notifyListeners();
  }

  void setCabinFilter(int? cabinId) {
    if (scope.setFilter(cabinId)) notifyListeners();
  }

  /// - allCabin'e geçiş: görüntülenen kabinin tüm atamaları seçilir (kilitli
  ///   seçim, diğer kabinlerdeki seçim korunur).
  /// - byDrawer'a geçiş: önceki moddan bağımsız olarak seçim sıfırlanır —
  ///   kullanıcı çekmeceleri kendisi seçer.
  /// - allCabin'den byMedicine'e geçiş: seçim sıfırlanır — kullanıcı temiz başlasın.
  /// - byDrawer → byMedicine: seçim korunur (aynı küme, farklı arayüz).
  void setCensusMode(CensusMode mode) {
    if (_censusMode == mode) return;
    final wasAllCabin = _censusMode == CensusMode.allCabin;
    _censusMode = mode;

    if (mode == CensusMode.allCabin) {
      _selectViewedCabin();
    } else if (mode == CensusMode.byDrawer || wasAllCabin) {
      _selection.clear();
    }
    notifyListeners();
  }

  void onSearchChanged(String value) {
    _search = value;
    notifyListeners();
  }

  void toggleUnit(int cabinDrawerId) {
    if (_censusMode == CensusMode.allCabin) return; // kilitli seçim
    _toggle(AssignmentSelection.unitAssignment(cabinDrawerId, _assignments));
  }

  /// Serum avadanlığı — normal gözle aynı kurallar.
  void toggleSerumTray(int cellId) {
    if (_censusMode == CensusMode.allCabin) return; // kilitli seçim
    _toggle(AssignmentSelection.serumAssignment(cellId, _assignments));
  }

  /// Listeden başka bir kabinin kalemi seçilince iç yerleşim o kabine geçer.
  void _toggle(MedicineAssignment? assignment) {
    if (assignment == null) return;
    final wasSelected = _selection.contains(assignment);
    _selection.toggle(assignment);
    if (!wasSelected) scope.view(scope.cabinIdOf(assignment));
    notifyListeners();
  }

  void toggleDrawer(DrawerGroup group) {
    if (_censusMode == CensusMode.allCabin) return;
    if (_selection.toggleAll(AssignmentSelection.inGroup(group, _assignments))) notifyListeners();
  }

  void startCensus({
    required void Function(List<CabinOperationDrawerJob> jobs, int skippedCount) onQueueReady,
    required void Function(CabinOperationFailure failure) onFailed,
  }) {
    if (!canStart) return;

    final result = CabinOperationQueueBuilder.build(
      items: selectedAssignments,
      assignmentOf: (a) => a,
      targetOf: (_, a) => CabinOperationTarget.fromAssignment(a, CabinOperationMode.census),
      cabinOrder: scope.cabinOrder,
      groups: scope.allGroups,
    );

    if (result.jobs.isEmpty) {
      onFailed(const CabinValidationFailure(reason: CabinValidationReason.noValidTargets));
      return;
    }

    if (result.skipped.isNotEmpty) {
      MedLogger.warn(
        unit: 'MasterCensus',
        swreq: 'SWREQ-CLI-MCENSUS-002',
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
