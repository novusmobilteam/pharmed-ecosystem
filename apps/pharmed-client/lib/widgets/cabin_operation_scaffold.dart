// lib/shared/widgets/cabin_widgets/cabin_operation_scaffold.dart
//
// Kabin işlem ekranlarının (atama, dolum, sayım, arıza) ortak layout iskeleti.
// Sol / Orta / Sağ panel yapısını ve boyutlarını tek noktada yönetir.
//
// KULLANIM:
//   CabinOperationScaffold(
//     leftPanel: MasterCabinOverviewPanel(...),
//     centerPanel: DrawerDetailPanel(...),
//     rightPanel: OperationPanelBase(...),
//   )
//
// Sınıf: Class B

import 'package:flutter/material.dart';

class CabinOperationScaffold extends StatelessWidget {
  const CabinOperationScaffold({
    super.key,
    required this.leftPanel,
    required this.centerPanel,
    required this.rightPanel,
    this.leftPanelWidth = _defaultLeftWidth,
    this.rightPanelWidth = _defaultRightWidth,
    this.spacing = _defaultSpacing,
    this.padding = const EdgeInsets.all(24),
  });

  final Widget leftPanel;
  final Widget centerPanel;
  final Widget rightPanel;

  final double leftPanelWidth;
  final double rightPanelWidth;
  final double spacing;
  final EdgeInsets padding;

  static const double _defaultLeftWidth = 260;
  static const double _defaultRightWidth = 320;
  static const double _defaultSpacing = 16;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sol panel — sabit genişlik
          SizedBox(width: leftPanelWidth, child: leftPanel),
          SizedBox(width: spacing),

          // Orta panel — kalan alanı kaplar
          Expanded(child: centerPanel),
          SizedBox(width: spacing),

          // Sağ panel — sabit genişlik
          SizedBox(width: rightPanelWidth, child: rightPanel),
        ],
      ),
    );
  }
}
