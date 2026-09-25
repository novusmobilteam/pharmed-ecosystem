import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/core/mixins/api_request_mixin.dart';
import 'package:pharmed_client/core/providers/usecase_providers.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../core/hardware/hardware.dart';
import '../../dashboard/dashboard.dart';

import 'package:collection/collection.dart';

enum RefillListType { waiting, completed }

final refillListSelectionNotifierProvider = ChangeNotifierProvider.autoDispose<RefillListSelectionNotifier>((ref) {
  return RefillListSelectionNotifier(
    getRefillListsUseCase: ref.read(getRefillListsUseCaseProvider),
    getRefillListFillDetailUseCase: ref.read(getRefillListFillDetailUseCaseProvider),
  );
});

class RefillListSelectionNotifier extends ChangeNotifier with ApiRequestMixin {
  RefillListSelectionNotifier({
    required GetRefillListsUseCase getRefillListsUseCase,
    required GetRefillListFillDetailUseCase getRefillListFillDetailUseCase,
  }) : _getRefillListsUseCase = getRefillListsUseCase,
       _getRefillListFillDetailUseCase = getRefillListFillDetailUseCase;

  final GetRefillListsUseCase _getRefillListsUseCase;
  final GetRefillListFillDetailUseCase _getRefillListFillDetailUseCase;

  final OperationKey fetchListOp = OperationKey.custom('fetch-list');

  /// Detay isteği liste id'sine bağlı — hızlı liste değişiminde eski isteğin
  /// bitmesi yeni isteğin loading durumunu kapatmasın diye.
  OperationKey detailOpFor(int listId) => OperationKey.custom('fetch-detail-$listId');

  StationCabinsContext? _stationContext;

  RefillListType _type = RefillListType.waiting;
  RefillListType get type => _type;

  List<RefillList> _waitingLists = [];
  List<RefillList> get waitingLists => _waitingLists;

  List<RefillList> _completedLists = [];
  List<RefillList> get completedLists => _completedLists;

  RefillList? _selectedList;
  RefillList? get selectedList => _selectedList;

  List<RefillListDetail> _details = [];
  List<RefillListDetail> get details => _details;

  final Set<int> _selectedDetailIds = {};
  List<RefillListDetail> get selectedItems => _details.where((d) => _selectedDetailIds.contains(d.id)).toList();
  int get selectedCount => _selectedDetailIds.length;

  int get selectedTypeIndex => RefillListType.values.indexOf(_type);

  List<RefillList> get visibleLists => _type == RefillListType.waiting ? _waitingLists : _completedLists;

  bool isSelected(RefillListDetail detail) => _selectedDetailIds.contains(detail.id);

  bool get isError => isFailed(fetchListOp);

  bool get isDetailLoading {
    final id = _selectedList?.id;
    return id != null && isLoading(detailOpFor(id));
  }

  bool canSelect(RefillListDetail detail) => !isReadOnly && !detail.isFilled && detail.id != null;

  /// Tamamlanmış listeler salt-okunur — yalnızca görüntülenir.
  bool get isReadOnly => _type == RefillListType.completed;

  bool get canStart => !isReadOnly && !isDetailLoading && _selectedDetailIds.isNotEmpty;

  void init(StationCabinsContext ctx) {
    _stationContext = ctx;
    _getRefillLists();
  }

  Future<void> retry() => _getRefillLists();

  void selectType(int index) {
    final next = RefillListType.values.elementAt(index);
    if (next == _type) return;
    _type = next;
    _clearListSelection();
    notifyListeners();
  }

  void selectRefillList(RefillList list) {
    if (_selectedList?.id == list.id) return;
    _selectedList = list;
    _details = [];
    _selectedDetailIds.clear();
    notifyListeners();
    _getRefillListDetail();
  }

  void selectItem(RefillListDetail detail) {
    if (!canSelect(detail)) return;
    final id = detail.id!;
    _selectedDetailIds.contains(id) ? _selectedDetailIds.remove(id) : _selectedDetailIds.add(id);
    notifyListeners();
  }

