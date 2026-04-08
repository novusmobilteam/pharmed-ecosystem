import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';
import 'package:pharmed_manager/core/widgets/pharmed_button.dart';

class SidePanelWrapper extends StatelessWidget {
  const SidePanelWrapper({
    super.key,
    required this.isOpen,
    required this.width,
    required this.panel,
    required this.child,
  });

  final bool isOpen;
  final double width;
  final Widget panel;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        AnimatedPositioned(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          right: isOpen ? 0 : (-width - 50),
          top: 0,
          bottom: 0,
          width: width,
          child: panel,
        ),
      ],
    );
  }
}

class SidePanel extends StatelessWidget {
  const SidePanel({
    super.key,
    required this.title,
    this.subtitle,
    this.badge,
    required this.child,
    this.onClose,
    this.onSave,
    this.onDelete,
    this.saveLabel = 'Kaydet',
    this.isLoading = false,
  });

  final String title;
  final String? subtitle;
  final String? badge;
  final Widget child;
  final VoidCallback? onClose;
  final VoidCallback? onSave;
  final VoidCallback? onDelete;
  final String saveLabel;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(left: BorderSide(color: Color(0xFFDDE3EC))),
        boxShadow: [BoxShadow(color: Color(0x140F192D), blurRadius: 24, offset: Offset(-4, 0))],
      ),
      child: Column(
        children: [
          _SidePanelHeader(title: title, subtitle: subtitle, badge: badge, onClose: onClose),
          Expanded(
            child: SingleChildScrollView(padding: const EdgeInsets.all(14), child: child),
          ),
          _SidePanelFooter(
            saveLabel: saveLabel,
            onSave: onSave,
            onClose: onClose,
            onDelete: onDelete,
            isLoading: isLoading,
          ),
        ],
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────

class _SidePanelHeader extends StatelessWidget {
  const _SidePanelHeader({required this.title, this.subtitle, this.badge, this.onClose});

  final String title;
  final String? subtitle;
  final String? badge;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF4F7FF), Color(0xFFEEF2FB)],
        ),
        border: Border(bottom: BorderSide(color: Color(0xFFE8ECF3))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(color: const Color(0xFFE8F1FC), borderRadius: BorderRadius.circular(6)),
                child: const Icon(Icons.edit_outlined, size: 14, color: Color(0xFF1A6FD8)),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A2332),
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 10, color: Color(0xFF7A8FA8)),
                      ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onClose,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFFDDE3EC)),
                  ),
                  child: const Icon(Icons.close_rounded, size: 13, color: Color(0xFF7A8FA8)),
                ),
              ),
            ],
          ),
          if (badge != null) ...[
            const SizedBox(height: 7),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(color: const Color(0xFFE8F1FC), borderRadius: BorderRadius.circular(4)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.info_outline_rounded, size: 10, color: Color(0xFF1A6FD8)),
                  const SizedBox(width: 4),
                  Text(
                    badge!,
                    style: const TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1A6FD8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Footer ────────────────────────────────────────────────────────

class _SidePanelFooter extends StatelessWidget {
  const _SidePanelFooter({required this.saveLabel, this.onSave, this.onClose, this.onDelete, this.isLoading = false});

  final String saveLabel;
  final VoidCallback? onSave;
  final VoidCallback? onClose;
  final VoidCallback? onDelete;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 9, 14, 9),
      decoration: BoxDecoration(
        color: MedColors.surface2,
        border: Border(top: BorderSide(color: MedColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          PharmedButton(
            label: 'İptal',
            onPressed: onClose,
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF3D4F66),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 150,
            child: MedButton(
              label: saveLabel,
              size: MedButtonSize.sm,
              onPressed: isLoading ? null : onSave,
              isLoading: isLoading,
            ),
          ),
        ],
      ),
    );
  }
}
