import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../core.dart';

class CustomDropdown<T> extends StatefulWidget {
  final String hintText;
  final List<T> items;
  final T selectedItem;
  final Function(dynamic item) onChanged;
  final String? Function(dynamic) labelBuilder;

  const CustomDropdown({
    super.key,
    required this.hintText,
    required this.items,
    required this.selectedItem,
    required this.onChanged,
    required this.labelBuilder,
  });

  @override
  State<CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isDropdownOpen = false;

  void _toggleDropdown() {
    if (_isDropdownOpen) {
      _overlayEntry?.remove();
      _isDropdownOpen = false;
    } else {
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
      _isDropdownOpen = true;
    }
  }

  OverlayEntry _createOverlayEntry<T>() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Size size = renderBox.size;
    Offset offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + size.height + 4,
        width: size.width,
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(8.0),
          child: ListView(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            children: widget.items.map((item) {
              return ListTile(
                title: Text(widget.labelBuilder(item) ?? "-"),
                onTap: () {
                  widget.onChanged(item);
                  _toggleDropdown();
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Column(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.hintText, style: context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
          GestureDetector(
            onTap: _toggleDropdown,
            child: Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.0), border: Border.all()),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.labelBuilder(widget.selectedItem).toString(),
                    style: context.theme.inputDecorationTheme.labelStyle,
                  ),
                  Spacer(),
                  Icon(PhosphorIcons.caretDown()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