  /// Kuyruk bittiğinde/durdurulduğunda çağrılır. Listeleri yeniden çeker ve
  /// az önce doldurulan listeyi, yeni durumuna göre doğru sekmede yeniden seçer
  /// (dolum sonrası send → partiallyCompleted/completed geçişi olabilir).
  Future<void> refreshAfterQueue() async {
    final reselectId = _selectedList?.id;
    await _getRefillLists();
    if (reselectId == null) return;

    final inWaiting = _waitingLists.firstWhereOrNull((l) => l.id == reselectId);
    final match = inWaiting ?? _completedLists.firstWhereOrNull((l) => l.id == reselectId);

    if (match == null) {
      _clearListSelection();
      notifyListeners();
      return;
    }

    _type = inWaiting != null ? RefillListType.waiting : RefillListType.completed;
    _selectedList = match;
    _selectedDetailIds.clear(); // doldurulan satırlar işaretli kalmasın
    notifyListeners();
    await _getRefillListDetail();
  }

  Future<void> _getRefillLists() async {
    final stationId = _stationContext?.station?.id;
    if (stationId == null) return;

    await execute(
      fetchListOp,
      operation: () => _getRefillListsUseCase.call(stationId),
      onData: (data) {
        final waiting = <RefillList>[];
        final completed = <RefillList>[];

        for (final list in data) {
          switch (list.status) {
            case RefillListStatus.send:
            case RefillListStatus.partiallyCompleted:
              waiting.add(list);
            case RefillListStatus.completed:
              completed.add(list);
            case RefillListStatus.toBeCollected:
            case RefillListStatus.collected:
            case null:
              break;
          }
        }

        _waitingLists = waiting;
        _completedLists = completed;
        notifyListeners();
      },
    );
  }

  Future<void> _getRefillListDetail() async {
    final listId = _selectedList?.id;
    if (listId == null) return;

    await execute(
      detailOpFor(listId),
      operation: () => _getRefillListFillDetailUseCase.call(listId),
      onData: (data) {
        // Yükleme sürerken başka listeye geçildiyse bu sonucu at.
        if (_selectedList?.id != listId) return;
        _details = data;

        // Seçilebilir tüm satırlar varsayılan olarak seçili gelir — kullanıcı
        // istemediklerini kaldırır. Tamamlanmış satırlar ve salt-okunur
        // (tamamlanan) sekme canSelect ile zaten dışarıda kalır.
        _selectedDetailIds
          ..clear()
          ..addAll(data.where(canSelect).map((d) => d.id!));

        notifyListeners();
      },
    );
  }

  void _clearListSelection() {
    _selectedList = null;
    _details = [];
    _selectedDetailIds.clear();
  }

  void startFilling({
    required void Function(List<CabinOperationDrawerJob> jobs, int fillingListId, int skippedCount) onQueueReady,
    required void Function(CabinOperationFailure failure) onFailed,
  }) {
    final listId = _selectedList?.id;
    if (!canStart || listId == null) return;

    final cabinOrder = [
      for (final cabin in _stationContext?.cabins ?? const <Cabin>[])
        if (cabin.id != null) cabin.id!,
    ];

    final result = RefillListJobMapper.build(rows: selectedItems, cabinOrder: cabinOrder);

    if (result.jobs.isEmpty) {
      onFailed(const CabinValidationFailure(reason: CabinValidationReason.noValidTargets));
      return;
    }

    if (result.skipped.isNotEmpty) {
      MedLogger.warn(
        unit: 'RefillList',
        swreq: 'SWREQ-CLI-RFLIST-001',
        message: 'Bazı işaretli satırlar fiziksel çekmece kimliği çözülemediği için kuyruğa alınamadı',
        context: {'skippedCount': result.skipped.length, 'fillingListId': listId},
      );
    }

    onQueueReady(result.jobs, listId, result.skipped.length);
  }
}
