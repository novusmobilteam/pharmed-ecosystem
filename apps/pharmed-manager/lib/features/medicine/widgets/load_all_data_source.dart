part of '../view/drug_form_panel.dart';

/// Sayfalamasız [SearchDataSource]: [SelectionDialog] sonsuz kaydırma yerine
/// tüm kayıtları tek seferde gösterir.
///
/// - Diyalog açılınca (arama boş) [fetchAll] ile tüm kayıtlar çekilir.
/// - Arama yazılınca istek atılmaz; son çekilen liste [labelBuilder] ile yerelde süzülür.
/// - `totalCount` dönen liste uzunluğu olduğundan diyalog sonraki sayfayı istemez.
SearchDataSource<T> _loadAllDataSource<T extends Selectable>({
  required Future<Result<ApiResponse<List<T>>?>> Function() fetchAll,
  required String? Function(T item) labelBuilder,
}) {
  List<T>? cache;

  return (skip, take, search) async {
    final query = search?.trim().toLowerCase() ?? '';

    if (cache == null || query.isEmpty) {
      final result = await fetchAll();
      final error = result.when<AppException?>(
        ok: (response) {
          cache = response?.data ?? <T>[];
          return null;
        },
        error: (e) => e,
      );
      if (error != null) return Result.error(error);
    }

    final all = cache ?? <T>[];
    final items = query.isEmpty
        ? all
        : all.where((item) => (labelBuilder(item) ?? '').toLowerCase().contains(query)).toList();

    // Diyalog sonraki sayfayı isterse (beklenmez) boş dönülür.
    if (skip > 0) return Result.ok(ApiResponse<List<T>>(data: <T>[], totalCount: items.length));
    return Result.ok(ApiResponse<List<T>>(data: items, totalCount: items.length));
  };
}
