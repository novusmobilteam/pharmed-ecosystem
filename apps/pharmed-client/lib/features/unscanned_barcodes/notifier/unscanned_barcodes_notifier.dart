import 'package:pharmed_core/pharmed_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/providers.dart';
import 'unscanned_barcodes_state.dart';

final unscannedBarcodesNotifierProvider = NotifierProvider<UnscannedBarcodesNotifier, UnscannedBarcodesState>(
  UnscannedBarcodesNotifier.new,
);

class UnscannedBarcodesNotifier extends Notifier<UnscannedBarcodesState> {
  GetUnscannedBarcodesUseCase get _getUnscannedBarcodes => ref.read(getUnscannedBarcodesUseCaseProvider);

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
  UnscannedBarcodesState build() {
    _load();
    return const UnscannedBarcodesLoading();
  }

  void _enterLoading() {
    final current = state;
    state = current is UnscannedBarcodesLoaded ? current.copyWith(isLoading: true) : const UnscannedBarcodesLoading();
  }

  Future<void> _load() async {
    final skip = (_currentPage - 1) * _pageSize;
    final result = await _getUnscannedBarcodes.call(
      params: PagedQueryParams(skip: skip, take: _pageSize, startDate: _startDate, endDate: _endDate),
    );
    result.when(
      ok: (response) {
        _totalCount = response?.totalCount ?? 0;
        state = UnscannedBarcodesLoaded(items: response?.data ?? []); // isLoading: false (default)
      },
      error: (e) => state = UnscannedBarcodesError(message: e.message),
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
