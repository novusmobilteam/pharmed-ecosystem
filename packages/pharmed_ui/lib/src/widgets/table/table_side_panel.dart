part of 'med_table_view.dart';

class _SidePanel extends StatefulWidget {
  const _SidePanel({required this.categories, required this.selectedId, required this.onSelect, this.title});

  final List<TableSideCategory> categories;
  final String? selectedId;
  final ValueChanged<String> onSelect;
  final String? title;

  @override
  State<_SidePanel> createState() => _SidePanelState();
}

class _SidePanelState extends State<_SidePanel> {
  late Set<String> _expandedIds;

  @override
  void initState() {
    super.initState();
    // Varsayılan: alt kategorisi olan tüm gruplar açık başlar (görseldeki gibi).
    _expandedIds = widget.categories.where((c) => c.hasChildren).map((c) => c.id).toSet();
  }

  @override
  void didUpdateWidget(_SidePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Seçim dışarıdan değiştiyse (örn. başka bir ekrandan gelindi), seçili
    // çocuğu barındıran grup her zaman açık kalsın.
    if (widget.selectedId != null && widget.selectedId != oldWidget.selectedId) {
      final parentId = _parentIdOf(widget.selectedId!);
      if (parentId != null) _expandedIds.add(parentId);
    }
  }

  String? _parentIdOf(String childId) {
    for (final cat in widget.categories) {
      if (cat.children?.any((c) => c.id == childId) ?? false) return cat.id;
    }
    return null;
  }

  void _toggleExpand(String id) =>
      setState(() => _expandedIds.contains(id) ? _expandedIds.remove(id) : _expandedIds.add(id));

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
              widget.title ?? context.l10n.table_categoriesDefaultTitle,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF374151)),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEEF0F4)),
          Expanded(
            child: ListView(padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8), children: _buildEntries()),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildEntries() {
    final widgets = <Widget>[];
    for (final cat in widget.categories) {
      if (!cat.hasChildren) {
        widgets.add(
          _SidePanelItem(
            label: cat.label,
            subtitle: cat.subtitle,
            statusColor: cat.statusColor,
            count: cat.count,
            active: cat.id == widget.selectedId,
            onTap: () => widget.onSelect(cat.id),
          ),
        );
        continue;
      }

      final expanded = _expandedIds.contains(cat.id);
      widgets.add(
        _SidePanelGroupHeader(
          label: cat.label,
          count: cat.count,
          expanded: expanded,
          onTap: () => _toggleExpand(cat.id),
        ),
      );
      if (expanded) {
        for (final child in cat.children!) {
          widgets.add(
            _SidePanelItem(
              label: child.label,
              subtitle: child.subtitle,
              statusColor: child.statusColor,
              count: child.count,
              active: child.id == widget.selectedId,
              indented: true,
              onTap: () => widget.onSelect(child.id),
            ),
          );
        }
      }
    }
    return widgets;
  }
}

class _SidePanelGroupHeader extends StatelessWidget {
  const _SidePanelGroupHeader({required this.label, required this.expanded, required this.onTap, this.count});

  final String label;
  final bool expanded;
  final int? count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        child: Row(
          children: [
            AnimatedRotation(
              turns: expanded ? 0.25 : 0.0,
              duration: const Duration(milliseconds: 130),
              child: const Icon(Icons.chevron_right, size: 14, color: Color(0xFF9CA3AF)),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF9CA3AF),
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidePanelItem extends StatefulWidget {
  const _SidePanelItem({
    required this.label,
    required this.active,
    required this.onTap,
    this.subtitle,
    this.statusColor,
    this.count,
    this.indented = false,
  });

  final String label;
  final String? subtitle;
  final Color? statusColor;
  final int? count;
  final bool active;
  final bool indented;
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
          margin: EdgeInsets.only(bottom: 2, left: widget.indented ? 12 : 0),
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
                  height: widget.subtitle != null ? 24 : 14,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(2)),
                )
              else
                const SizedBox(width: 11),
              if (widget.statusColor != null) ...[
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(color: widget.statusColor, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.label,
                      overflow: TextOverflow.ellipsis,
                      style: MedTextStyles.bodyMd().copyWith(
                        fontWeight: widget.active ? FontWeight.w600 : FontWeight.w400,
                        color: widget.active ? MedColors.blue : MedColors.text,
                      ),
                    ),
                    if (widget.subtitle != null)
                      Text(
                        widget.subtitle!,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                      ),
                  ],
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
