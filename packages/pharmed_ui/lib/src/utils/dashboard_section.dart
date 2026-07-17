class DashboardSection<T> {
  const DashboardSection({this.data, this.isLoading = false, this.error, this.isStale = false, this.staleSavedAt});

  final T? data;
  final bool isLoading;
  final String? error;

  /// Veri cache'ten geldi (çekme patladı ama eski veri var).
  final bool isStale;
  final DateTime? staleSavedAt;

  bool get hasData => data != null;
  bool get isInitialLoading => isLoading && data == null;

  /// Hata var ve gösterilecek hiç veri yok → panel-içi hata + retry.
  bool get showError => error != null && data == null;

  DashboardSection<T> copyWith({
    T? data,
    bool? isLoading,
    Object? error = _sentinel,
    bool? isStale,
    Object? staleSavedAt = _sentinel,
  }) {
    return DashboardSection<T>(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error == _sentinel ? this.error : error as String?,
      isStale: isStale ?? this.isStale,
      staleSavedAt: staleSavedAt == _sentinel ? this.staleSavedAt : staleSavedAt as DateTime?,
    );
  }

  static const _sentinel = Object();
}
