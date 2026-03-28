part of 'unified_table_view.dart';

class _TableToolbar<T extends TableData> extends StatelessWidget {
  const _TableToolbar({
    required this.searchController,
    required this.enableSearch,
    required this.onSearchChanged,
    required this.enableExcel,
    required this.enablePDF,
    required this.onExcelPressed,
    required this.onPdfPressed,
    required this.selectedCount,
    required this.selectionMode,
    required this.onClearSelection,
    this.enableDateFilter = false,
    this.currentDateRange,
    this.onDateFilterPressed,
    this.selectionActions,
  });

  final TextEditingController searchController;
  final bool enableSearch;
  final ValueChanged<String> onSearchChanged;
  final bool enableExcel;
  final bool enablePDF;
  final VoidCallback onExcelPressed;
  final VoidCallback onPdfPressed;
  final int selectedCount;
  final TableSelectionMode selectionMode;
  final VoidCallback onClearSelection;
  final bool enableDateFilter;
  final DateTimeRange? currentDateRange;
  final VoidCallback? onDateFilterPressed;
  final List<Widget>? selectionActions;

  bool get _hasExport => enableExcel || enablePDF;
  bool get _hasSelection => selectionMode != TableSelectionMode.none && selectedCount > 0;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      color: _hasSelection ? const Color(0xFFEFF6FF) : Colors.white,
      child: Row(
        children: [
          // ── Sol: seçim bilgisi VEYA arama + tarih filtresi
          if (_hasSelection) ...[
            _SelectionInfo(
              count: selectedCount,
              onClear: onClearSelection,
            ),
            const SizedBox(width: 12),
            if (selectionActions != null)
              ...selectionActions!.map((w) => Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: w,
                  )),
          ] else ...[
            if (enableSearch)
              SizedBox(
                width: 240,
                child: _SearchField(
                  controller: searchController,
                  onChanged: onSearchChanged,
                ),
              ),
          ],

          const Spacer(),

          // ── Sağ: tarih filtresi + export (her zaman)
          if (!_hasSelection && enableDateFilter) ...[
            _DateFilterBtn(
              active: currentDateRange != null,
              onPressed: onDateFilterPressed ?? () {},
            ),
            const SizedBox(width: 6),
          ],
          if (_hasExport) ...[
            if (enableExcel || enablePDF)
              Container(
                height: 20,
                width: 1,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                color: const Color(0xFFE5E7EB),
              ),
            if (enableExcel)
              _ExportBtn(
                icon: Icons.table_chart_outlined,
                label: _hasSelection ? 'Seçilenleri Aktar' : 'Excel',
                color: const Color(0xFF166534),
                bgColor: const Color(0xFFF0FDF4),
                borderColor: const Color(0xFFBBF7D0),
                onPressed: onExcelPressed,
              ),
            if (enableExcel && enablePDF) const SizedBox(width: 6),
            if (enablePDF)
              _ExportBtn(
                icon: Icons.picture_as_pdf_outlined,
                label: _hasSelection ? 'PDF' : 'PDF',
                color: const Color(0xFF991B1B),
                bgColor: const Color(0xFFFFF1F2),
                borderColor: const Color(0xFFFFCDD2),
                onPressed: onPdfPressed,
              ),
          ],
        ],
      ),
    );
  }
}

// ─── SEÇİM BİLGİSİ ───────────────────────────────────────────────────────────

class _SelectionInfo extends StatelessWidget {
  const _SelectionInfo({required this.count, required this.onClear});

  final int count;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF2563EB),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '$count seçili',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: onClear,
          child: const Text(
            'Temizle',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF2563EB),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── ARAMA ALANI ─────────────────────────────────────────────────────────────

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 13, color: Color(0xFF111827)),
        decoration: InputDecoration(
          hintText: 'Ara...',
          hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
          prefixIcon: const Icon(Icons.search, size: 17, color: Color(0xFF9CA3AF)),
          suffixIcon: controller.text.isNotEmpty
              ? GestureDetector(
                  onTap: () => onChanged(''),
                  child: const Icon(Icons.close, size: 14, color: Color(0xFF9CA3AF)),
                )
              : null,
          filled: true,
          fillColor: const Color(0xFFF8F9FB),
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
          ),
        ),
      ),
    );
  }
}

// ─── EXPORT BUTTON ───────────────────────────────────────────────────────────

class _ExportBtn extends StatefulWidget {
  const _ExportBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
    required this.borderColor,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final Color color, bgColor, borderColor;
  final VoidCallback onPressed;

  @override
  State<_ExportBtn> createState() => _ExportBtnState();
}

class _ExportBtnState extends State<_ExportBtn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 130),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _hovered ? widget.bgColor : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _hovered ? widget.color.withValues(alpha: 0.3) : widget.borderColor,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 14, color: widget.color),
              const SizedBox(width: 5),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: widget.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── DATE FILTER BUTTON ───────────────────────────────────────────────────────

class _DateFilterBtn extends StatefulWidget {
  const _DateFilterBtn({required this.active, required this.onPressed});

  final bool active;
  final VoidCallback onPressed;

  @override
  State<_DateFilterBtn> createState() => _DateFilterBtnState();
}

class _DateFilterBtnState extends State<_DateFilterBtn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.active ? const Color(0xFF2563EB) : const Color(0xFF6B7280);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Tooltip(
        message: 'Tarih Filtresi',
        child: GestureDetector(
          onTap: widget.onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 130),
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            decoration: BoxDecoration(
              color: widget.active
                  ? const Color(0xFF2563EB).withValues(alpha: 0.08)
                  : _hovered
                      ? const Color(0xFFF5F7FA)
                      : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: widget.active ? const Color(0xFF2563EB).withValues(alpha: 0.3) : const Color(0xFFE5E7EB),
              ),
            ),
            child: Icon(
              widget.active ? Icons.event_available : Icons.calendar_today_outlined,
              size: 15,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}
