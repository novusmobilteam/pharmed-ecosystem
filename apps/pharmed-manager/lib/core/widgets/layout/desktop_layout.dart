import 'package:flutter/material.dart';

import '../../core.dart';

class DesktopLayout extends StatelessWidget {
  const DesktopLayout({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.showAddButton = false,
    this.onAddLabel,
    this.onAddPressed,
    this.actions = const [],
    this.isLoading = false,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final bool showAddButton;
  final VoidCallback? onAddPressed;
  final String? onAddLabel;
  final List<Widget> actions;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppDimensions.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: MedTextStyles.titleLg()),
                  if (subtitle != null) Text(subtitle!, style: MedTextStyles.bodyMd()),
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
      ),
    );
  }
}
