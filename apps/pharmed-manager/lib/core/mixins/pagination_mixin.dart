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

  Timer? _searchDebounce;

  List<T> get items => _items;
  int get totalCount => _totalCount;
  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  bool get isEmpty => _totalCount <= 0;

  bool get isTableLoading => isLoading(const OperationKey.fetch());

  int get totalPages => (_totalCount / _pageSize).ceil();
  bool get canGoNext => _currentPage < totalPages;
  bool get canGoPrev => _currentPage > 1;

  // ── Sayfa yönetimi ────────────────────────────────────────────────────────

  void setPageSize(int newSize) {
    if (_pageSize == newSize) return;
    _pageSize = newSize;
    _currentPage = 1;
    notifyListeners();
  }

  void setPage(int page) {
    if (page < 1 || (totalPages > 0 && page > totalPages)) return;
    _currentPage = page;
    notifyListeners();
  }

  void nextPage() {
    if (canGoNext) setPage(_currentPage + 1);
  }

  void previousPage() {
    if (canGoPrev) setPage(_currentPage - 1);
  }

  // ── Debounced arama ───────────────────────────────────────────────────────
  //
  // Kullanım: notifier'da ayrıca Timer tanımlamaya gerek yok.
  //
  //   void search(String query) {
  //     debouncedSearch(query, () {
  //       _searchQuery = query;
  //       setPage(1);
  //       getUsers();
  //     });
  //   }

  void debouncedSearch(String query, VoidCallback onSearch, {Duration delay = const Duration(milliseconds: 400)}) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(delay, onSearch);
  }

  /// Debounce timer'ını iptal eder.
  /// Notifier'ın dispose()'unda çağrılmalıdır.
  void cancelSearchDebounce() => _searchDebounce?.cancel();

  // ── Veri çekme ────────────────────────────────────────────────────────────

  Future<void> fetchPagedData({
    required Future<Result<ApiResponse<List<T>>>> Function(int skip, int take) fetchMethod,
  }) async {
    final skip = (_currentPage - 1) * _pageSize;

    await execute<ApiResponse<List<T>>>(
      const OperationKey.fetch(),
      operation: () => fetchMethod(skip, _pageSize),
      onData: (apiResponse) {
        if (apiResponse.isSuccess == true) {
          _items = apiResponse.data ?? [];
          _totalCount = apiResponse.totalCount ?? 0;
        } else {
          _items = [];
          _totalCount = 0;
        }
        notifyListeners();
      },
      onFailed: (error) async {
        _items = [];
        _totalCount = 0;
        notifyListeners();
      },
    );
  }
}
