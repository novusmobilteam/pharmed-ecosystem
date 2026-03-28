import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core.dart';
import '../pharmed_icon_button.dart';

class DesktopLayout extends StatelessWidget {
  const DesktopLayout({
    super.key,
    required this.title,
    required this.child,
    this.showAddButton = false,
    this.onAddLabel,
    this.onAddPressed,
    this.actions = const [],
    this.isLoading = false,
  });

  final String title;
  final Widget child;
  final bool showAddButton;
  final VoidCallback? onAddPressed;
  final String? onAddLabel;
  final List<Widget> actions;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F7),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Topbar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: const Color(0xFFEEF0F4),
                  width: 1.0,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Geri butonu
                if (context.canPop()) ...[
                  _BackButton(onPressed: () => context.pop()),
                  const SizedBox(width: 8),
                  Container(
                    width: 1,
                    height: 20,
                    color: const Color(0xFFEEF0F4),
                    margin: const EdgeInsets.only(right: 12),
                  ),
                ],

                // Başlık
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111827),
                      letterSpacing: -0.3,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Aksiyonlar
                Row(
                  spacing: 8,
                  children: [
                    ...actions,
                    if (showAddButton)
                      PharmedIconButton(
                        onPressed: onAddPressed,
                        label: onAddLabel ?? 'Yeni',
                        icon: PhosphorIcons.plus(),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // ── İçerik
          Expanded(
            child: Stack(
              children: [
                Padding(
                  padding: AppDimensions.pagePadding,
                  child: child,
                ),
                if (isLoading)
                  Container(
                    color: Colors.white.withValues(alpha: 0.6),
                    child: const Center(
                      child: CircularProgressIndicator.adaptive(),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── BACK BUTTON ─────────────────────────────────────────────────────────────

class _BackButton extends StatefulWidget {
  const _BackButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  State<_BackButton> createState() => _BackButtonState();
}

class _BackButtonState extends State<_BackButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 130),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _hovered ? const Color(0xFFF5F7FA) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _hovered ? const Color(0xFFE5E7EB) : Colors.transparent,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                PhosphorIcons.caretLeft(),
                size: 15,
                color: const Color(0xFF6B7280),
              ),
              const SizedBox(width: 4),
              Text(
                'Geri',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _hovered ? const Color(0xFF374151) : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
