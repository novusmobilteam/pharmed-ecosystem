import 'package:pharmed_core/pharmed_core.dart';

enum MedicineListMode { equivalent, all }

sealed class DrugAssignmentUiState {
  const DrugAssignmentUiState();
}

final class DrugAssignmentUninitialized extends DrugAssignmentUiState {
  const DrugAssignmentUninitialized();
}

final class DrugAssignmentLoading extends DrugAssignmentUiState {
  const DrugAssignmentLoading();
}

/// Göz seçili değil — sağda "MEVCUT ATAMALAR" tablosu gösterilir.
final class DrugAssignmentIdle extends DrugAssignmentUiState {
  const DrugAssignmentIdle({
    required this.groups,
    required this.assignments,
    required this.cabinId,
    this.searchQuery = '',
  });

  final List<DrawerGroup> groups;
  final List<MedicineAssignment> assignments;
  final int cabinId;
  final String searchQuery;

  List<MedicineAssignment> get visibleAssignments {
    if (searchQuery.trim().isEmpty) return assignments;
    final q = searchQuery.toLowerCase().trim();
    return assignments.where((a) {
      final name = a.medicine?.name?.toLowerCase() ?? '';
      final barcode = a.medicine?.barcode?.toLowerCase() ?? '';
      return name.contains(q) || barcode.contains(q);
    }).toList();
  }

  DrugAssignmentIdle copyWith({String? searchQuery}) {
    return DrugAssignmentIdle(
      groups: groups,
      assignments: assignments,
      cabinId: cabinId,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

final class DrugAssignmentCellSelected extends DrugAssignmentUiState {
  const DrugAssignmentCellSelected({
    required this.groups,
    required this.assignments,
    required this.cabinId,
    required this.selectedGroup,
    required this.assignment,
    required this.medicinePage,
    required this.equivalentMedicinePage, // YENİ
    this.listMode = MedicineListMode.all, // YENİ
    this.selectedStepNo,
    this.selectedDrug,
    this.minQty,
    this.maxQty,
    this.criticalQty,
  });

  final List<DrawerGroup> groups;
  final List<MedicineAssignment> assignments;
  final int cabinId;
  final DrawerGroup selectedGroup;
  final int? selectedStepNo;

  final MedicineAssignment assignment;
  final MedicinePageState medicinePage; // "Tüm İlaçlar"
  final MedicinePageState equivalentMedicinePage; // YENİ — "Muadil İlaçlar"
  final MedicineListMode listMode; // YENİ

  final Medicine? selectedDrug;
  final int? minQty;
  final int? maxQty;
  final int? criticalQty;

  int get selectedSlotId => selectedGroup.slot.id ?? -1;
  int? get selectedUnitId => assignment.cabinDrawerId;
  bool get isAssigned => assignment.id != null;
  bool get canSave => selectedDrug != null && minQty != null && minQty! > 0;

  /// Aktif sekmeye göre gösterilecek sayfa.
  MedicinePageState get selectedPage => listMode == MedicineListMode.equivalent ? equivalentMedicinePage : medicinePage;

  DrugAssignmentCellSelected copyWith({
    MedicineAssignment? assignment,
    MedicinePageState? medicinePage,
    MedicinePageState? equivalentMedicinePage, // YENİ
    MedicineListMode? listMode, // YENİ
    Medicine? selectedDrug,
    int? minQty,
    int? maxQty,
    int? criticalQty,
  }) {
    return DrugAssignmentCellSelected(
      groups: groups,
      assignments: assignments,
      cabinId: cabinId,
      selectedGroup: selectedGroup,
      selectedStepNo: selectedStepNo,
      assignment: assignment ?? this.assignment,
      medicinePage: medicinePage ?? this.medicinePage,
      equivalentMedicinePage: equivalentMedicinePage ?? this.equivalentMedicinePage,
      listMode: listMode ?? this.listMode,
      selectedDrug: selectedDrug ?? this.selectedDrug,
      minQty: minQty ?? this.minQty,
      maxQty: maxQty ?? this.maxQty,
      criticalQty: criticalQty ?? this.criticalQty,
    );
  }
}

final class DrugAssignmentSaving extends DrugAssignmentUiState {
  const DrugAssignmentSaving({
    required this.groups,
    required this.assignments,
    required this.cabinId,
    required this.selectedGroup,
    required this.assignment,
    this.selectedDrug,
    this.minQty,
    this.maxQty,
    this.criticalQty,
  });

  final List<DrawerGroup> groups;
  final List<MedicineAssignment> assignments;
  final int cabinId;
  final DrawerGroup selectedGroup;
  final MedicineAssignment assignment;
  final Medicine? selectedDrug;
  final int? minQty;
  final int? maxQty;
  final int? criticalQty;
}

final class DrugAssignmentError extends DrugAssignmentUiState {
  const DrugAssignmentError({required this.message, required this.previous});

  final String message;
  final DrugAssignmentUiState previous;
}

/// Sayfalı ilaç arama listesi state'i (SelectionDialog'un infinite-scroll'u
/// yerine — bu ekranda sabit sayfa numaralı gezinme kullanılıyor).
class MedicinePageState {
  const MedicinePageState({
    this.items = const [],
    this.page = 0,
    this.pageSize = 10,
    this.totalCount = 0,
    this.search = '',
    this.isLoading = false,
    this.error,
  });

  final List<Medicine> items;
  final int page; // 0-indexed
  final int pageSize;
  final int totalCount;
  final String search;
  final bool isLoading;
  final String? error;

  int get totalPages => totalCount == 0 ? 1 : (totalCount / pageSize).ceil();
  bool get hasNextPage => (page + 1) < totalPages;
  bool get hasPreviousPage => page > 0;

  MedicinePageState copyWith({
    List<Medicine>? items,
    int? page,
    int? totalCount,
    String? search,
    bool? isLoading,
    Object? error = _sentinel,
  }) {
    return MedicinePageState(
      items: items ?? this.items,
      page: page ?? this.page,
      pageSize: pageSize,
      totalCount: totalCount ?? this.totalCount,
      search: search ?? this.search,
      isLoading: isLoading ?? this.isLoading,
      error: error == _sentinel ? this.error : error as String?,
    );
  }

  static const _sentinel = Object();
}
