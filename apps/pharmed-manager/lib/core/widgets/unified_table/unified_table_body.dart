part of 'unified_table_view.dart';

class _TableBody<T extends TableData> extends StatelessWidget {
  const _TableBody({
    required this.data,
    required this.cols,
    required this.totalFlex,
    required this.sortColIndex,
    required this.sortAsc,
    required this.colFilters,
    required this.onSort,
    required this.onFilterPressed,
    required this.selectionMode,
    required this.selectedItems,
    required this.onToggleItem,
    required this.onToggleAll,
    required this.actions,
    required this.horizontalScroll,
    this.minRowWidth,
    this.cellBuilder,
  });

  final List<T> data;
  final List<_ColMeta> cols;
  final double totalFlex;
  final int? sortColIndex;
  final bool sortAsc;
  final Map<int, Set<String>> colFilters; // key = contentIndex
  final ValueChanged<int> onSort;
  final Future<void> Function(int) onFilterPressed;
  final TableSelectionMode selectionMode;
  final Set<T> selectedItems;
  final ValueChanged<T> onToggleItem;
  final VoidCallback onToggleAll;
  final List<TableActionItem<T>> actions;
  final bool horizontalScroll;
  final double? minRowWidth;
  final CellBuilder<T>? cellBuilder;

  // Seçim kolonu
  static const double _multiColW = 44.0;
  static const double _singleColW = 32.0;

  // Aksiyon kolonu: her buton için temel genişlik.
  // Butonların kendi genişliği (_btnW) bundan küçük tutulur,
  // böylece başlık metni sıkışmaz.
  static const double _actionColW = 82.0;
  static const double _btnW = 32.0;

  bool get _showMulti => selectionMode == TableSelectionMode.multi;
  bool get _showSingle => selectionMode == TableSelectionMode.single;
  bool get _showSelCol => _showMulti || _showSingle;
  bool get _showActions => actions.isNotEmpty;
  double get _selColW => _showMulti ? _multiColW : _singleColW;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Yatay scroll açıksa minimum genişliği uygula
        final contentWidth =
            horizontalScroll ? math.max(constraints.maxWidth, minRowWidth ?? 800.0) : constraints.maxWidth;

        final fixedW = (_showSelCol ? _selColW : 0.0) + (_showActions ? _actionColW * actions.length : 0.0);
        final available = contentWidth - fixedW;
        final unit = totalFlex > 0 ? available / totalFlex : 0.0;
        final widths = cols.map((c) => c.flex * unit).toList();

        final allSelected = data.isNotEmpty && data.every(selectedItems.contains);
        final someSelected = selectedItems.isNotEmpty && !allSelected;

        final table = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: const Color(0xFFF9FAFB),
              child: Row(
                children: [
                  if (_showSelCol)
                    SizedBox(
                      width: _selColW,
                      child: _showMulti
                          ? Center(
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: Checkbox(
                                  value: allSelected ? true : (someSelected ? null : false),
                                  tristate: true,
                                  onChanged: (_) => onToggleAll(),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  activeColor: const Color(0xFF2563EB),
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),

                  // Veri kolonu başlıkları
                  ...List.generate(
                    cols.length,
                    (i) => _HeaderCell(
                      col: cols[i],
                      width: widths[i],
                      isActive: sortColIndex == i,
                      sortAsc: sortAsc,
                      hasFilter:
                          colFilters.containsKey(cols[i].contentIndex) && colFilters[cols[i].contentIndex]!.isNotEmpty,
                      onSort: cols[i].sortable ? () => onSort(i) : null,
                      onFilter: cols[i].filterable ? () => onFilterPressed(i) : null,
                    ),
                  ),

                  // Aksiyon başlığı — maxLines:1 + ellipsis ile sıkışma önlenir
                  if (_showActions)
                    SizedBox(
                      width: _actionColW * actions.length,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 11),
                        child: Text(
                          'İşlemler',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFEEF0F4)),

            // ── Satırlar ─────────────────────────────────────────────────────
            Expanded(
              child: data.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_off, size: 40, color: Color(0xFFD1D5DB)),
                          SizedBox(height: 8),
                          Text(
                            'Sonuç bulunamadı',
                            style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (_, i) => _TableRow<T>(
                        item: data[i],
                        cols: cols,
                        widths: widths,
                        isEven: i.isEven,
                        selectionMode: selectionMode,
                        isSelected: selectedItems.contains(data[i]),
                        onToggle: () => onToggleItem(data[i]),
                        actions: actions,
                        selColW: _selColW,
                        actionColW: _actionColW,
                        btnW: _btnW,
                        cellBuilder: cellBuilder,
                      ),
                    ),
            ),
          ],
        );

