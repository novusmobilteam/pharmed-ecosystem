import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../widgets.dart';

class CabinOperationDialog extends StatelessWidget {
  const CabinOperationDialog({
    super.key,
    required this.type,
    required this.statusInput,
    required this.stats,
    required this.banners,
    required this.footerContent,
    required this.child,
  });

  final CabinInventoryType type;
  final OperationStatusInput statusInput;
  final List<StatCellData> stats;
  final List<Widget> banners;
  final FooterContent footerContent;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: MedSpacing.insetXl,
      shape: RoundedRectangleBorder(borderRadius: MedRadius.xl2All),
      backgroundColor: MedColors.surface,
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Header(type, statusInput: statusInput),
              OperationStatsRow(cells: stats),
              SizedBox(height: 14.0),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: MedSpacing.insetXl.left),
                child: Column(children: banners),
              ),
              Flexible(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: MedSpacing.insetXl.left),
                  child: child,
                ),
              ),

              OperationDialogFooter(content: footerContent),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.type, {required this.statusInput});

  final CabinInventoryType type;
  final OperationStatusInput statusInput;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: MedSpacing.insetXl,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: MedColors.border, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(type.title, style: MedTextStyles.titleSm(color: MedColors.text)),
          ),
          OperationStatusBadge(input: statusInput),
        ],
      ),
    );
  }
}
