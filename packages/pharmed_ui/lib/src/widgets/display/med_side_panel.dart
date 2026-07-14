import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

/// Sol tarafta başlık + seçilebilir öğe listesi gösteren genel amaçlı yan panel.
///
/// Örnek:
/// ```dart
/// MedSidePanel<Station>(
///   title: 'İstasyonlar',
///   items: notifier.stations,
///   selected: notifier.selectedStation,
///   labelBuilder: (s) => s.name ?? '-',
///   onSelected: notifier.selectStation,
/// )
/// ```
class MedSidePanel<T> extends StatelessWidget {
  const MedSidePanel({
    super.key,
    required this.items,
    required this.labelBuilder,
    required this.onSelected,
    this.title,
    this.selected,
    this.countBuilder,
    this.width = 185,
    this.emptyPlaceholder,
  });

  final String? title;
  final List<T> items;
  final T? selected;
  final String Function(T item) labelBuilder;
  final int? Function(T item)? countBuilder;
  final ValueChanged<T> onSelected;
  final double width;
  final Widget? emptyPlaceholder;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        children: [
          if (title != null) ...[
            Container(
              height: 52,
              padding: MedSpacing.insetXl.copyWith(top: 0, bottom: 0),
              alignment: Alignment.centerLeft,
              child: Text(title!, style: MedTextStyles.titleSm()),
            ),
            const Divider(height: 1, color: MedColors.border),
          ],
          Expanded(
            child: items.isEmpty && emptyPlaceholder != null
                ? Center(child: emptyPlaceholder)
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: MedSpacing.md, horizontal: MedSpacing.md),
                    itemCount: items.length,
                    itemBuilder: (_, i) {
                      final item = items[i];
                      return MedSidePanelItem(
                        label: labelBuilder(item),
                        count: countBuilder?.call(item),
                        active: item == selected,
                        onTap: () => onSelected(item),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// [MedSidePanel] içindeki tek bir seçilebilir satır.
class MedSidePanelItem extends StatefulWidget {
  const MedSidePanelItem({super.key, required this.label, required this.active, required this.onTap, this.count});

  final String label;
  final bool active;
  final int? count;
  final VoidCallback onTap;

  @override
  State<MedSidePanelItem> createState() => _MedSidePanelItemState();
}

class _MedSidePanelItemState extends State<MedSidePanelItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.active;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 130),
          margin: const EdgeInsets.only(bottom: 2),
          padding: const EdgeInsets.symmetric(horizontal: MedSpacing.lg, vertical: MedSpacing.md),
          decoration: BoxDecoration(
            color: active
                ? MedColors.blueLight
                : _hovered
                ? MedColors.surface2
                : Colors.transparent,
            borderRadius: MedRadius.mdAll,
          ),
          child: Row(
            children: [
              if (active)
                Container(
                  width: 3,
                  height: 14,
                  margin: const EdgeInsets.only(right: MedSpacing.md),
                  decoration: BoxDecoration(color: MedColors.blue, borderRadius: MedRadius.smAll),
                )
              else
                const SizedBox(width: 11),
              Expanded(
                child: Text(
                  widget.label,
                  overflow: TextOverflow.ellipsis,
                  style: MedTextStyles.bodyMd().copyWith(
                    fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                    color: active ? MedColors.blue : MedColors.text,
                  ),
                ),
              ),
              if (widget.count != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: MedSpacing.sm, vertical: 1),
                  decoration: BoxDecoration(
                    color: active ? MedColors.blue.withValues(alpha: 0.1) : MedColors.surface3,
                    borderRadius: MedRadius.midAll,
                  ),
                  child: Text(
                    '${widget.count}',
                    style: MedTextStyles.bodySm().copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: active ? MedColors.blue : MedColors.text3,
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
