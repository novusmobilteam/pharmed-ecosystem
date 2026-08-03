import 'package:flutter/foundation.dart';

import '../../../../core/core.dart';

class PrescriptionTemplatesNotifier extends ChangeNotifier with ApiRequestMixin {
  final GetPrescriptionTemplatesUseCase _listUseCase;
  final GetPrescriptionTemplateItemsUseCase _itemsUseCase;

  PrescriptionTemplatesNotifier({
    required GetPrescriptionTemplatesUseCase listUseCase,
    required GetPrescriptionTemplateItemsUseCase itemsUseCase,
  }) : _listUseCase = listUseCase,
       _itemsUseCase = itemsUseCase {
    fetch();
  }

  final OperationKey fetchOp = OperationKey.fetch();

  List<PrescriptionTemplate> _templates = [];
  List<PrescriptionTemplate> get templates => _templates;

  /// Genişletilmiş şablonların item cache'i. Aynı şablona iki kez expand
  /// açıp kapatınca tekrar fetch etmiyoruz.
  final Map<int, List<PrescriptionTemplateItem>> _itemsByTemplateId = {};

  /// Anlık fetch edilen şablon id'leri (per-card spinner için).
  final Set<int> _loadingTemplateIds = {};

  bool get isFetching => isLoading(fetchOp);

  List<PrescriptionTemplateItem>? itemsOf(int templateId) => _itemsByTemplateId[templateId];

  bool isLoadingItems(int templateId) => _loadingTemplateIds.contains(templateId);

  Future<void> fetch() async {
    await execute(
      fetchOp,
      operation: () => _listUseCase.call(),
      onData: (data) {
        _templates = data;
        notifyListeners();
      },
    );
  }

  /// Card expand edildiğinde çağrılır. Cache varsa no-op.
  Future<void> fetchItems(int templateId) async {
    if (_itemsByTemplateId.containsKey(templateId)) return;
    if (_loadingTemplateIds.contains(templateId)) return;

    _loadingTemplateIds.add(templateId);
    notifyListeners();

    final result = await _itemsUseCase.call(templateId);
    result.when(
      ok: (items) {
        _itemsByTemplateId[templateId] = items ?? [];
      },
      error: (_) {
        // Hata durumunda cache'e koyma — kullanıcı tekrar açınca yeniden denesin.
      },
    );

    _loadingTemplateIds.remove(templateId);
    notifyListeners();
  }
}
