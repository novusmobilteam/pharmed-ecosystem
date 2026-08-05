import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

class CabinOperationSelectionLayout extends StatelessWidget {
  const CabinOperationSelectionLayout({
    super.key,
    required this.left,
    required this.right,
    this.leftWidth = 320,
    this.footer,
    this.isLoading = false,
  });

  final double leftWidth;
  final Widget left;
  final Widget right;
  final Widget? footer;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: MedLoadingIndicator());
    }
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
