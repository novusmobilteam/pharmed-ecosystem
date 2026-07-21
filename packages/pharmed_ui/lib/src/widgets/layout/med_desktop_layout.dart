import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

class MedDesktopLayout extends StatelessWidget {
  const MedDesktopLayout({
    super.key,
    required this.menu,
    required this.child,
    this.showAddButton = false,
    this.onAddLabel,
    this.onAddPressed,
    this.actions = const [],
    this.isLoading = false,
  });

  final MenuItem menu;
  final Widget child;
  final bool showAddButton;
  final VoidCallback? onAddPressed;
  final String? onAddLabel;
  final List<Widget> actions;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(menu.localizedName(locale), style: MedTextStyles.titleLg()),
                Text(menu.localizedDescription(locale), style: MedTextStyles.bodyMd()),
              ],
            ),
            Row(spacing: 8, children: [...actions]),
          ],
        ),
        SizedBox(height: 12.0),
        Expanded(
          child: Stack(
            children: [
              child,
              if (isLoading)
                Container(
                  color: Colors.white.withValues(alpha: 0.6),
                  child: const Center(child: CircularProgressIndicator.adaptive()),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
