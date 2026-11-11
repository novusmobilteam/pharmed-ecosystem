import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

part 'table_side_panel.dart';
part 'table_toolbar.dart';
part 'table_body.dart';
part 'table_footer.dart';
part 'table_date_filter.dart';

// ─── COLUMN META (dahili) ────────────────────────────────────────────────────
//
// [index]        → kolonun listedeki sırası (sort state, filter state key'i)
// [contentIndex] → item.content[] index'i; columnDefs ile farklı olabilir

class _ColMeta<T> {
  final int index;
  final String title;
  final double flex;
  final bool numeric;
  final Widget? Function(T)? cellBuilder;
  final String? Function(T)? displayValue;
  final Comparable? Function(T)? sortValue;
  final TableServerFilter? serverFilter;

  const _ColMeta({
    required this.index,
    required this.title,
    required this.flex,
    required this.numeric,
    this.cellBuilder,
    this.displayValue,
    this.sortValue,
    this.serverFilter,
  });

  bool get sortable => sortValue != null || displayValue != null || numeric;
  bool get isServerFiltered => serverFilter != null;
  bool get filterable => isServerFiltered || displayValue != null || !numeric;

  /// Filtre, export ve fallback text için tek kaynak.
  String valueOf(T item) {
    return displayValue?.call(item) ?? '-';
  }

  /// Sıralama için karşılaştırılabilir değer.
  Comparable? sortKeyOf(T item) {
    if (sortValue != null) return sortValue!(item);
    if (displayValue != null) return displayValue!(item);
    return null;
  }
}

// ─── UNIFIED TABLE VIEW ───────────────────────────────────────────────────────

class MedTable<T extends Object> extends StatefulWidget {
  const MedTable({
    super.key,
    required this.data,
    // Kategori paneli
    this.categories,
    this.selectedCategoryId,
    this.onCategoryChanged,
    // Kolon tanımları — ikisinden biri kullanılır:
    //   1) columnDefs → tam kontrol (başlık, flex, tip, contentIndex)
    //   2) item.titles + numericColumnIndices + columnFlexes → eski yöntem
    required this.columnDefs,
    this.numericColumnIndices = const {},
    this.columnFlexes,
    // Yatay kaydırma
    this.horizontalScroll = false,
    this.minTableWidth,
    // Arama
    this.enableSearch = false,
    this.onSearchChanged,
    // Export
    this.enableExcel = false,
    this.enablePDF = false,
    this.exportFileName = 'Export',
    this.onExcelPressed,
    this.onPdfPressed,
    this.pdfTitle,
    this.pdfHeaderBuilder,
    // Tarih filtresi
    this.enableDateFilter = false,
    this.enableTimeFilter = false,
    this.onDateRangeChanged,
    // Seçim
    this.selectionMode = TableSelectionMode.none,
    this.onSelectionChanged,
    this.onSingleSelectionChanged,
    this.selectionActions,
    // Satır aksiyonları
    this.actions = const [],
    // Custom cell render
    this.cellBuilder,
    // Pagination
    this.enablePagination = false,
    this.pagedScroll = true,
    this.enableInfiniteScroll = false,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.onLoadMore,
    this.summary,
    this.exportSummaryRow,
    this.currentPage,
    this.pageSize,
    this.serverTotalCount,
    this.onPageChanged,
    // Durum
    this.isLoading = false,
    this.emptyWidget,
    this.loadingWidget,
    this.categoryTitle,
    this.initialDateRange,
    this.toolbarActions,
    this.rowColor,
    this.selectedCategoryIds = const {},
    this.onCategorySelectionChanged,
    this.serverFilters = const {},
    this.onServerFiltersChanged,
  });

  final List<T> data;

  // ── Kategori paneli ──────────────────────────────────────────────────────────
  final List<TableSideCategory>? categories;
  final String? selectedCategoryId;
  final ValueChanged<String>? onCategoryChanged;

