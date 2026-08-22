import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

class MedMobileLayout extends StatelessWidget {
  const MedMobileLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text(context.l10n.common_viewInPreparationMessage)));
  }
}
