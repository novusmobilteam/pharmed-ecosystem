class PagedQueryParams {
  const PagedQueryParams({this.skip, this.take, this.searchQuery, this.startDate, this.endDate, this.searchFields});

  final int? skip;
  final int? take;
  final String? searchQuery;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String>? searchFields;
}
