import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core.dart';
import '../../services/export/excel_export_service.dart';
import '../../services/export/pdf_export_service.dart';
import 'unified_table_models.dart';

part 'unified_table_side_panel.dart';
part 'unified_table_toolbar.dart';
part 'unified_table_body.dart';
part 'unified_table_footer.dart';
part 'unified_table_date_filter.dart';

// ─── COLUMN META (dahili) ────────────────────────────────────────────────────
//
// [index]        → kolonun listedeki sırası (sort state, filter state key'i)
// [contentIndex] → item.content[] index'i; columnDefs ile farklı olabilir

class _ColMeta {
  final int index;
  final int contentIndex;
  final String title;
  final double flex;
  final bool numeric;

  const _ColMeta({
    required this.index,
    required this.contentIndex,
    required this.title,
    required this.flex,
    required this.numeric,
  });

  bool get filterable => !numeric;
  bool get sortable => numeric;
}

// ─── UNIFIED TABLE VIEW ───────────────────────────────────────────────────────

class UnifiedTableView<T extends TableData> extends StatefulWidget {
  const UnifiedTableView({
    super.key,
    required this.data,
    // Kategori paneli
    this.categories,
    this.selectedCategoryId,
    this.onCategoryChanged,
    // Kolon tanımları — ikisinden biri kullanılır:
    //   1) columnDefs → tam kontrol (başlık, flex, tip, contentIndex)
    //   2) item.titles + numericColumnIndices + columnFlexes → eski yöntem
    this.columnDefs,
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
    // Tarih filtresi
    this.enableDateFilter = false,
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
  });

  final List<T> data;

  // ── Kategori paneli ──────────────────────────────────────────────────────────
  final List<TableSideCategory>? categories;
  final String? selectedCategoryId;
  final ValueChanged<String>? onCategoryChanged;

  // ── Kolon ────────────────────────────────────────────────────────────────────
  /// Verilirse item.titles / numericColumnIndices / columnFlexes yerine geçer.
  /// Tab/index'e göre farklı kolonlar göstermek için idealdir.
  final List<TableColumnDef>? columnDefs;

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

  // ── Tarih filtresi ────────────────────────────────────────────────────────────
  final bool enableDateFilter;
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

  @override
  State<UnifiedTableView<T>> createState() => _UnifiedTableViewState<T>();
}

class _UnifiedTableViewState<T extends TableData> extends State<UnifiedTableView<T>> {
  final _searchController = TextEditingController();
  int? _sortColIndex;
  bool _sortAsc = true;

  // Key: _ColMeta.contentIndex (hangi içeriği filtrelediği)
  final Map<int, Set<String>> _colFilters = {};

