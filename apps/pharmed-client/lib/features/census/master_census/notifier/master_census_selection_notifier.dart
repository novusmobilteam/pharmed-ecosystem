// [SWREQ-CLI-MCENSUS-001] [IEC 62304 §5.5]
// Master kabin sayımının seçim fazı: seçilen kabinin atamalarını çeker,
// sayım modunu (tüm kabin / çekmece / ilaç) ve seçimi yönetir, kuyruğu
// hazırlayıp execution notifier'a devreder.
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

  /// Seçilen kabinin fiziksel çekmece kimlikleri — istasyon atamaları bununla süzülür.
  Set<int> _cabinSlotIds = const {};

  /// Kabin görsel verisi — serum avadanlıklarının kilit adresleri için.
  List<DrawerGroup> _groups = const [];

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
    if (q.isEmpty) return _assignments;
    return _assignments.where((a) {
      final name = a.medicine?.name?.toLowerCase() ?? '';
      final barcode = a.medicine?.barcode?.toLowerCase() ?? '';
      return name.contains(q) || barcode.contains(q);
    }).toList();
  }

  List<MedicineAssignment> get selectedAssignments => _selection.selectedFrom(_assignments);

  bool get canStart => _selection.isNotEmpty;

  void _selectAll() => _selection
    ..clear()
    ..addAll(_assignments);

  // ── Akış ──────────────────────────────────────────────────────────────

  Future<void> init(CabinRouteContext ctx) {
    _groups = ctx.cabinData?.groups ?? const <DrawerGroup>[];
    _cabinSlotIds = {for (final g in _groups) ?g.slot.id};
    return _fetchAssignments();
  }

  /// Kuyruk bittiğinde/durdurulduğunda — stoklar değişti, baştan çekilir ve
  /// "tüm kabin" moduna dönülür.
  Future<void> refreshAfterQueue() => _fetchAssignments();

  Future<void> _fetchAssignments() async {
    await execute(
      fetchAssignmentsOp,
      operation: () => _getAssignments.call(),
      onData: (all) {
        // İstasyon atamaları döner — yalnızca seçilen kabinin çekmeceleri.
        _assignments = all.where((a) {
          final slotId = a.drawerUnit?.drawerSlot?.id ?? a.drawerUnit?.drawerSlotId;
          return slotId != null && _cabinSlotIds.contains(slotId);
        }).toList();
        _censusMode = CensusMode.byMedicine;
        _selectAll();
        notifyListeners();
      },
    );
  }

  /// - allCabin'e geçiş: tüm atamalar seçilir (kilitli seçim).
  /// - allCabin'den çıkış: seçim sıfırlanır — kullanıcı temiz başlasın.
  /// - byDrawer ↔ byMedicine: seçim korunur (aynı küme, farklı arayüz).
  void setCensusMode(CensusMode mode) {
    if (_censusMode == mode) return;
    final wasAllCabin = _censusMode == CensusMode.allCabin;
    _censusMode = mode;

    if (mode == CensusMode.allCabin) {
      _selectAll();
    } else if (wasAllCabin) {
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
    final assignment = AssignmentSelection.unitAssignment(cabinDrawerId, _assignments);
    if (assignment == null) return;
    _selection.toggle(assignment);
    notifyListeners();
  }

  /// Serum avadanlığı — normal gözle aynı kurallar.
  void toggleSerumTray(int cellId) {
    if (_censusMode == CensusMode.allCabin) return; // kilitli seçim
    final assignment = AssignmentSelection.serumAssignment(cellId, _assignments);
    if (assignment == null) return;
    _selection.toggle(assignment);
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
      groups: _groups,
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

    onQueueReady(result.jobs, result.skipped.length);
  }
}