  /// Yan paneldeki kategoriler için çoklu seçim.
  /// Verilirse yan panel checkbox'lı çoklu moda geçer.
  /// Satır seçimi ([onSelectionChanged]) ile ilgisi yoktur.
  final Set<String> selectedCategoryIds;
  final ValueChanged<Set<String>>? onCategorySelectionChanged;

  // ── Kolon ────────────────────────────────────────────────────────────────────
  /// Verilirse item.titles / numericColumnIndices / columnFlexes yerine geçer.
  /// Tab/index'e göre farklı kolonlar göstermek için idealdir.
  final List<TableColumnDef<T>> columnDefs;

  /// columnDefs verilmemişse: hangi content index'leri numeric (sıralanabilir)
  final Set<int> numericColumnIndices;

  /// columnDefs verilmemişse: her kolonun flex genişliği
  final List<double>? columnFlexes;

  // ── Yatay kaydırma ───────────────────────────────────────────────────────────
  final bool horizontalScroll;
  final double? minTableWidth;

  // ── Arama ────────────────────────────────────────────────────────────────────
  final bool enableSearch;
  final ValueChanged<String>? onSearchChanged;

  // ── Export ───────────────────────────────────────────────────────────────────
  final bool enableExcel;
  final bool enablePDF;
  final String exportFileName;
  final VoidCallback? onExcelPressed;
  final VoidCallback? onPdfPressed;

  /// PDF başlığı (basit string). pdfHeaderBuilder verilirse yok sayılır.
  final String? pdfTitle;

  /// PDF üst başlık bloğunu ekran tarafında kurmak için (uzun başlık,
  /// hasta bilgi satırları vb.). Verilirse pdfTitle yerine bu kullanılır.
  final PdfHeaderBuilder? pdfHeaderBuilder;

  // ── Tarih filtresi ────────────────────────────────────────────────────────────
  final bool enableDateFilter;

  /// true → tarih filtresinde başlangıç/bitiş saati de seçilir; hazır
  /// aralıklar günün başından (00:00) bitiş gününün sonuna (23:59:59) kadar
  /// uzanır. false → eski davranış (yalnızca gün).
  final bool enableTimeFilter;
  final ValueChanged<DateTimeRange?>? onDateRangeChanged;

  // ── Seçim ────────────────────────────────────────────────────────────────────
  final TableSelectionMode selectionMode;

  /// [multi] modunda seçili item seti değişince tetiklenir
  final void Function(Set<T> selectedItems)? onSelectionChanged;

  /// [single] modunda seçili item (veya null) değişince tetiklenir
  final ValueChanged<T?>? onSingleSelectionChanged;

  /// Seçim modunda toolbar'da görünen özel aksiyon butonları
  final List<Widget>? selectionActions;

  // ── Satır aksiyonları ────────────────────────────────────────────────────────
  final List<TableActionItem<T>> actions;

  // ── Custom cell render ───────────────────────────────────────────────────────
  final CellBuilder<T>? cellBuilder;

  // ── Pagination ───────────────────────────────────────────────────────────────
  final bool enablePagination;

  /// [enablePagination] açıkken sayfa footer'ı yerine kaydırdıkça yükleme:
  /// tablo gelen sayfaları kendi içinde biriktirir ve listenin sonuna
  /// yaklaşınca [onPageChanged] ile sıradaki sayfayı ister. Notifier tarafında
  /// değişiklik gerekmez — sayfa 1'e dönen her istek (filtre/arama/kategori)
  /// listeyi baştan başlatır. false → klasik sayfa footer'ı.
  ///
  /// [currentPage] verilmezse hangi sayfanın geldiği bilinemeyeceği için
  /// klasik sayfalamaya düşülür.
  final bool pagedScroll;

  // ── Sonsuz kaydırma (dışarıdan yönetilen; enablePagination yerine) ──────────
  /// true → sayfa footer'ı yerine liste sonuna yaklaşınca [onLoadMore] çağrılır.
  final bool enableInfiniteScroll;

  /// Sunucuda yüklenmemiş kayıt kaldı mı.
  final bool hasMore;

