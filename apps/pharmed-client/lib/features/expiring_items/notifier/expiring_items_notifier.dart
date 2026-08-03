import 'package:pharmed_core/pharmed_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/providers.dart';
import 'expiring_items_state.dart';

final expiringItemsNotifierProvider = NotifierProvider<ExpiringItemsNotifier, ExpiringItemsState>(
  ExpiringItemsNotifier.new,
);

class ExpiringItemsNotifier extends Notifier<ExpiringItemsState> {
  GetExpiringStocksUseCase get _useCase => ref.read(getExpiringStocksUseCaseProvider);

  DateTime? _startDate;
  DateTime? get startDate => _startDate;

  DateTime? _endDate;
  DateTime? get endDate => _endDate;

  int _currentPage = 1;
  int get currentPage => _currentPage;

  final int _pageSize = 15;
  int get pageSize => _pageSize;

  int _totalCount = 0;
  int get totalCount => _totalCount;

  int get totalPages => (_totalCount / _pageSize).ceil();

  bool get canGoNext => _currentPage < totalPages;
  bool get canGoPrev => _currentPage > 1;

  @override
  ExpiringItemsState build() {
    _load();

    return const ExpiringItemsLoading();
  }

  /// Tablo varsa koru + tablo-içi loading; yoksa (ilk yükleme) tam ekran Loading.
  void _enterLoading() {
    final current = state;
    state = current is ExpiringItemsLoaded ? current.copyWith(isLoading: true) : const ExpiringItemsLoading();
  }

  Future<void> _load() async {
    final skip = (_currentPage - 1) * _pageSize;
    final result = await _useCase.call(
      params: PagedQueryParams(skip: skip, take: _pageSize, startDate: _startDate, endDate: _endDate),
    );
    result.when(
      ok: (response) {
        _totalCount = response?.totalCount ?? 0;
        state = ExpiringItemsLoaded(items: response?.data ?? []); // isLoading: false (default)
      },
      error: (e) => state = ExpiringItemsError(message: e.message),
    );
  }

  Future<void> refresh() async {
    _enterLoading();
    await _load();
  }

  Future<void> onDateRangeChanged(DateTime? start, DateTime? end) async {
    _startDate = start ?? _startDate;
    _endDate = end ?? _endDate;
    _currentPage = 1;
    _enterLoading();
    await _load();
  }

  Future<void> goToPage(int page) async {
    if (page < 1 || (totalPages > 0 && page > totalPages)) return;
    _currentPage = page;
    _enterLoading();
    await _load();
  }

  Future<void> nextPage() async {
    if (canGoNext) await goToPage(_currentPage + 1);
  }

  Future<void> previousPage() async {
    if (canGoPrev) await goToPage(_currentPage - 1);
  }
}
