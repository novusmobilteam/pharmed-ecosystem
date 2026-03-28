import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../core.dart';

class AccordionView extends StatefulWidget {
  const AccordionView({
    super.key,
    required this.isSelected,
    this.isChildSelected = false,
    required this.onTap,
    required this.title,
    this.subtitle,
    required this.child,
    this.showLeading = true,
  });

  final String title;
  final String? subtitle;

  /// Akordiyonun seçili olup olmaması durumu
  final bool isSelected;

  /// Akordiyonda gösterilen herhangi bir child'ın seçili olup olmaması durumu
  final bool isChildSelected;
  final VoidCallback onTap;

  final Widget child;
  final bool showLeading;

  @override
  State<AccordionView> createState() => _AccordionViewState();
}

class _AccordionViewState extends State<AccordionView> {
  final Duration duration = Duration(milliseconds: 400);
  final Curve curve = Curves.easeInOut;

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.isSelected ? context.colorScheme.primary : context.colorScheme.onPrimary.withAlpha(120);
    final borderWidth = widget.isSelected ? 2.0 : 1.0;

    return InkWell(
      onTap: widget.onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: AnimatedContainer(
          curve: curve,
          duration: duration,
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: borderWidth),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _headerView(widget.title, widget.subtitle, widget.isSelected, widget.isChildSelected),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                alignment: Alignment.topCenter,
                child: widget.isSelected ? widget.child : SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerView(String title, String? subtitle, bool isSelected, bool isChildSelected) {
    final backgroundColor = isSelected || isChildSelected ? context.colorScheme.primaryContainer : Colors.transparent;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 0),
      padding: const EdgeInsets.symmetric(
        horizontal: 12.0,
        vertical: 8.0,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.vertical(
          top: const Radius.circular(8.0),
          bottom: isSelected ? Radius.zero : const Radius.circular(8.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: ListTile(
              title: Text(title),
              subtitle: subtitle != null ? Text(subtitle) : null,
            ),
          ),
          Spacer(),
          Icon(
            isSelected ? PhosphorIcons.caretUp() : PhosphorIcons.caretDown(),
          ),
        ],
      ),
    );
  }
}