  /// Sonraki sayfa yükleniyor — liste yerinde kalır, altta ince bir gösterge
  /// çıkar ([isLoading] ise tüm tabloyu yükleniyor durumuna alır).
  final bool isLoadingMore;
  final VoidCallback? onLoadMore;

  /// Footer'ın hemen üstünde gösterilen özet satırı (ör. miktar toplamı).
  final Widget? summary;

  /// Verilirse Excel/PDF çıktısının sonuna eklenen özet satırı (kolon
  /// sayısıyla aynı uzunlukta; boş hücreler için '').
  final List<String>? exportSummaryRow;

  final int? currentPage;
  final int? pageSize;
  final int? serverTotalCount;
  final ValueChanged<int>? onPageChanged;

  // ── Durum ────────────────────────────────────────────────────────────────────
  final bool isLoading;
  final Widget? emptyWidget;
  final Widget? loadingWidget;

  final String? categoryTitle;

  final DateTimeRange? initialDateRange;

  final List<Widget>? toolbarActions;

  /// Satır zemini (ör. duruma göre boyama). null dönerse varsayılan zebra.
  /// Seçili / üzerine gelinen satır rengi bunun önüne geçer.
  final Color? Function(T item)? rowColor;

  // ── Server-side kolon filtreleri ────────────────────────────────────────────
  /// Key: TableServerFilter.field, value: seçili option değerleri.
  /// Kontrollü (controlled) — state notifier'da tutulur.
  final Map<String, Set<Object>> serverFilters;
  final ValueChanged<Map<String, Set<Object>>>? onServerFiltersChanged;

  @override
  State<MedTable<T>> createState() => _MedTableState<T>();
}

class _MedTableState<T extends Object> extends State<MedTable<T>> {
  final _searchController = TextEditingController();
  int? _sortColIndex;
  bool _sortAsc = true;

  // Key: _ColMeta.index (kolonun listedeki sırası).
  // contentIndex DEĞİL — displayValue kolonlarının content karşılığı
  // olmayabilir ve iki kolon aynı contentIndex'e düşebilir.
  final Map<int, Set<String>> _colFilters = {};

  final Set<T> _selectedItems = {};
  DateTimeRange? _currentDateRange;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
    _absorbPage();

