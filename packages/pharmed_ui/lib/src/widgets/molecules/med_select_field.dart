import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

// ─────────────────────────────────────────────────────────────────
// MedSelectField
// [SWREQ-UI-MOL-SEL-001]
// Özel dropdown — native Select yerine, dokunmatik için optimize.
// Her seçenek min 44px, açılır liste max 220px yükseklik.
// Sınıf : Class A (görsel seçim)
// ─────────────────────────────────────────────────────────────────

class MedSelectOption<T> {
  const MedSelectOption({required this.value, required this.label, this.sublabel});
  final T value;
  final String label;
  final String? sublabel;
}

class MedSelectField<T> extends StatefulWidget {
  const MedSelectField({
    super.key,
    required this.options,
    this.value,
    this.onChanged,
    this.label,
    this.placeholder = 'Seçiniz...',
    this.enabled = true,
  });

  final List<MedSelectOption<T>> options;
  final T? value;
  final ValueChanged<T>? onChanged;
  final String? label;
  final String placeholder;
  final bool enabled;

  @override
  State<MedSelectField<T>> createState() => _MedSelectFieldState<T>();
}

class _MedSelectFieldState<T> extends State<MedSelectField<T>> with SingleTickerProviderStateMixin {
  bool _open = false;
  OverlayEntry? _overlay;
  final LayerLink _link = LayerLink();
  late AnimationController _anim;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, -0.05), end: Offset.zero).animate(_fade);
  }

  @override
  void dispose() {
    _closeDropdown();
    _anim.dispose();
    super.dispose();
  }

  MedSelectOption<T>? get _selected => widget.options.where((o) => o.value == widget.value).firstOrNull;

  void _toggleDropdown() {
    if (!widget.enabled) return;
    _open ? _closeDropdown() : _openDropdown();
  }

  void _openDropdown() {
    setState(() => _open = true);
    _overlay = _buildOverlay();
    Overlay.of(context).insert(_overlay!);
    _anim.forward();
  }

  void _closeDropdown() {
    if (_overlay == null) return;
    _anim.reverse().then((_) {
      _overlay?.remove();
      _overlay = null;
    });
    setState(() => _open = false);
  }

  void _select(T value) {
    widget.onChanged?.call(value);
    _closeDropdown();
  }

  OverlayEntry _buildOverlay() {
    final renderBox = context.findRenderObject()! as RenderBox;
    final size = renderBox.size;

    return OverlayEntry(
      builder: (_) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _closeDropdown,
        child: Stack(
          children: [
            Positioned.fill(child: Container(color: Colors.transparent)),
            CompositedTransformFollower(
              link: _link,
              showWhenUnlinked: false,
              offset: Offset(0, size.height + 4),
              child: FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slide,
                  child: Material(
                    color: Colors.transparent,
                    child: _DropdownList<T>(
                      options: widget.options,
                      selected: widget.value,
                      width: size.width,
                      onSelect: _select,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: const TextStyle(
              fontFamily: MedFonts.sans,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: MedColors.text2,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 6),
        ],
        CompositedTransformTarget(
          link: _link,
          child: GestureDetector(
            onTap: _toggleDropdown,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              constraints: const BoxConstraints(minHeight: 48),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: _open ? MedColors.surface : MedColors.surface2,
                border: Border.all(color: _open ? MedColors.blue : MedColors.border, width: 1.5),
                borderRadius: BorderRadius.circular(8),
                boxShadow: _open ? const [BoxShadow(color: Color(0x1F1A6FD8), blurRadius: 0, spreadRadius: 3)] : null,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _selected?.label ?? widget.placeholder,
                      style: TextStyle(
                        fontFamily: MedFonts.sans,
                        fontSize: 14,
                        color: _selected == null ? MedColors.text4 : MedColors.text,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _open ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: MedColors.text3),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DropdownList<T> extends StatelessWidget {
  const _DropdownList({required this.options, required this.selected, required this.width, required this.onSelect});

  final List<MedSelectOption<T>> options;
  final T? selected;
  final double width;
  final ValueChanged<T> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      constraints: const BoxConstraints(maxHeight: 220),
      decoration: BoxDecoration(
        color: MedColors.surface,
        border: Border.all(color: MedColors.border, width: 1.5),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: Color(0x1F1E3259), blurRadius: 32, offset: Offset(0, 12)),
          BoxShadow(color: Color(0x0F1E3259), blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: options.length,
          separatorBuilder: (_, __) => const Divider(height: 1, color: MedColors.border2),
          itemBuilder: (_, i) {
            final opt = options[i];
            final isSelected = opt.value == selected;
            return _DropdownItem<T>(option: opt, isSelected: isSelected, onSelect: onSelect);
          },
        ),
      ),
    );
  }
}

class _DropdownItem<T> extends StatefulWidget {
  const _DropdownItem({required this.option, required this.isSelected, required this.onSelect});
  final MedSelectOption<T> option;
  final bool isSelected;
  final ValueChanged<T> onSelect;

  @override
  State<_DropdownItem<T>> createState() => _DropdownItemState<T>();
}

class _DropdownItemState<T> extends State<_DropdownItem<T>> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onSelect(widget.option.value),
      onTapDown: (_) => setState(() => _hovered = true),
      onTapUp: (_) => setState(() => _hovered = false),
      onTapCancel: () => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: widget.isSelected
            ? MedColors.blueLight
            : _hovered
            ? MedColors.surface2
            : Colors.transparent,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.option.label,
                    style: TextStyle(
                      fontFamily: MedFonts.sans,
                      fontSize: 13,
                      fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: widget.isSelected ? MedColors.blue : MedColors.text,
                    ),
                  ),
                  if (widget.option.sublabel != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      widget.option.sublabel!,
                      style: const TextStyle(fontFamily: MedFonts.sans, fontSize: 11, color: MedColors.text3),
                    ),
                  ],
                ],
              ),
            ),
            if (widget.isSelected) const Icon(Icons.check_rounded, size: 16, color: MedColors.blue),
          ],
        ),
      ),
    );
  }
}
