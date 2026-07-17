// lib/widgets/two_column_layout.dart
//
// [SWREQ-UI-LAYOUT-001]
// Sınıf : Class A
//
// Kabin işlemi gerektirmeyen ekranlar için genel amaçlı iki sütun layout.
//
// Sol  : sabit genişlik (default 380px), beyaz bg, header + content
// Sağ  : Expanded, beyaz header + bg'siz content
//
// Her iki header da MenuItem'dan veya ayrı parametrelerden beslenir.

import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

class TwoColumnLayout extends StatelessWidget {
  const TwoColumnLayout({
    super.key,
    required this.menuItem,
    required this.leftTitle,
    required this.left,
    required this.right,
    this.leftSubtitle,
    this.leftIcon, // IconData — elle verilen
    this.leftWidth = 380,
    this.footer,
  });

  final MenuItem menuItem;
  final String leftTitle;
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
              SizedBox(
                width: leftWidth,
                child: Container(
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _PanelHeader.withIcon(icon: leftIcon, title: leftTitle, subtitle: leftSubtitle),
                      const Divider(height: 1, thickness: 1, color: MedColors.border),
                      Expanded(child: left),
                    ],
                  ),
                ),
              ),

              const VerticalDivider(width: 1, thickness: 1, color: MedColors.border),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      color: Colors.white,
                      child: Column(
                        children: [
                          _PanelHeader.withUnicode(
                            unicode: menuItem.unicode,
                            title: menuItem.name ?? '',
                            subtitle: menuItem.description,
                          ),
                          const Divider(height: 1, thickness: 1, color: MedColors.border),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(padding: const EdgeInsets.all(24.0), child: right),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── Footer — tam genişlik ───────────────────────────────────
        if (footer != null) _PanelFooter(child: footer!),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _PanelHeader extends StatelessWidget {
  const _PanelHeader._({required this.icon, required this.title, this.subtitle});

  /// Sol panel — IconData doğrudan verilir.
  factory _PanelHeader.withIcon({required IconData? icon, required String title, String? subtitle}) =>
      _PanelHeader._(icon: icon, title: title, subtitle: subtitle);

  /// Sağ panel — unicode string'den IconData üretilir.
  factory _PanelHeader.withUnicode({required String? unicode, required String title, String? subtitle}) =>
      _PanelHeader._(icon: unicode != null ? iconDataFromUnicode(unicode) : null, title: title, subtitle: subtitle);

  final IconData? icon;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: MedSpacing.xl,
        right: MedSpacing.xl,
        top: MedSpacing.xl,
        bottom: MedSpacing.md,
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            MedRectangleIconButton(color: MedColors.blueLight, iconColor: MedColors.blue, iconData: icon!),
            const SizedBox(width: 10),
          ],
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              Text(title, style: MedTextStyles.titleMd()),
              if (subtitle != null) Text(subtitle!, style: MedTextStyles.monoMd(color: MedColors.text3)),
            ],
          ),
        ],
      ),
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