    // Initial date range varsa uygula
    if (widget.initialDateRange != null) {
      _currentDateRange = widget.initialDateRange;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onDateRangeChanged?.call(_currentDateRange);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(MedTable<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.data, widget.data)) {
      final appended = _absorbPage();
      // Kaydırarak sonraki sayfa eklendiyse kullanıcının kolon filtreleri korunur.
      if (!appended) _colFilters.clear();
      final data = _data;
      _selectedItems.removeWhere((item) => !data.contains(item));
    }
    // columnDefs değişince sort/filter sıfırla
    if (oldWidget.columnDefs != widget.columnDefs) {
      _colFilters.clear();
      _sortColIndex = null;
    }
  }

  /// Client + server filtrelerinin birleşik görünümü (sadece gösterim için).
  Map<int, Set<String>> get _displayColFilters {
    final merged = Map<int, Set<String>>.from(_colFilters);
    for (final col in _cols) {
      final sf = col.serverFilter;
      if (sf == null) continue;
      final selected = widget.serverFilters[sf.field];
      if (selected == null || selected.isEmpty) continue;
      merged[col.index] = sf.options.where((o) => selected.contains(o.value)).map((o) => o.label).toSet();
    }
    return merged;
  }

  void _setServerFilter(String field, Set<Object> values) {
    final next = Map<String, Set<Object>>.from(widget.serverFilters);
    values.isEmpty ? next.remove(field) : next[field] = values;
    widget.onServerFiltersChanged?.call(next);
  }

  void _removeColFilter(int colIndex) {
    final sf = _cols[colIndex].serverFilter;
    if (sf != null) {
      _setServerFilter(sf.field, {});
    } else {
      setState(() => _colFilters.remove(colIndex));
    }
  }

  // ── Kolon meta ───────────────────────────────────────────────────────────────

  List<_ColMeta<T>> get _cols => List.generate(widget.columnDefs.length, (i) {
    final def = widget.columnDefs[i];
    return _ColMeta<T>(
      index: i,
      title: def.title,
      flex: def.flex,
      numeric: def.numeric,
      cellBuilder: def.cellBuilder,
      displayValue: def.displayValue,
      sortValue: def.sortValue,
      serverFilter: def.serverFilter,
    );
  });

  double get _totalFlex {
    final cols = _cols;
    if (cols.isEmpty) return 1.0;
    return cols.fold(0.0, (s, c) => s + c.flex);
  }

  // ── Filtreleme ve sıralama ───────────────────────────────────────────────────

  // ── Kaydırdıkça sayfa yükleme (pagedScroll) ─────────────────────────────────

  /// Sayfa no → o sayfanın kayıtları. Yalnızca [_pagedMode]'da kullanılır.
  final Map<int, List<T>> _pages = {};

  /// İstenip henüz gelmemiş sayfa — aynı kaydırma hareketinde tekrar istenmesin.
  int? _requestedPage;

  bool get _pagedMode =>
      widget.enablePagination && widget.pagedScroll && !widget.enableInfiniteScroll && widget.currentPage != null;

  int get _lastLoadedPage => _pages.isEmpty ? 0 : _pages.keys.reduce(math.max);

  /// Tablonun gösterdiği tüm kayıtlar.
  List<T> get _data {
    if (!_pagedMode) return widget.data;
    if (_pages.isEmpty) return widget.data;
    final keys = _pages.keys.toList()..sort();
    return [for (final k in keys) ..._pages[k]!];
  }

  /// Yeni gelen [widget.data]'yı [widget.currentPage] sayfası olarak işler.
  /// true → sayfa mevcut listenin sonuna eklendi (sıfırlama değil).
  bool _absorbPage() {
    if (!_pagedMode) {
      _pages.clear();
      _requestedPage = null;
      return false;
    }
    final page = widget.currentPage ?? 1;
    if (page <= 1 || _pages.isEmpty) {
      _pages
        ..clear()
        ..[page] = widget.data;
      _requestedPage = null;
      return false;
    }
    // Daha ileri sayfalar artık geçersiz (ör. kayıt sonrası aynı sayfa
    // yeniden çekildi) — o sayfadan sonrası atılır.
    _pages.removeWhere((k, _) => k > page);
    _pages[page] = widget.data;
    if (_requestedPage != null && page >= _requestedPage!) _requestedPage = null;
    return true;
  }

  bool get _pagedHasMore {
    if (_pages.isEmpty) return false;
    final loaded = _data.length;
    final total = widget.serverTotalCount ?? 0;
    if (total > 0) return loaded < total;
    // Toplam bilinmiyor (-1): son sayfa dolu geldiyse devamı olabilir.
    final last = _pages[_lastLoadedPage]!;
    final pageSize = widget.pageSize ?? _pages.values.first.length;
    return last.isNotEmpty && last.length >= pageSize;
  }

  /// Sonraki sayfa yükleniyor — liste yerinde kalır, altta ince gösterge.
  bool get _pagedLoadingMore => _pagedMode && widget.isLoading && (widget.currentPage ?? 1) > 1;

  void _requestNextPage() {
    final next = _lastLoadedPage + 1;
    if (_requestedPage != null && _requestedPage! >= next) return;
    _requestedPage = next;
    widget.onPageChanged?.call(next);
  }

  bool get _scrollLoadingEnabled => widget.enableInfiniteScroll || _pagedMode;
  bool get _effectiveHasMore => widget.enableInfiniteScroll ? widget.hasMore : _pagedHasMore;
  bool get _effectiveLoadingMore => widget.enableInfiniteScroll ? widget.isLoadingMore : _pagedLoadingMore;

  /// Tüm tabloyu "yükleniyor" durumuna alır mı — sonraki sayfa yüklenirken hayır.
  bool get _showFullLoading => widget.isLoading && !(_pagedLoadingMore && _data.isNotEmpty);

  List<T> get _filtered {
    var data = List<T>.from(_data);
    final cols = _cols;

    // Client-side arama (onSearchChanged verilmemişse)
    if (widget.onSearchChanged == null) {
      final q = _searchController.text.toLowerCase();
      if (q.isNotEmpty) {
        data = data.where((item) {
          return cols.any((c) => c.valueOf(item).toLowerCase().contains(q));
        }).toList();
      }
    }

    // Kolon filtreleri
    for (final entry in _colFilters.entries) {
      if (entry.value.isEmpty) continue;
      final matches = cols.where((c) => c.index == entry.key);
      if (matches.isEmpty) continue;
      final col = matches.first;
      data = data.where((item) => entry.value.contains(col.valueOf(item))).toList();
    }

    // Sıralama
    if (_sortColIndex != null && _sortColIndex! < cols.length) {
      final col = cols[_sortColIndex!];
      if (col.sortable) {
        data.sort((a, b) {
          final va = col.sortKeyOf(a);
          final vb = col.sortKeyOf(b);
          if (va == null && vb == null) return 0;
          if (va == null) return 1;
          if (vb == null) return -1;
          final cmp = va.compareTo(vb);
          return _sortAsc ? cmp : -cmp;
        });
      }
    }

    return data;
  }

  List<T> get _exportData => _selectedItems.isNotEmpty ? _selectedItems.toList() : _filtered;

  List<String> _uniqueValuesFor(_ColMeta<T> col) {
    return _data.map((item) => col.valueOf(item)).where((v) => v.isNotEmpty && v != '-').toSet().toList()..sort();
  }

  bool get _hasActiveFilters =>
      _displayColFilters.values.any((s) => s.isNotEmpty) ||
      _searchController.text.isNotEmpty ||
      _currentDateRange != null;

  void _applyColFilter(int colIndex, Set<String> values) {
    setState(() {
      if (values.isEmpty) {
        _colFilters.remove(colIndex);
      } else {
        _colFilters[colIndex] = values;
      }
    });
  }

  Future<void> _showColFilterDialog(int colIndex) async {
    final cols = _cols;
    if (colIndex >= cols.length) return;
    final col = cols[colIndex];
    final sf = col.serverFilter;

    final result = await showDialog<Set<String>>(
      context: context,
      barrierColor: Colors.black26,
      builder: (_) => _ColFilterDialog(
        columnTitle: col.title,
        uniqueValues: sf != null ? sf.options.map((o) => o.label).toList() : _uniqueValuesFor(col),
        selected: Set.from(_displayColFilters[col.index] ?? {}),
      ),
    );

    if (result == null || !mounted) return;

    if (sf != null) {
      final values = sf.options.where((o) => result.contains(o.label)).map((o) => o.value).toSet();
      _setServerFilter(sf.field, values);
    } else {
      _applyColFilter(col.index, result);
    }
  }

  void _handleDateFilter() {
    showDialog(
      context: context,
      barrierColor: Colors.black26,
      builder: (_) => _QuickDateFilterPopup(
        selectedDateRange: _currentDateRange,
        showTime: widget.enableTimeFilter,
        onDateSelected: (range) {
          setState(() => _currentDateRange = range);
          widget.onDateRangeChanged?.call(range);
        },
      ),
    );
  }

  void _clearAllFilters() {
    setState(() {
      if (widget.serverFilters.isNotEmpty) widget.onServerFiltersChanged?.call({});
      _colFilters.clear();
      _searchController.clear();
      _currentDateRange = null;
    });
    widget.onSearchChanged?.call('');
    widget.onDateRangeChanged?.call(null);
  }

  // ── Seçim ────────────────────────────────────────────────────────────────────

  void _toggleItem(T item) {
    setState(() {
      if (widget.selectionMode == TableSelectionMode.single) {
        final wasSelected = _selectedItems.contains(item);
        _selectedItems.clear();
        if (!wasSelected) _selectedItems.add(item);
        // setState bittikten SONRA callback — scheduleCallback ile context güvenli
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onSingleSelectionChanged?.call(wasSelected ? null : item);
        });
      } else {
        _selectedItems.contains(item) ? _selectedItems.remove(item) : _selectedItems.add(item);
      }
    });
    if (widget.selectionMode != TableSelectionMode.single) {
      widget.onSelectionChanged?.call(Set.from(_selectedItems));
    }
  }

  void _toggleAll() {
    final filteredData = _filtered;
    final allSelected = filteredData.every(_selectedItems.contains);
    setState(() {
      allSelected ? _selectedItems.removeAll(filteredData) : _selectedItems.addAll(filteredData);
    });
    widget.onSelectionChanged?.call(Set.from(_selectedItems));
  }

  void _clearSelection() {
    setState(() => _selectedItems.clear());
    widget.onSelectionChanged?.call({});
    widget.onSingleSelectionChanged?.call(null);
  }

  // ── Export ───────────────────────────────────────────────────────────────────

  List<List<String>> _buildExportRows() {
    final cols = _cols;
    final rows = _exportData.map((item) => cols.map((c) => c.valueOf(item)).toList()).toList();
    final summaryRow = widget.exportSummaryRow;
    if (summaryRow != null && summaryRow.length == cols.length) rows.add(summaryRow);
    return rows;
  }

  Future<void> _handleExcel() async {
    if (widget.onExcelPressed != null) return widget.onExcelPressed!();
    await ExcelExportService.exportRows(
      fileName: widget.exportFileName,
      columns: _cols.map((c) => c.title).toList(),
      rows: _buildExportRows(),
      context: context,
    );
  }

  Future<void> _handlePdf() async {
    if (widget.onPdfPressed != null) return widget.onPdfPressed!();
    await PdfExportService.exportRows(
      fileName: widget.exportFileName,
      columns: _cols.map((c) => c.title).toList(),
      rows: _buildExportRows(),
      context: context,
      title: widget.pdfTitle ?? context.l10n.table_defaultPdfReportTitle,
      headerBuilder: widget.pdfHeaderBuilder,
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final showSidePanel = widget.categories != null && widget.categories!.isNotEmpty;
    final filteredData = _filtered;
    final cols = _cols;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showSidePanel) ...[
              _SidePanel(
                title: widget.categoryTitle,
                categories: widget.categories!,
                selectedId: widget.selectedCategoryId,
                selectedIds: widget.selectedCategoryIds,
                onSelectionChanged: widget.onCategorySelectionChanged,
                onSelect: (id) {
                  setState(() {
                    _colFilters.clear();
                    _selectedItems.clear();
                  });
                  widget.onCategoryChanged?.call(id);
                },
              ),
              const VerticalDivider(width: 1, color: Color(0xFFEEF0F4)),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _TableToolbar<T>(
                    searchController: _searchController,
                    enableSearch: widget.enableSearch,
                    toolbarActions: widget.toolbarActions,
                    onSearchChanged: (q) {
                      setState(() {});
                      widget.onSearchChanged?.call(q);
                    },
                    enableExcel: widget.enableExcel,
                    enablePDF: widget.enablePDF,
                    onExcelPressed: _handleExcel,
                    onPdfPressed: _handlePdf,
                    enableDateFilter: widget.enableDateFilter,
                    currentDateRange: _currentDateRange,
                    onDateFilterPressed: _handleDateFilter,
                    selectionMode: widget.selectionMode,
                    selectedCount: _selectedItems.length,
                    onClearSelection: _clearSelection,
                    selectionActions: widget.selectionActions,
                  ),
                  if (_hasActiveFilters)
                    _ActiveFilterBar<T>(
                      colFilters: _displayColFilters,
                      cols: cols,
                      searchQuery: _searchController.text,
                      currentDateRange: _currentDateRange,
                      showTime: widget.enableTimeFilter,
                      onClearAll: _clearAllFilters,
                      onRemoveColFilter: _removeColFilter,
                      onClearSearch: () {
                        setState(() => _searchController.clear());
                        widget.onSearchChanged?.call('');
                      },
                      onClearDateRange: () {
                        setState(() => _currentDateRange = null);
                        widget.onDateRangeChanged?.call(null);
                      },
                    ),
                  const Divider(height: 1, color: Color(0xFFEEF0F4)),
                  Expanded(
                    child: _showFullLoading
                        ? (widget.loadingWidget ?? const Center(child: CircularProgressIndicator.adaptive()))
                        : _data.isEmpty
                        ? (widget.emptyWidget ?? _defaultEmpty())
                        : _withInfiniteScroll(_buildTableArea(filteredData, cols)),
                  ),
                  if (_scrollLoadingEnabled && _effectiveLoadingMore) const LinearProgressIndicator(minHeight: 2),
                  if (widget.summary != null && !_showFullLoading) ...[
                    const Divider(height: 1, color: Color(0xFFEEF0F4)),
                    widget.summary!,
                  ],
                  const Divider(height: 1, color: Color(0xFFEEF0F4)),
                  _TableFooter(
                    filteredCount: filteredData.length,
                    // Kaydırarak yüklemede "yüklenen / sunucudaki toplam" gösterilir.
                    totalCount: _scrollLoadingEnabled && (widget.serverTotalCount ?? -1) > _data.length
                        ? widget.serverTotalCount!
                        : _data.length,
                    enablePagination: widget.enablePagination && !_scrollLoadingEnabled,
                    currentPage: widget.currentPage,
                    pageSize: widget.pageSize,
                    serverTotalCount: widget.serverTotalCount,
                    onPageChanged: widget.onPageChanged,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Dikey liste sonuna ~[_loadMoreThreshold] px kala (≈ 13-14 satır), ya da
  /// ilk sayfa ekranı doldurmadığında (kaydırılacak bir şey yoksa) bir sonraki
  /// sayfayı ister — kullanıcı listenin sonuna gelmeden veri hazır olur.
  /// Yükleme sürerken veya kayıt kalmadıysa tetiklemez.
  static const double _loadMoreThreshold = 600;

  Widget _withInfiniteScroll(Widget child) {
    if (!_scrollLoadingEnabled) return child;

    void check(ScrollMetrics metrics) {
      if (metrics.axis != Axis.vertical) return;
      if (!_effectiveHasMore || _effectiveLoadingMore || widget.isLoading) return;
      if (metrics.extentAfter >= _loadMoreThreshold) return;
      if (widget.enableInfiniteScroll) {
        widget.onLoadMore?.call();
      } else {
        _requestNextPage();
      }
    }

    return NotificationListener<Notification>(
      onNotification: (n) {
        if (n is ScrollUpdateNotification) check(n.metrics);
        if (n is ScrollMetricsNotification) check(n.metrics);
        return false;
      },
      child: child,
    );
  }

  Widget _buildTableArea(List<T> filteredData, List<_ColMeta<T>> cols) {
    return _TableBody<T>(
      data: filteredData,
      cols: cols,
      totalFlex: _totalFlex,
      sortColIndex: _sortColIndex,
      sortAsc: _sortAsc,
      colFilters: _displayColFilters,
      selectionMode: widget.selectionMode,
      selectedItems: _selectedItems,
      onToggleItem: _toggleItem,
      onToggleAll: _toggleAll,
      actions: widget.actions,
      horizontalScroll: widget.horizontalScroll,
      minRowWidth: widget.minTableWidth,
      rowColor: widget.rowColor,
      onSort: (i) => setState(() {
        _sortColIndex == i ? _sortAsc = !_sortAsc : (_sortColIndex = i, _sortAsc = true);
      }),
      onFilterPressed: _showColFilterDialog,
    );
  }

  Widget _defaultEmpty() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.inbox_outlined, size: 40, color: Color(0xFFD1D5DB)),
        const SizedBox(height: 8),
        Text(context.l10n.table_noDataTitle, style: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF))),
      ],
    ),
  );
}
