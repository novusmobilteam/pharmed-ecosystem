part of 'unified_table_view.dart';

// ─── SOL KATEGORİ PANELİ ─────────────────────────────────────────────────────

class _SidePanel extends StatelessWidget {
  const _SidePanel({
    required this.categories,
    required this.selectedId,
    required this.onSelect,
    this.title,
  });

  final List<TableSideCategory> categories;
  final String? selectedId;
  final ValueChanged<String> onSelect;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 185,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            child: Text(
              title ?? 'Kategoriler',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF374151),
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEEF0F4)),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              itemCount: categories.length,
              itemBuilder: (_, i) {
                final cat = categories[i];
                return _SidePanelItem(
                  label: cat.label,
                  count: cat.count,
                  active: cat.id == selectedId,
                  onTap: () => onSelect(cat.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SidePanelItem extends StatefulWidget {
  const _SidePanelItem({
    required this.label,
    this.count,
    required this.active,
    required this.onTap,
  });

  final String label;
  final int? count;
  final bool active;
  final VoidCallback onTap;

  @override
  State<_SidePanelItem> createState() => _SidePanelItemState();
}

class _SidePanelItemState extends State<_SidePanelItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 130),
          margin: const EdgeInsets.only(bottom: 2),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: widget.active
                ? const Color(0xFFEFF6FF)
                : _hovered
                    ? const Color(0xFFF5F7FA)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              if (widget.active)
                Container(
                  width: 3,
                  height: 14,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                )
              else
                const SizedBox(width: 11),
              Expanded(
                child: Text(
                  widget.label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: widget.active ? FontWeight.w600 : FontWeight.w400,
                    color: widget.active ? const Color(0xFF2563EB) : const Color(0xFF374151),
                  ),
                ),
              ),
              if (widget.count != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: widget.active ? const Color(0xFF2563EB).withValues(alpha: 0.1) : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${widget.count}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: widget.active ? const Color(0xFF2563EB) : const Color(0xFF9CA3AF),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
