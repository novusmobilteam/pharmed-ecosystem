// [SWREQ-CLI-MDESTRUCTION-001] [IEC 62304 §5.5]
// Master kabin imhasının seçim fazı: seçilen kabinin imha edilebilir
// malzemelerini çeker, kullanıcının yetkili olduğu ve stoğu olan gözlerin
// seçimini yönetir, kuyruğu hazırlayıp execution notifier'a devreder.
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../core/hardware/hardware.dart';
import '../../../core/mixins/mixins.dart';
import '../../../core/providers/providers.dart';
import '../../auth/auth.dart';
import '../../dashboard/dashboard.dart';

final masterDestructionSelectionNotifierProvider =
    ChangeNotifierProvider.autoDispose<MasterDestructionSelectionNotifier>((ref) {
      return MasterDestructionSelectionNotifier(
        getAssignments: ref.read(getMasterDisposableMaterialsUseCaseProvider),
        authNotifier: ref.read(authNotifierProvider.notifier),
      );
    });

class MasterDestructionSelectionNotifier extends ChangeNotifier with ApiRequestMixin {
  MasterDestructionSelectionNotifier({
    required GetMasterDisposableMaterialsUseCase getAssignments,
    required AuthNotifier authNotifier,
  }) : _getAssignments = getAssignments,
       _authNotifier = authNotifier;

  final GetMasterDisposableMaterialsUseCase _getAssignments;
  final AuthNotifier _authNotifier;

  final OperationKey fetchAssignmentsOp = OperationKey.fetch();

  Set<int> _cabinSlotIds = const {};

  /// Kabin görsel verisi — serum avadanlıklarının kilit adresleri için.
  List<DrawerGroup> _groups = const [];

  List<MedicineAssignment> _assignments = [];
  final AssignmentSelection _selection = AssignmentSelection();
  String _search = '';

  List<MedicineAssignment> get assignments => _assignments;
  Set<int> get selectedUnitIds => _selection.unitIds;
  Set<int> get selectedSerumCellIds => _selection.serumCellIds;
  bool isSelected(MedicineAssignment a) => _selection.contains(a);
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

  /// Kullanıcı bu ilacı imha etmeye yetkili mi. İlaç olmayan malzemede
  /// (örn. tıbbi sarf) kısıt yoktur.
  bool isAuthorized(MedicineAssignment a) {
    final medicine = a.medicine;
    final userId = _authNotifier.currentUser?.id;
    if (medicine is! Drug) return true;
    if (userId == null) return false; // oturum yoksa yetki de yok
    return medicine.destroyableUsers.any((u) => u.id == userId);
  }

  /// Seçilebilir mi: çekmecesi çözülmüş, kullanıcı yetkili ve gözde stok var.
  bool canSelect(MedicineAssignment a) => a.cabinDrawerId != null && isAuthorized(a) && a.totalQuantity > 0;

  Future<void> init(CabinRouteContext ctx) {
    _groups = ctx.cabinData?.groups ?? const <DrawerGroup>[];
    _cabinSlotIds = {for (final g in _groups) ?g.slot.id};
    return _fetchAssignments();
  }

  Future<void> refreshAfterQueue() => _fetchAssignments();

  Future<void> _fetchAssignments() async {
    await execute(
      fetchAssignmentsOp,
      operation: () => _getAssignments.call(),
      onData: (all) {
        _assignments = all.where((a) {
          final slotId = a.drawerUnit?.drawerSlot?.id ?? a.drawerUnit?.drawerSlotId;
          return slotId != null && _cabinSlotIds.contains(slotId);
        }).toList();
        _selection.clear(); // imha bilinçli seçim ister — varsayılan seçim yok
        notifyListeners();
      },
    );
  }

  void onSearchChanged(String value) {
    _search = value;
    notifyListeners();
  }

  void toggleUnit(int cabinDrawerId) =>
      toggleAssignment(AssignmentSelection.unitAssignment(cabinDrawerId, _assignments));

  /// Serum avadanlığı — normal gözle aynı kurallar.
  void toggleSerumTray(int cellId) => toggleAssignment(AssignmentSelection.serumAssignment(cellId, _assignments));

  void toggleAssignment(MedicineAssignment? assignment) {
    if (assignment == null || !canSelect(assignment)) return;
    _selection.toggle(assignment);
    notifyListeners();
  }

  void toggleDrawer(DrawerGroup group) {
    final selectable = AssignmentSelection.inGroup(group, _assignments).where(canSelect);
    if (_selection.toggleAll(selectable)) notifyListeners();
  }

  void startDestruction({
    required void Function(List<CabinOperationDrawerJob> jobs, int skippedCount) onQueueReady,
    required void Function(CabinOperationFailure failure) onFailed,
  }) {
    if (!canStart) return;

    final result = CabinOperationQueueBuilder.build(
      items: selectedAssignments,
      assignmentOf: (a) => a,
      targetOf: (_, a) => CabinOperationTarget.fromAssignment(a, CabinOperationMode.destruction),
      groups: _groups,
    );

    if (result.jobs.isEmpty) {
      onFailed(const CabinValidationFailure(reason: CabinValidationReason.noValidTargets));
      return;
    }

    if (result.skipped.isNotEmpty) {
      MedLogger.warn(
        unit: 'MasterDestruction',
        swreq: 'SWREQ-CLI-MDESTRUCTION-002',
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
