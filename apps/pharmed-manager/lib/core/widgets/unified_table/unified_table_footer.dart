part of 'unified_table_view.dart';

// ─── FOOTER ──────────────────────────────────────────────────────────────────

class _TableFooter extends StatelessWidget {
  const _TableFooter({
    required this.filteredCount,
    required this.totalCount,
    required this.enablePagination,
    this.currentPage,
    this.pageSize,
    this.serverTotalCount,
    this.onPageChanged,
  });

  final int filteredCount;
  final int totalCount;
  final bool enablePagination;
  final int? currentPage;
  final int? pageSize;
  final int? serverTotalCount; // server-side toplam kayıt sayısı
  final ValueChanged<int>? onPageChanged;

  @override
  Widget build(BuildContext context) {
    if (enablePagination) {
      return _PaginationFooter(
        currentPage: currentPage ?? 1,
        pageSize: pageSize ?? 20,
        totalCount: serverTotalCount ?? totalCount,
        onPageChanged: onPageChanged,
      );
    }

    return _CountFooter(
      filteredCount: filteredCount,
      totalCount: totalCount,
    );
  }
}

// ─── SAYIM FOOTER ─────────────────────────────────────────────────────────────

class _CountFooter extends StatelessWidget {
  const _CountFooter({required this.filteredCount, required this.totalCount});

  final int filteredCount, totalCount;

  @override
  Widget build(BuildContext context) {
    final isFiltered = filteredCount != totalCount;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            isFiltered ? '$filteredCount / $totalCount kayıt' : '$totalCount kayıt',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── PAGINATION FOOTER ───────────────────────────────────────────────────────

class _PaginationFooter extends StatelessWidget {
  const _PaginationFooter({
    required this.currentPage,
    required this.pageSize,
    required this.totalCount,
    this.onPageChanged,
  });

  final int currentPage;
  final int pageSize;
  final int totalCount;
  final ValueChanged<int>? onPageChanged;

  int get _totalPages => totalCount == 0 ? 1 : (totalCount / pageSize).ceil();
  int get _startRecord => totalCount == 0 ? 0 : (currentPage - 1) * pageSize + 1;
  int get _endRecord => (currentPage * pageSize).clamp(0, totalCount);
  bool get _canGoPrev => currentPage > 1;
  bool get _canGoNext => currentPage < _totalPages;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            'Toplam $totalCount kayıt',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            '$_startRecord–$_endRecord',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF374151),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 12),
          _PageBtn(
            icon: Icons.chevron_left,
            enabled: _canGoPrev,
            tooltip: 'Önceki sayfa',
            onPressed: () => onPageChanged?.call(currentPage - 1),
          ),
          // Sayfa numaraları
          ..._buildPageNumbers(),
          _PageBtn(
            icon: Icons.chevron_right,
            enabled: _canGoNext,
            tooltip: 'Sonraki sayfa',
            onPressed: () => onPageChanged?.call(currentPage + 1),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageNumbers() {
    // Gösterilecek sayfalar: ilk, son, aktif ±1 ve aralarına "…"
    final pages = <int>{};
    pages.add(1);
    pages.add(_totalPages);
    for (int p = currentPage - 1; p <= currentPage + 1; p++) {
      if (p >= 1 && p <= _totalPages) pages.add(p);
    }
    final sorted = pages.toList()..sort();

    final widgets = <Widget>[];
    for (int i = 0; i < sorted.length; i++) {
      final p = sorted[i];
      // Boşluk varsa "…" ekle
      if (i > 0 && sorted[i - 1] != p - 1) {
        widgets.add(const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text('…', style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
        ));
      }
      widgets.add(_PageNumber(
        page: p,
        isActive: p == currentPage,
        onPressed: () => onPageChanged?.call(p),
      ));
    }
    return widgets;
  }
}

class _PageBtn extends StatefulWidget {
  const _PageBtn({
    required this.icon,
    required this.enabled,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final bool enabled;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  State<_PageBtn> createState() => _PageBtnState();
}

class _PageBtnState extends State<_PageBtn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: widget.enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: Tooltip(
        message: widget.tooltip,
        child: GestureDetector(
          onTap: widget.enabled ? widget.onPressed : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: _hovered && widget.enabled ? const Color(0xFFF5F7FA) : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: _hovered && widget.enabled ? const Color(0xFFE5E7EB) : Colors.transparent,
              ),
            ),
            child: Icon(
              widget.icon,
              size: 16,
              color: widget.enabled ? const Color(0xFF374151) : const Color(0xFFD1D5DB),
            ),
          ),
        ),
      ),
    );
  }
}

class _PageNumber extends StatefulWidget {
  const _PageNumber({
    required this.page,
    required this.isActive,
    required this.onPressed,
  });

  final int page;
  final bool isActive;
  final VoidCallback onPressed;

  @override
  State<_PageNumber> createState() => _PageNumberState();
}

class _PageNumberState extends State<_PageNumber> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: 28,
          height: 28,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: widget.isActive
                ? const Color(0xFF2563EB)
                : _hovered
                    ? const Color(0xFFF5F7FA)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: widget.isActive
                ? null
                : Border.all(
                    color: _hovered ? const Color(0xFFE5E7EB) : Colors.transparent,
                  ),
          ),
          child: Text(
            '${widget.page}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: widget.isActive ? Colors.white : const Color(0xFF374151),
            ),
          ),
        ),
      ),
    );
  }
}
