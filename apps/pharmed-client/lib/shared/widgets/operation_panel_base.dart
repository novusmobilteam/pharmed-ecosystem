// lib/features/cabin/presentation/widgets/operation_panel_base.dart
//
// [SWREQ-UI-CAB-004]
// Kabin işlemleri sağ panelinin temel iskeleti.
//
// Tüm işlem modları (assign, fill, count, fault) bu widget'ı
// temel alır. Header sabit, içerik [child] parametresiyle değişir.
//
// KULLANIM:
//   OperationPanelBase(
//     mode: CabinOperationMode.fill,
//     child: FillOperationContent(...),
//   )
//
// BAĞIMLILIK:
//   - pharmed_ui: MedColors, MedFonts, MedTextStyles, MedRadius
//   - pharmed_client: CabinOperationMode
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../core/enums/cabin_operation_mode.dart';

// ─────────────────────────────────────────────────────────────────
// OperationPanelBase
// ─────────────────────────────────────────────────────────────────

/// Sağ panel iskeleti — header sabit, [child] moda göre değişir.
///
/// Header içeriği:
///   - Sol: moda göre renklenen LED nokta + başlık
///   - Sağ: mod kısa adı badge
///
/// [child] padding almaz — iç widget kendi padding'ini yönetir.
class OperationPanelBase extends StatelessWidget {
  const OperationPanelBase({super.key, required this.mode, required this.child});

  final CabinOperationMode mode;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final config = _ModeConfig.of(mode);

    return Container(
      decoration: BoxDecoration(
        color: MedColors.surface,
        border: Border.all(color: MedColors.border, width: 1.5),
        borderRadius: MedRadius.lgAll,
        boxShadow: const [
          BoxShadow(color: Color(0x0F1E3C64), blurRadius: 24, offset: Offset(0, 6)),
          BoxShadow(color: Color(0x081E3C64), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _OperationPanelHeader(config: config),
          Padding(padding: const EdgeInsets.all(16.0), child: child),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────────────

class _OperationPanelHeader extends StatelessWidget {
  const _OperationPanelHeader({required this.config});

  final _ModeConfig config;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: MedColors.surface,
        border: Border(bottom: BorderSide(color: MedColors.border2, width: 1.5)),
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
      ),
      child: Row(
        children: [
          // LED nokta
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: config.accentColor,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: config.accentColor.withOpacity(0.45), blurRadius: 6)],
            ),
          ),
          const SizedBox(width: 8),

          // Başlık
          Expanded(
            child: Text(
              config.title,
              style: TextStyle(
                fontFamily: MedFonts.title,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: MedColors.text2,
                letterSpacing: 0.8,
              ),
            ),
          ),

          // Mod badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: config.badgeBg, borderRadius: BorderRadius.circular(20)),
            child: Text(
              config.badge,
              style: TextStyle(
                fontFamily: MedFonts.mono,
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: config.accentColor,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Mod konfigürasyonu
// ─────────────────────────────────────────────────────────────────

final class _ModeConfig {
  const _ModeConfig({required this.title, required this.badge, required this.accentColor, required this.badgeBg});

  final String title;
  final String badge;
  final Color accentColor;
  final Color badgeBg;

  static _ModeConfig of(CabinOperationMode mode) => switch (mode) {
    CabinOperationMode.assign => _ModeConfig(
      title: 'İLAÇ ATAMA',
      badge: 'ATAMA',
      accentColor: MedColors.blue,
      badgeBg: MedColors.blueLight,
    ),
    CabinOperationMode.fill => _ModeConfig(
      title: 'İLAÇ DOLUM',
      badge: 'DOLUM',
      accentColor: MedColors.green,
      badgeBg: MedColors.greenLight,
    ),
    CabinOperationMode.count => _ModeConfig(
      title: 'İLAÇ SAYIM',
      badge: 'SAYIM',
      accentColor: MedColors.amber,
      badgeBg: MedColors.amberLight,
    ),
    CabinOperationMode.fault => _ModeConfig(
      title: 'ARIZA BİLDİR',
      badge: 'ARIZA',
      accentColor: MedColors.red,
      badgeBg: MedColors.redLight,
    ),
  };
}
