import 'package:flutter/material.dart';
import '../atoms/atoms.dart';

// ─────────────────────────────────────────────────────────────────
// TreatmentRow
// [SWREQ-UI-MOL-004] [HAZ-003]
// Kullanım: Yaklaşan tedaviler listesindeki tek zaman çizelgesi satırı
// Atomlar : MedAvatar + MedLabel + _PriorityBadge + _StatusBadge
//           + timeline çizgisi (iç widget)
//
// NOT: isUrgent dışarıdan parametre değil, içeride türetilir:
//   _isUrgent = priority == urgent && status == pending
//
// Sınıf: Class B — ilaç adı, doz, öncelik yanlış gösterilirse
//         yanlış tedavi uygulanabilir
// ─────────────────────────────────────────────────────────────────

enum TreatmentPriority { urgent, normal, routine }

enum TreatmentStatus { pending, done, returned }

class TreatmentRow extends StatelessWidget {
  const TreatmentRow({
    super.key,
    required this.time,
    required this.patientName,
    required this.patientId,
    required this.avatar,
    required this.medicineName,
    required this.dose,
    required this.drawerCode,
    required this.priority,
    required this.status,
    this.isLast = false,
    this.onDetail,
  });

  final String time;
  final String patientName;

  /// Örn: "#P-0033 · Oda 301"
  final String patientId;

  final MedAvatar avatar;
  final String medicineName;

  /// Örn: "1×1 — PO (AC)"
  final String dose;

  /// Örn: "A-09", "B-11"
  final String drawerCode;

  final TreatmentPriority priority;
  final TreatmentStatus status;

  /// Son satırda timeline dikey çizgisi gizlenir
  final bool isLast;

  final VoidCallback? onDetail;

  // [HAZ-003] Acil + bekleyen kombinasyonu → kırmızı arka plan
  // Dışarıdan değil, içeride tutarlı şekilde hesaplanır
  bool get _isUrgent => priority == TreatmentPriority.urgent && status == TreatmentStatus.pending;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: _isUrgent ? 6 : 0, vertical: 9),
      decoration: _isUrgent ? BoxDecoration(color: const Color(0xFFFFF8F8), borderRadius: MedRadius.mdAll) : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Saat sütunu
          SizedBox(
            width: 44,
            child: Text(
              time,
              style: MedTextStyles.monoMd(
                color: _isUrgent ? MedColors.red : MedColors.text2,
                weight: _isUrgent ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Timeline çizgisi + nokta
          _TimelineLine(priority: priority, status: status, isLast: isLast),

          const SizedBox(width: 12),

          // Hasta + ilaç bilgisi
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    avatar,
                    const SizedBox(width: 7),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MedLabel(
                            text: patientName,
                            variant: MedLabelVariant.monoValue,
                            overflow: TextOverflow.ellipsis,
                          ),
                          MedLabel(text: patientId, variant: MedLabelVariant.monoDetail),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 3),

                Row(
                  children: [
                    Flexible(
                      child: MedLabel(
                        text: medicineName,
                        variant: MedLabelVariant.monoValue,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    MedLabel(text: dose, variant: MedLabelVariant.monoDetail),
                    const SizedBox(width: 6),
                    _DrawerTag(code: drawerCode, isWarning: _isUrgent),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 6),

          Row(
            children: [
              _PriorityBadge(priority: priority),
              const SizedBox(width: 4),
              _StatusBadge(status: status),
              const SizedBox(width: 4),
              _DetailButton(onTap: onDetail),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Timeline çizgisi ─────────────────────────────────────────────

class _TimelineLine extends StatelessWidget {
  const _TimelineLine({required this.priority, required this.status, required this.isLast});

  final TreatmentPriority priority;
  final TreatmentStatus status;
  final bool isLast;

  Color get _circleColor {
    if (status == TreatmentStatus.done) return MedColors.green;
    return switch (priority) {
      TreatmentPriority.urgent => MedColors.red,
      TreatmentPriority.normal => MedColors.blue,
      TreatmentPriority.routine => MedColors.text3,
    };
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 10,
      height: 48,
      child: Column(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _circleColor, width: 2),
              color: status == TreatmentStatus.done ? _circleColor.withOpacity(0.15) : MedColors.surface,
            ),
          ),
          if (!isLast)
            Expanded(
              child: Center(child: Container(width: 1.5, color: MedColors.border2)),
            ),
        ],
      ),
    );
  }
}

// ── Çekmece kodu etiketi ─────────────────────────────────────────

class _DrawerTag extends StatelessWidget {
  const _DrawerTag({required this.code, this.isWarning = false});

  final String code;
  final bool isWarning;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: isWarning ? MedColors.redLight : MedColors.blueLight,
        borderRadius: const BorderRadius.all(Radius.circular(4)),
      ),
      child: Text(code, style: MedTextStyles.monoXs(color: isWarning ? MedColors.red : MedColors.blue)),
    );
  }
}

// ── Öncelik badge ─────────────────────────────────────────────────

class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge({required this.priority});

  final TreatmentPriority priority;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label) = switch (priority) {
      TreatmentPriority.urgent => (MedColors.redLight, MedColors.red, 'Acil'),
      TreatmentPriority.normal => (MedColors.blueLight, MedColors.blue, 'Normal'),
      TreatmentPriority.routine => (MedColors.greenLight, MedColors.green, 'Rutin'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: MedRadius.xlAll),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: MedFonts.mono,
          fontSize: 9,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
          color: fg,
        ),
      ),
    );
  }
}

// ── Durum badge ───────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final TreatmentStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label, border) = switch (status) {
      TreatmentStatus.pending => (MedColors.amberLight, MedColors.amber, 'Bekliyor', null),
      TreatmentStatus.done => (MedColors.greenLight, MedColors.green, 'Dağıtıldı', null),
      TreatmentStatus.returned => (MedColors.surface3, MedColors.text3, 'İade', MedColors.border2),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: MedRadius.xlAll,
        border: border != null ? Border.all(color: border) : null,
      ),
      child: Text(label, style: MedTextStyles.monoXs(color: fg)),
    );
  }
}

// ── Detay butonu ──────────────────────────────────────────────────

class _DetailButton extends StatelessWidget {
  const _DetailButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: MedColors.surface,
          border: Border.all(color: MedColors.border2),
          borderRadius: const BorderRadius.all(Radius.circular(6)),
        ),
        alignment: Alignment.center,
        child: Icon(Icons.visibility_outlined, size: 11, color: MedColors.text3),
      ),
    );
  }
}
