class DashboardSection<T> {
  const DashboardSection({this.data, this.isLoading = false, this.error, this.savedAt});

  final T? data;
  final bool isLoading;
  final String? error;
  final DateTime? savedAt;

  bool get hasData => data != null;
  bool get isInitialLoading => isLoading && data == null;

  /// Hata var ve gösterilecek hiç veri yok → panel-içi hata + retry.
  bool get showError => error != null && data == null;

  DashboardSection<T> copyWith({T? data, bool? isLoading, Object? error = _sentinel, DateTime? savedAt}) {
    return DashboardSection<T>(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error == _sentinel ? this.error : error as String?,
      savedAt: savedAt ?? this.savedAt,
    );
  }

  static const _sentinel = Object();
}