  final Set<T> _selectedItems = {};
  DateTimeRange? _currentDateRange;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));

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
  void didUpdateWidget(UnifiedTableView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _colFilters.clear();
      _selectedItems.removeWhere((item) => !widget.data.contains(item));
    }
    // columnDefs değişince sort/filter sıfırla
    if (oldWidget.columnDefs != widget.columnDefs) {
      _colFilters.clear();
      _sortColIndex = null;
    }
  }

  // ── Kolon meta ───────────────────────────────────────────────────────────────

  List<_ColMeta> get _cols {
    // 1) columnDefs verilmişse onu kullan
    if (widget.columnDefs != null) {
      return List.generate(widget.columnDefs!.length, (i) {
        final def = widget.columnDefs![i];
        return _ColMeta(
          index: i,
          contentIndex: def.contentIndex ?? i,
          title: def.title,
          flex: def.flex,
          numeric: def.numeric,
        );
      });
    }

    // 2) Klasik yol: item.titles
    if (widget.data.isEmpty) return [];
    final titles = widget.data.first.titles;
    final flexes = widget.columnFlexes;
    return List.generate(titles.length, (i) {
      return _ColMeta(
        index: i,
        contentIndex: i,
        title: titles[i] ?? 'Sütun ${i + 1}',
        flex: (flexes != null && i < flexes.length) ? flexes[i] : 1.0,
        numeric: widget.numericColumnIndices.contains(i),
      );
    });
  }

  double get _totalFlex {
    final cols = _cols;
    if (cols.isEmpty) return 1.0;
    return cols.fold(0.0, (s, c) => s + c.flex);
  }

  // ── Filtreleme ve sıralama ───────────────────────────────────────────────────

  List<T> get _filtered {
    var data = List<T>.from(widget.data);

    // Client-side arama
    if (widget.onSearchChanged == null) {
      final q = _searchController.text.toLowerCase();
      if (q.isNotEmpty) {
        data = data
            .where((item) => item.content.any((cell) => cell?.toString().toLowerCase().contains(q) ?? false))
            .toList();
      }
    }

    // Kolon filtreleri (contentIndex bazında)
    for (final entry in _colFilters.entries) {
      if (entry.value.isEmpty) continue;
      data = data.where((item) {
        final ci = entry.key;
        final val = ci < item.content.length ? item.content[ci]?.toString() ?? '' : '';
        return entry.value.contains(val);
      }).toList();
    }

    // Sıralama (rawContent üzerinden)
    if (_sortColIndex != null) {
      final cols = _cols;
      if (_sortColIndex! < cols.length) {
        final col = cols[_sortColIndex!];
        if (col.sortable) {
          dynamic raw(T item) {
            final rc = item.rawContent;
            return col.contentIndex < rc.length ? rc[col.contentIndex] : null;
          }

          data.sort((a, b) {
            final va = raw(a);
            final vb = raw(b);
            if (va == null && vb == null) return 0;
            if (va == null) return 1;
            if (vb == null) return -1;
            if (va is num && vb is num) {
              return _sortAsc ? va.compareTo(vb) : vb.compareTo(va);
            }
            final cmp = va.toString().compareTo(vb.toString());
            return _sortAsc ? cmp : -cmp;
          });
        }
      }
    }

    return data;
  }

  List<T> get _exportData => _selectedItems.isNotEmpty ? _selectedItems.toList() : _filtered;

  List<String> _uniqueValuesFor(int contentIndex) {
    return widget.data
        .map((item) => contentIndex < item.content.length ? item.content[contentIndex]?.toString() ?? '' : '')
        .where((v) => v.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
  }

  bool get _hasActiveFilters =>
      _colFilters.values.any((s) => s.isNotEmpty) || _searchController.text.isNotEmpty || _currentDateRange != null;

  void _applyColFilter(int contentIndex, Set<String> values) {
    setState(() {
      if (values.isEmpty) {
        _colFilters.remove(contentIndex);
      } else {
        _colFilters[contentIndex] = values;
      }
    });
  }

  // async/await → parent context'inde setState güvenli
  Future<void> _showColFilterDialog(int colIndex) async {
    final cols = _cols;
    if (colIndex >= cols.length) return;
    final col = cols[colIndex];

    final result = await showDialog<Set<String>>(
      context: context,
      barrierColor: Colors.black26,
      builder: (_) => _ColFilterDialog(
        columnTitle: col.title,
        uniqueValues: _uniqueValuesFor(col.contentIndex),
        selected: Set.from(_colFilters[col.contentIndex] ?? {}),
      ),
    );

    if (result != null && mounted) {
      _applyColFilter(col.contentIndex, result);
    }
  }

  void _handleDateFilter() {
    showDialog(
      context: context,
      barrierColor: Colors.black26,
      builder: (_) => _QuickDateFilterPopup(
        selectedDateRange: _currentDateRange,
        onDateSelected: (range) {
          setState(() => _currentDateRange = range);
          widget.onDateRangeChanged?.call(range);
        },
      ),
    );
  }

  void _clearAllFilters() {
    setState(() {
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

  Future<void> _handleExcel() async {
    if (widget.onExcelPressed != null) {
      widget.onExcelPressed!();
      return;
    }
    await ExcelExportService.exportTableData(
      fileName: widget.exportFileName,
      columns: _cols.map((c) => c.title).toList(),
      data: _exportData,
      context: context,
    );
  }

  Future<void> _handlePdf() async {
    if (widget.onPdfPressed != null) {
      widget.onPdfPressed!();
      return;
    }
    await PdfExportService.exportTableData(
      fileName: widget.exportFileName,
      columns: _cols.map((c) => c.title).toList(),
      data: _exportData,
      context: context,
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
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
                    _ActiveFilterBar(
                      colFilters: _colFilters,
                      cols: cols,
                      searchQuery: _searchController.text,
                      currentDateRange: _currentDateRange,
                      onClearAll: _clearAllFilters,
                      onRemoveColFilter: (ci) => setState(() => _colFilters.remove(ci)),
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
                    child: widget.isLoading
                        ? (widget.loadingWidget ?? const Center(child: CircularProgressIndicator.adaptive()))
                        : widget.data.isEmpty
                            ? (widget.emptyWidget ?? _defaultEmpty())
                            : _buildTableArea(filteredData, cols),
                  ),
                  const Divider(height: 1, color: Color(0xFFEEF0F4)),
                  _TableFooter(
                    filteredCount: filteredData.length,
                    totalCount: widget.data.length,
                    enablePagination: widget.enablePagination,
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

  Widget _buildTableArea(List<T> filteredData, List<_ColMeta> cols) {
    return _TableBody<T>(
      data: filteredData,
      cols: cols,
      totalFlex: _totalFlex,
      sortColIndex: _sortColIndex,
      sortAsc: _sortAsc,
      colFilters: _colFilters,
      selectionMode: widget.selectionMode,
      selectedItems: _selectedItems,
      onToggleItem: _toggleItem,
      onToggleAll: _toggleAll,
      actions: widget.actions,
      cellBuilder: widget.cellBuilder,
      horizontalScroll: widget.horizontalScroll,
      minRowWidth: widget.minTableWidth,
      onSort: (i) => setState(() {
        _sortColIndex == i ? _sortAsc = !_sortAsc : (_sortColIndex = i, _sortAsc = true);
      }),
      onFilterPressed: _showColFilterDialog,
    );
  }

  Widget _defaultEmpty() => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 40, color: Color(0xFFD1D5DB)),
            SizedBox(height: 8),
            Text(
              'Veri bulunamadı',
              style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
            ),
          ],
        ),
      );
}
