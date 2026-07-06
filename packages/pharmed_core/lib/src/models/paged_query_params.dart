import 'package:pharmed_core/pharmed_core.dart';

class PagedQueryParams {
  const PagedQueryParams({
    this.skip,
    this.take,
    this.searchQuery,
    this.searchFields,
    this.startDate,
    this.endDate,
    this.filters,
  });

  final int? skip;
  final int? take;
  final String? searchQuery;
  final List<String>? searchFields;
  final DateTime? startDate;
  final DateTime? endDate;

  /// Ek DevExtreme filter clause'ları. Her biri ya
  /// `[field, op, value]` üçlüsü ya da gruplanmış bir liste olabilir.
  /// Tümü AND ile birleştirilir; OR gerekirse tek bir clause olarak
  /// gruplanmış halde verilir.
  final List<Object>? filters;

  PagedQueryParams copyWith({
    int? skip,
    int? take,
    String? searchQuery,
    List<String>? searchFields,
    DateTime? startDate,
    DateTime? endDate,
    List<Object>? filters,
  }) {
    return PagedQueryParams(
      skip: skip ?? this.skip,
      take: take ?? this.take,
      searchQuery: searchQuery ?? this.searchQuery,
      searchFields: searchFields ?? this.searchFields,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      filters: filters ?? this.filters,
    );
  }
}

/// DevExtreme filter clause builder.
/// Her metot ham `List<Object>` döndürür — `fetchRequest`'e doğrudan verilebilir.
abstract final class Filter {
  static List<Object> eq(String field, Object value) => [field, '=', value];
  static List<Object> neq(String field, Object value) => [field, '<>', value];
  static List<Object> gt(String field, Object value) => [field, '>', value];
  static List<Object> gte(String field, Object value) => [field, '>=', value];
  static List<Object> lt(String field, Object value) => [field, '<', value];
  static List<Object> lte(String field, Object value) => [field, '<=', value];
  static List<Object> contains(String field, String value) => [field, 'contains', value];

  /// `field IN values` — DevExtreme'de OR zinciri olarak açılır.
  static List<Object> inList(String field, List<Object> values) {
    if (values.isEmpty) {
      // Boş IN — backend'e gitmemesi için çağıran tarafta filtreyi hiç eklememek daha iyi.
      // Burada güvenli no-op: her zaman false dönen bir clause.
      return [field, '=', ''];
    }
    if (values.length == 1) return eq(field, values.first);
    final parts = <Object>[];
    for (var i = 0; i < values.length; i++) {
      parts.add(eq(field, values[i]));
      if (i < values.length - 1) parts.add('or');
    }
    return parts;
  }

  static List<Object> and(List<List<Object>> clauses) => _join(clauses, 'and');
  static List<Object> or(List<List<Object>> clauses) => _join(clauses, 'or');

  static List<Object> _join(List<List<Object>> clauses, String op) {
    if (clauses.isEmpty) return const [];
    if (clauses.length == 1) return clauses.first;
    final parts = <Object>[];
    for (var i = 0; i < clauses.length; i++) {
      parts.add(clauses[i]);
      if (i < clauses.length - 1) parts.add(op);
    }
    return parts;
  }
}

extension PagedQueryParamsBuilder on PagedQueryParams {
  static PagedQueryParams fromPreset({
    required DateRangePreset preset,
    List<Object>? filters,
    int skip = 0,
    int take = 20,
    String? search,
  }) {
    final range = preset.toRange(DateTime.now());
    return PagedQueryParams(
      skip: skip,
      take: take,
      searchQuery: search,
      startDate: range.start,
      endDate: range.end,
      filters: filters,
    );
  }
}