        // Yatay scroll: SizedBox ile genişliği sabitle
        if (horizontalScroll) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(),
            child: SizedBox(width: contentWidth, child: table),
          );
        }
        return table;
      },
    );
  }
}

// ─── HEADER HÜCRESİ ──────────────────────────────────────────────────────────

class _HeaderCell extends StatefulWidget {
  const _HeaderCell({
    required this.col,
    required this.width,
    required this.isActive,
    required this.sortAsc,
    required this.hasFilter,
    this.onSort,
    this.onFilter,
  });

  final _ColMeta col;
  final double width;
  final bool isActive, sortAsc, hasFilter;
  final VoidCallback? onSort;
  final VoidCallback? onFilter;

  @override
  State<_HeaderCell> createState() => _HeaderCellState();
}

class _HeaderCellState extends State<_HeaderCell> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: widget.width,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
        color: _hovered ? const Color(0xFFF0F4FF) : Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (widget.onSort != null)
              Expanded(
                child: GestureDetector(
                  onTap: widget.onSort,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          widget.col.title,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: widget.isActive ? const Color(0xFF2563EB) : const Color(0xFF6B7280),
                          ),
                        ),
                      ),
                      const SizedBox(width: 3),
                      Icon(
                        widget.isActive
                            ? (widget.sortAsc ? Icons.arrow_upward : Icons.arrow_downward)
                            : Icons.unfold_more,
                        size: 12,
                        color: widget.isActive ? const Color(0xFF2563EB) : const Color(0xFFD1D5DB),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: Text(
                  widget.col.title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
            if (widget.onFilter != null)
              GestureDetector(
                onTap: widget.onFilter,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  margin: const EdgeInsets.only(left: 4),
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: widget.hasFilter ? const Color(0xFF2563EB).withValues(alpha: 0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    widget.hasFilter ? Icons.filter_alt : Icons.filter_alt_outlined,
                    size: 13,
                    color: widget.hasFilter ? const Color(0xFF2563EB) : const Color(0xFFD1D5DB),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── TABLO SATIRI ─────────────────────────────────────────────────────────────

class _TableRow<T extends TableData> extends StatefulWidget {
  const _TableRow({
    required this.item,
    required this.cols,
    required this.widths,
    required this.isEven,
    required this.selectionMode,
    required this.isSelected,
    required this.onToggle,
    required this.actions,
    required this.selColW,
    required this.actionColW,
    required this.btnW,
    this.cellBuilder,
  });

  final T item;
  final List<_ColMeta> cols;
  final List<double> widths;
  final bool isEven;
  final TableSelectionMode selectionMode;
  final bool isSelected;
  final VoidCallback onToggle;
  final List<TableActionItem<T>> actions;
  final double selColW;
  final double actionColW;
  final double btnW;
  final CellBuilder<T>? cellBuilder;

  @override
  State<_TableRow<T>> createState() => _TableRowState<T>();
}

class _TableRowState<T extends TableData> extends State<_TableRow<T>> {
  bool _hovered = false;

  bool get _selectable => widget.selectionMode != TableSelectionMode.none;
  bool get _showMulti => widget.selectionMode == TableSelectionMode.multi;
  bool get _showSingle => widget.selectionMode == TableSelectionMode.single;
  bool get _showSelCol => _showMulti || _showSingle;

  String _fmt(dynamic v) {
    if (v == null) return '-';
    if (v is num) return v == v.toInt() ? v.toInt().toString() : v.toString();
    return v.toString();
  }

  Color get _rowBg {
    if (widget.isSelected) return const Color(0xFFEFF6FF);
    if (_hovered) return const Color(0xFFF5F7FA);
    return widget.isEven ? Colors.white : const Color(0xFFFAFAFB);
  }

  @override
  Widget build(BuildContext context) {
    final content = widget.item.content;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: _selectable ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: _selectable ? widget.onToggle : null,
        child: Stack(
          children: [
            // ── Satır içeriği
            AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              decoration: BoxDecoration(
                color: _rowBg,
                border: const Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
              ),
              child: Row(
                children: [
                  // ── Seçim kolonu
                  if (_showSelCol)
                    SizedBox(
                      width: widget.selColW,
                      child: Center(
                        child: _showMulti
                            // Çoklu → checkbox
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: Checkbox(
                                  value: widget.isSelected,
                                  onChanged: (_) => widget.onToggle(),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  activeColor: const Color(0xFF2563EB),
                                ),
                              )
                            // Tekli → radio dot
                            : AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: widget.isSelected ? const Color(0xFF2563EB) : const Color(0xFFD1D5DB),
                                    width: widget.isSelected ? 5.0 : 1.5,
                                  ),
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),

                  // ── Veri hücreleri (contentIndex üzerinden)
                  ...List.generate(widget.cols.length, (i) {
                    final col = widget.cols[i];
                    final ci = col.contentIndex;
                    final value = ci < content.length ? content[ci] : null;
                    final custom = widget.cellBuilder?.call(widget.item, col.index, value);
                    return SizedBox(
                      width: widget.widths[i],
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        child: custom != null
                            ? Align(
                                alignment: Alignment.centerLeft,
                                child: custom,
                              )
                            : Text(
                                _fmt(value),
                                textAlign: TextAlign.left,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: i == 0 ? const Color(0xFF111827) : const Color(0xFF4B5563),
                                  fontWeight: i == 0 ? FontWeight.w500 : FontWeight.w400,
                                ),
                              ),
                      ),
                    );
                  }),

                  // ── Aksiyon butonları
                  // actionColW (boşluk dahil) vs btnW (butonun kendisi) ayrımı
                  // sayesinde başlık metni sıkışmaz, butonlar ortaya hizalanır.
                  if (widget.actions.isNotEmpty)
                    SizedBox(
                      width: widget.actionColW * widget.actions.length,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: widget.actions.map((action) {
                          final visible = action.isVisible?.call(widget.item) ?? true;
                          if (!visible) {
                            return SizedBox(width: widget.btnW);
                          }
                          return _ActionBtn(
                            icon: action.icon,
                            tooltip: action.tooltip,
                            color: action.color,
                            width: widget.btnW,
                            onPressed: () => action.onPressed(widget.item),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),

            // ── Sol seçim çubuğu (Positioned → genişliğe ek yük yok)
            if (widget.isSelected)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(width: 3, color: const Color(0xFF2563EB)),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── ACTION BUTTON ────────────────────────────────────────────────────────────

class _ActionBtn extends StatefulWidget {
  const _ActionBtn({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    required this.width,
    this.color,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final double width;
  final Color? color;

  @override
  State<_ActionBtn> createState() => _ActionBtnState();
}

class _ActionBtnState extends State<_ActionBtn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.color ?? const Color(0xFF6B7280);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Tooltip(
        message: widget.tooltip,
        child: GestureDetector(
          onTap: widget.onPressed,
          child: SizedBox(
            width: widget.width,
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _hovered ? c.withValues(alpha: 0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(widget.icon, size: 15, color: c),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── AKTİF FİLTRE ÇUBUĞU ─────────────────────────────────────────────────────

class _ActiveFilterBar extends StatelessWidget {
  const _ActiveFilterBar({
    required this.colFilters,
    required this.cols,
    required this.searchQuery,
    required this.onClearAll,
    required this.onRemoveColFilter,
    required this.onClearSearch,
    this.currentDateRange,
    this.onClearDateRange,
  });

  final Map<int, Set<String>> colFilters; // key = contentIndex
  final List<_ColMeta> cols;
  final String searchQuery;
  final VoidCallback onClearAll, onClearSearch;
  final ValueChanged<int> onRemoveColFilter;
  final DateTimeRange? currentDateRange;
  final VoidCallback? onClearDateRange;

  String _fmt(DateTimeRange r) {
    String p(DateTime d) =>
        '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year.toString().substring(2)}';
    final s = p(r.start);
    final e = p(r.end);
    return s == e ? s : '$s – $e';
  }

  String _titleFor(int contentIndex) {
    try {
      return cols.firstWhere((c) => c.contentIndex == contentIndex).title;
    } catch (_) {
      return 'Sütun';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      color: const Color(0xFFF0F4FF),
      child: Row(
        children: [
          const Icon(Icons.filter_list_rounded, size: 14, color: Color(0xFF2563EB)),
          const SizedBox(width: 6),
          const Text(
            'Filtreler:',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF6B7280)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  if (currentDateRange != null)
                    _FilterChip(
                      label: _fmt(currentDateRange!),
                      icon: Icons.calendar_today_outlined,
                      onRemove: () => onClearDateRange?.call(),
                    ),
                  if (searchQuery.isNotEmpty)
                    _FilterChip(
                      label: '"$searchQuery"',
                      onRemove: onClearSearch,
                    ),
                  ...colFilters.entries.where((e) => e.value.isNotEmpty).map((e) => _FilterChip(
                        label: '${_titleFor(e.key)}: ${e.value.length} seçili',
                        onRemove: () => onRemoveColFilter(e.key),
                      )),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: onClearAll,
            child: const Text(
              'Temizle',
              style: TextStyle(fontSize: 12, color: Color(0xFF2563EB), fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.onRemove, this.icon});

  final String label;
  final VoidCallback onRemove;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFDBEAFE),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2563EB).withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: const Color(0xFF1D4ED8)),
            const SizedBox(width: 3),
          ],
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF1D4ED8))),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close, size: 11, color: Color(0xFF1D4ED8)),
          ),
        ],
      ),
    );
  }
}

// ─── KOLON FİLTRE DİYALOĞU ───────────────────────────────────────────────────

class _ColFilterDialog extends StatefulWidget {
  const _ColFilterDialog({
    required this.columnTitle,
    required this.uniqueValues,
    required this.selected,
  });

  final String columnTitle;
  final List<String> uniqueValues;
  final Set<String> selected;

  @override
  State<_ColFilterDialog> createState() => _ColFilterDialogState();
}

class _ColFilterDialogState extends State<_ColFilterDialog> {
  late Set<String> _selected;
  late List<String> _filtered;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selected = Set.from(widget.selected);
    _filtered = List.from(widget.uniqueValues);
    _searchCtrl.addListener(() {
      final q = _searchCtrl.text.toLowerCase();
      setState(() {
        _filtered = q.isEmpty
            ? List.from(widget.uniqueValues)
            : widget.uniqueValues.where((v) => v.toLowerCase().contains(q)).toList();
      });
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  bool get _allSelected => _filtered.isNotEmpty && _filtered.every(_selected.contains);

  void _toggleAll() => setState(() => _allSelected ? _selected.removeAll(_filtered) : _selected.addAll(_filtered));

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: Colors.white,
      child: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFEEF0F4)))),
              child: Row(
                children: [
                  Expanded(
                    child: Text(widget.columnTitle,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context, null),
                    child: const Icon(Icons.close, size: 16, color: Color(0xFF9CA3AF)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
              child: SizedBox(
                height: 34,
                child: TextField(
                  controller: _searchCtrl,
                  autofocus: true,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Ara...',
                    hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                    prefixIcon: const Icon(Icons.search, size: 16, color: Color(0xFF9CA3AF)),
                    filled: true,
                    fillColor: const Color(0xFFF8F9FB),
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5)),
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: _toggleAll,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: Checkbox(
                        value: _allSelected,
                        onChanged: (_) => _toggleAll(),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        activeColor: const Color(0xFF2563EB),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Tümünü Seç (${_filtered.length})',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF2563EB)),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1, color: Color(0xFFEEF0F4)),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240),
              child: _filtered.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: Text('Sonuç yok', style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)))),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: _filtered.length,
                      itemBuilder: (_, i) {
                        final val = _filtered[i];
                        final checked = _selected.contains(val);
                        return InkWell(
                          onTap: () => setState(() => checked ? _selected.remove(val) : _selected.add(val)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: Checkbox(
                                    value: checked,
                                    onChanged: (_) =>
                                        setState(() => checked ? _selected.remove(val) : _selected.add(val)),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                    activeColor: const Color(0xFF2563EB),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                    child: Text(val, style: const TextStyle(fontSize: 13, color: Color(0xFF374151)))),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const Divider(height: 1, color: Color(0xFFEEF0F4)),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: _DialogBtn(
                      label: 'Temizle',
                      onPressed: () => Navigator.pop(context, <String>{}),
                      filled: false,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _DialogBtn(
                      label: 'Uygula (${_selected.length})',
                      onPressed: () => Navigator.pop(context, Set<String>.from(_selected)),
                      filled: true,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── DİYALOG BUTON ───────────────────────────────────────────────────────────

class _DialogBtn extends StatefulWidget {
  const _DialogBtn({required this.label, required this.onPressed, required this.filled});

  final String label;
  final VoidCallback onPressed;
  final bool filled;

  @override
  State<_DialogBtn> createState() => _DialogBtnState();
}

class _DialogBtnState extends State<_DialogBtn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(vertical: 9),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: widget.filled
                ? (_hovered ? const Color(0xFF1D4ED8) : const Color(0xFF2563EB))
                : (_hovered ? const Color(0xFFF5F7FA) : Colors.white),
            borderRadius: BorderRadius.circular(8),
            border: widget.filled ? null : Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: widget.filled ? Colors.white : const Color(0xFF374151),
            ),
          ),
        ),
      ),
    );
  }
}
