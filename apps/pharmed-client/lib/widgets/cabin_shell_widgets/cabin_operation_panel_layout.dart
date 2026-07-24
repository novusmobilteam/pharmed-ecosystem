import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

class CabinOperationPanelLayout extends StatelessWidget {
  const CabinOperationPanelLayout({
    super.key,
    this.menuItem,
    this.leftTitle,
    required this.left,
    required this.right,
    this.leftSubtitle,
    this.leftIcon, // IconData — elle verilen
    this.leftWidth = 340,
    this.footer,
  });

  final MenuItem? menuItem;
  final String? leftTitle;
  final String? leftSubtitle;
  final IconData? leftIcon; // String değil IconData
  final double leftWidth;
  final Widget left;
  final Widget right;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              SizedBox(width: leftWidth, child: left),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Padding(padding: const EdgeInsets.only(left: 24.0), child: right),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        if (footer != null) _PanelFooter(child: footer!),
      ],
    );
  }
}

class _PanelFooter extends StatelessWidget {
  const _PanelFooter({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(height: 1, thickness: 1, color: MedColors.border),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: MedSpacing.xl, vertical: MedSpacing.xl),
            child: child,
          ),
        ],
      ),
    );
  }
}
