import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

class ScreenTitle extends StatelessWidget {
  const ScreenTitle({super.key, required this.menu});

  final MenuItem menu;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 4.0,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 6,
          height: 45,
          decoration: BoxDecoration(color: MedColors.blue, borderRadius: MedRadius.mdAll),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(menu.name.toString(), style: MedTextStyles.titleLg()),
              Text(menu.description ?? '', style: MedTextStyles.bodyMd()),
            ],
          ),
        ),
      ],
    );
  }
}
