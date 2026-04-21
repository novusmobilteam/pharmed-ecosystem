// [SWREQ-UI-CAB-003] [SWREQ-UI-CAB-007]
// DrawerPanel bileşenlerinde ortak kullanılan widget'lar ve renk sistemi.
// Sınıf: Class B

part of 'drawer_panel.dart';

// ─────────────────────────────────────────────────────────────────
// CabinCellStatus — ortak göz durumu enum'u
// ─────────────────────────────────────────────────────────────────

enum CabinCellStatus { empty, assigned, low, critical, fault, maintenance }

// ─────────────────────────────────────────────────────────────────
// CabinCellColors — durum bazlı renk seti
// ─────────────────────────────────────────────────────────────────

final class CabinCellColors {
  const CabinCellColors({required this.bgLight, required this.bgDark, required this.border});

  final Color bgLight;
  final Color bgDark;
  final Color border;

  static CabinCellColors of(CabinCellStatus status) => switch (status) {
    CabinCellStatus.empty => const CabinCellColors(
      bgLight: Color(0xFFE8EDF5),
      bgDark: Color(0xFFD8E2EE),
      border: Color(0xFFA8B8CC),
    ),
    CabinCellStatus.assigned => const CabinCellColors(
      bgLight: Color(0xFFDDEEFF),
      bgDark: Color(0xFFC8D8EE),
      border: Color(0xFF7AB0D8),
    ),
    CabinCellStatus.low => const CabinCellColors(
      bgLight: Color(0xFFFFFBEB),
      bgDark: Color(0xFFFEF3C7),
      border: Color(0xFFF5C97A),
    ),
    CabinCellStatus.critical => const CabinCellColors(
      bgLight: Color(0xFFFEF2F2),
      bgDark: Color(0xFFFDE8E8),
      border: Color(0xFFF9A8A8),
    ),
    CabinCellStatus.fault => const CabinCellColors(
      bgLight: Color(0xFFFFF0F0),
      bgDark: Color(0xFFFEE2E2),
      border: Color(0xFFDC2626),
    ),
    CabinCellStatus.maintenance => const CabinCellColors(
      bgLight: Color(0xFFFFFBEB),
      bgDark: Color(0xFFFEF3C7),
      border: Color(0xFFF59E0B),
    ),
  };
}

// ─────────────────────────────────────────────────────────────────
// CabinModeBanner — mod bilgi bandı
// ─────────────────────────────────────────────────────────────────

class CabinModeBanner extends StatelessWidget {
  const CabinModeBanner({super.key, required this.mode, this.isPatientAssignment = false});

  final CabinOperationMode mode;
  final bool isPatientAssignment;

  @override
  Widget build(BuildContext context) {
    final (bg, border, text, message) = _config(context, mode);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border, width: 1.5),
        borderRadius: MedRadius.smAll,
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 14, color: text),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontFamily: MedFonts.sans, fontSize: 11, fontWeight: FontWeight.w500, color: text),
            ),
          ),
        ],
      ),
    );
  }

  (Color, Color, Color, String) _config(BuildContext context, CabinOperationMode mode) => switch (mode) {
    CabinOperationMode.assign =>
      isPatientAssignment
          ? (
              const Color(0xFFE8F1FC),
              const Color(0xFFC4D9F5),
              const Color(0xFF1256AA),
              context.l10n.cabin_bannerPatientAssign,
            )
          : (
              const Color(0xFFE8F1FC),
              const Color(0xFFC4D9F5),
              const Color(0xFF1256AA),
              context.l10n.cabin_bannerDrugAssign,
            ),
    CabinOperationMode.fill => (
      const Color(0xFFE6F7F2),
      const Color(0xFF9ED9C4),
      const Color(0xFF086E4A),
      context.l10n.cabin_bannerDrugFill,
    ),
    CabinOperationMode.count => (
      const Color(0xFFFEF3E2),
      const Color(0xFFF5C97A),
      const Color(0xFF92520A),
      context.l10n.cabin_bannerDrugCount,
    ),
    CabinOperationMode.fault => (
      const Color(0xFFFEF2F2),
      const Color(0xFFF9A8A8),
      const Color(0xFF9B1C1C),
      context.l10n.cabin_bannerFault,
    ),
  };
}

// ─────────────────────────────────────────────────────────────────
// CabinDrawerEmptyState — çekmece seçilmediğinde gösterilen boş durum
// ─────────────────────────────────────────────────────────────────

class CabinDrawerEmptyState extends StatelessWidget {
  const CabinDrawerEmptyState({super.key, required this.subtitle});

  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MedColors.surface,
        border: Border.all(color: MedColors.border, width: 1.5),
        borderRadius: MedRadius.lgAll,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.touch_app_outlined, size: 48, color: MedColors.text4),
            const SizedBox(height: 16),
            Text(context.l10n.cabin_touchDrawerHint, style: MedTextStyles.bodyMd(color: MedColors.text3)),
            const SizedBox(height: 6),
            Text(subtitle, style: MedTextStyles.monoMd(color: MedColors.text4)),
          ],
        ),
      ),
    );
  }
}
