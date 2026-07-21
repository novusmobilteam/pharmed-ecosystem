import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

class KitContentNotifier extends ChangeNotifier with ApiRequestMixin {
  final GetKitContentUseCase _getKitContentUseCase;
  final DeleteKitContentUseCase _deleteKitContentUseCase;

  KitContentNotifier({
    required GetKitContentUseCase getKitContentUseCase,
    required DeleteKitContentUseCase deleteKitContentUseCase,
  }) : _getKitContentUseCase = getKitContentUseCase,
       _deleteKitContentUseCase = deleteKitContentUseCase;

  int? _kitId;
  int? get kitId => _kitId;

  OperationKey fetchOp = OperationKey.fetch();
  OperationKey deleteOp = OperationKey.delete();

  List<KitContent> _items = [];
  List<KitContent> get items => _items;

  bool get isFetching => isLoading(fetchOp);

  // Functions
  Future<void> getKitContents(int kitId) async {
    _kitId = kitId;
    notifyListeners();
    await execute(fetchOp, operation: () => _getKitContentUseCase.call(kitId), onData: (data) => _items = data);
  }

  Future<void> deleteKitContent(
    int id,
    Kit kit, {
    Function(String? msg)? onFailed,
    Function(String? msg)? onSuccess,
  }) async {
    final item = _items.firstWhere((x) => x.id == id, orElse: () => KitContent(id: id));

    await executeVoid(
      deleteOp,
      operation: () => _deleteKitContentUseCase.call(item),
      onFailed: (error) => onFailed?.call(error.message),
      onSuccess: () {
        onSuccess?.call(null);
        getKitContents(kit.id!);
      },
    );
  }

  void setKitId(int? kitId) {
    _kitId = kitId;
    notifyListeners();
  }
}
