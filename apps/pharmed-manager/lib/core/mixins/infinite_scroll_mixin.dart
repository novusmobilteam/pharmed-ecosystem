// [SWREQ-MGR-TABLE-INFINITE-001] [IEC 62304 §5.5]
//
// PaginationMixin'in sonsuz kaydırma karşılığı: ilk sayfa filtre/arama/tarih
// değişince baştan çekilir, sonraki sayfalar [loadMore] ile listenin SONUNA
// eklenir. MedTable(enableInfiniteScroll: true) ile birlikte kullanılır:
//   items → data, hasMore, isLoadingMore, loadMore → onLoadMore,
//   isFirstPageLoading → isLoading, totalCount → serverTotalCount.
//
// Yarış koruması: filtre değiştiğinde nesil (_generation) artar; eski
// nesilden dönen yanıt yok sayılır — aksi halde önceki filtrenin sayfası yeni
// listeye eklenebilirdi.
//
// Sınıf: Class B

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

import 'api_request_mixin.dart';

mixin InfiniteScrollMixin<T> on ApiRequestMixin {
  static const firstPageOp = OperationKey.custom('infinite-first-page');
  static const nextPageOp = OperationKey.custom('infinite-next-page');

  int _pageSize = 50;
  int get pageSize => _pageSize;

  List<T> _items = [];
  List<T> get items => _items;

  /// Sunucunun bildirdiği toplam. Bilinmiyorsa (≤ 0) son sayfanın boyutuna
  /// bakılarak [hasMore] belirlenir.
  int _totalCount = 0;
  int get totalCount => _totalCount;

  bool _reachedEnd = false;

  bool get hasMore => !_reachedEnd && (_totalCount <= 0 || _items.length < _totalCount);

  bool get isFirstPageLoading => isLoading(firstPageOp);
  bool get isLoadingMore => isLoading(nextPageOp);

  int _generation = 0;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;
  Timer? _searchDebounce;

  DateTimeRange? _dateRange;
  DateTimeRange? get dateRange => _dateRange;
  DateTime? get startDate => _dateRange?.start;
  DateTime? get endDate => _dateRange?.end;

  /// Notifier mevcut filtre state'iyle tek bir sayfa çeker.
  Future<Result<ApiResponse<List<T>>?>> fetchPage(int skip, int take);

  void setPageSize(int size) => _pageSize = size;

  /// İlk yüklemeden önce varsayılan tarih aralığını yükleme tetiklemeden kurar.
  @protected
  void initDateRange(DateTimeRange? range) => _dateRange = range;

  /// Listeyi temizleyip ilk sayfayı çeker — her filtre değişiminde çağrılır.
  Future<void> reload() async {
    final generation = ++_generation;
    _items = [];
    _totalCount = 0;
    _reachedEnd = false;
    notifyListeners();

    await execute(
      firstPageOp,
      operation: () => fetchPage(0, _pageSize),
      onData: (response) {
        if (generation != _generation) return;
        _apply(response, append: false);
      },
      onFailed: (_) {
        if (generation != _generation) return;
        _reachedEnd = true;
        notifyListeners();
      },
    );
  }

  /// Sonraki sayfayı listenin sonuna ekler.
  Future<void> loadMore() async {
    if (!hasMore || isLoadingMore || isFirstPageLoading) return;
    final generation = _generation;

    await execute(
      nextPageOp,
      operation: () => fetchPage(_items.length, _pageSize),
      onData: (response) {
        if (generation != _generation) return;
        _apply(response, append: true);
      },
      // Hata: tekrar denemek için kullanıcı aşağı kaydırmaya devam edebilir;
      // sonsuz döngüye girmemek için bu nesilde dur.
      onFailed: (_) {
        if (generation != _generation) return;
        _reachedEnd = true;
        notifyListeners();
      },
    );
  }

  void _apply(ApiResponse<List<T>>? response, {required bool append}) {
    final page = response?.isSuccess == true ? (response?.data ?? <T>[]) : <T>[];
    _items = append ? [..._items, ...page] : page;
    _totalCount = response?.totalCount ?? 0;
    if (page.length < _pageSize) _reachedEnd = true;
    notifyListeners();
  }

  void setDateRange(DateTimeRange? value) {
    if (_dateRange?.start == value?.start && _dateRange?.end == value?.end) return;
    _dateRange = value;
    reload();
  }

  void search(String query, {Duration delay = const Duration(milliseconds: 400)}) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(delay, () {
      final trimmed = query.trim();
      if (_searchQuery == trimmed) return;
      _searchQuery = trimmed;
      reload();
    });
  }

  void cancelSearchDebounce() {
    _searchDebounce?.cancel();
    _searchDebounce = null;
  }
}
