import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

import 'dart:async';

import 'api_request_mixin.dart';

mixin PaginationMixin<T> on ApiRequestMixin {
  int _pageSize = 15;
  int _currentPage = 1;

  List<T> _items = [];
  int _totalCount = 0;

  String _searchQuery = '';
  Timer? _searchDebounce;

  List<T> get items => _items;
  int get totalCount => _totalCount;
  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  String get searchQuery => _searchQuery;
  bool get hasSearch => _searchQuery.isNotEmpty;
  bool get isEmpty => _totalCount <= 0;
  bool get isTableLoading => isLoading(const OperationKey.fetch());

  int get totalPages => (_totalCount / _pageSize).ceil();
  bool get canGoNext => _currentPage < totalPages;
  bool get canGoPrev => _currentPage > 1;

  DateTime? _startDate;
  DateTime? _endDate;

  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  bool get hasDateFilter => _startDate != null || _endDate != null;

  DateTimeRange? get dateRange => DateTimeRange(start: _startDate ?? DateTime.now(), end: _endDate ?? DateTime.now());

  // ── Alt sınıf sözleşmesi ──────────────────────────────────────────────────
  //
  // Notifier bunu implement eder. Mevcut filtre state'ini (searchQuery + kendi
  // filtreleri: kategori, tip, tarih vs.) kullanarak fetchPagedData'yı çağırır.
  //
  //   @override
  //   Future<void> reload() => fetchPagedData(
  //     fetchMethod: (skip, take) => useCase.call(Params(
  //       skip: skip,
  //       take: take,
  //       search: searchQuery,
  //       type: _selectedCategory,
  //     )),
  //   );
  //
  Future<void> fetch();

  // ── Sayfa yönetimi (her biri otomatik reload tetikler) ────────────────────

  void setPage(int page) {
    if (page < 1 || (totalPages > 0 && page > totalPages)) return;
    if (_currentPage == page) return;
    _currentPage = page;
    notifyListeners();
    fetch();
  }

  void setPageSize(int newSize) {
    if (_pageSize == newSize) return;
    _pageSize = newSize;
    _currentPage = 1;
    notifyListeners();
    fetch();
  }

  void nextPage() {
    if (canGoNext) setPage(_currentPage + 1);
  }

  void previousPage() {
    if (canGoPrev) setPage(_currentPage - 1);
  }

  void setDateRange(DateTimeRange<DateTime>? value) {
    if (_startDate == value?.start && _endDate == value?.end) return;
    _startDate = value?.start;
    _endDate = value?.end;
    _currentPage = 1;
    notifyListeners();
    fetch();
  }

  void clearDateRange() => setDateRange(null);

  void search(String query, {Duration delay = const Duration(milliseconds: 400)}) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(delay, () {
      final trimmed = query.trim();
      if (_searchQuery == trimmed) {
        return;
      }
      _searchQuery = trimmed;
      _currentPage = 1;
      notifyListeners();
      fetch();
    });
  }

  void cancelSearchDebounce() {
    _searchDebounce?.cancel();
    _searchDebounce = null;
  }

  Future<void> fetchPagedData({
    required Future<Result<ApiResponse<List<T>>?>> Function(int skip, int take) fetchMethod,
  }) async {
    final skip = (_currentPage - 1) * _pageSize;

    await execute(
      const OperationKey.fetch(),
      operation: () => fetchMethod(skip, _pageSize),
      onData: (apiResponse) {
        if (apiResponse?.isSuccess == true) {
          _items = apiResponse?.data ?? [];
          _totalCount = apiResponse?.totalCount ?? 0;
        } else {
          _items = [];
          _totalCount = 0;
        }
        notifyListeners();
      },
      onFailed: (_) async {
        _items = [];
        _totalCount = 0;
        notifyListeners();
      },
    );
  }

  /// Kategori/tab değişiminde her şeyi sıfırlayan tek nokta.
  /// Notifier kendi filtre state'ini de sıfırladıktan sonra reload çağırır.
  void resetFilters({bool notify = true}) {
    _searchDebounce?.cancel();
    final changed = _searchQuery.isNotEmpty || _currentPage != 1 || _startDate != null || _endDate != null;
    _searchQuery = '';
    _startDate = null;
    _endDate = null;
    _currentPage = 1;
    if (notify && changed) notifyListeners();
  }
}
