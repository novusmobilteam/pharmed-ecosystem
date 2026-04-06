// lib/features/cabin/presentation/widgets/cell_info_card.dart
//
// [SWREQ-UI-CAB-004]
// Sağ panel üst kısmındaki göz bilgi kartı.
//
// Göz adresi gösterilmez. Gösterilen bilgiler:
//   - Atama durumu badge (İlaç Atanmış / Hasta Atanmış / Atanmamış)
//   - İlaç / hasta adı
//   - Min / Mevcut / Maks stok bar
//
// KULLANIM:
//   CellInfoCard(
//     stock: cabinStock,        // null → Atanmamış
//   )
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

// ─────────────────────────────────────────────────────────────────
// CellInfoCard
// ─────────────────────────────────────────────────────────────────

/// Seçili göze ait atama ve stok özetini gösterir.
///
/// [stock] null ise "Atanmamış" durumu gösterilir.
class CellInfoCard extends StatelessWidget {
  const CellInfoCard({super.key, this.stock});

  /// Seçili göze ait stok — null ise atanmamış.
  final CabinStock? stock;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: MedColors.surface2,
        border: Border.all(color: MedColors.border, width: 1.5),
        borderRadius: MedRadius.mdAll,
      ),
      child: stock == null ? const _UnassignedContent() : _AssignedContent(stock: stock!),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Atanmamış
// ─────────────────────────────────────────────────────────────────

class _UnassignedContent extends StatelessWidget {
  const _UnassignedContent();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text('Atanmamış', style: MedTextStyles.bodySm(color: MedColors.text3)),
        ),
        _AssignmentBadge.unassigned(),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Atanmış
// ─────────────────────────────────────────────────────────────────

class _AssignedContent extends StatelessWidget {
  const _AssignedContent({required this.stock});

  final CabinStock stock;

  @override
  Widget build(BuildContext context) {
    final assignment = stock.assignment;
    final name = assignment?.medicine?.name ?? '—';
    //final isPatient = assignment?.patient != null;
    final isPatient = false;

    final qty = stock.quantity?.toDouble() ?? 0;
    final min = assignment?.minQuantity?.toDouble() ?? 0;
    final max = assignment?.maxQuantity?.toDouble() ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // İsim + badge
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontFamily: MedFonts.sans,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: MedColors.text,
                ),
              ),
            ),
            const SizedBox(width: 8),
            isPatient ? _AssignmentBadge.patient() : _AssignmentBadge.drug(),
          ],
        ),
        const SizedBox(height: 10),

        // Stok bar
        _StockBar(qty: qty, min: min, max: max),
        const SizedBox(height: 6),

        // Min / Mevcut / Maks etiketleri
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Min: ${min.toInt()}', style: MedTextStyles.monoMd(color: MedColors.text3)),
            Text('Mevcut: ${qty.toInt()}', style: MedTextStyles.monoMd(color: MedColors.text2)),
            Text('Maks: ${max.toInt()}', style: MedTextStyles.monoMd(color: MedColors.text3)),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Stok bar
// ─────────────────────────────────────────────────────────────────

class _StockBar extends StatelessWidget {
  const _StockBar({required this.qty, required this.min, required this.max});

  final double qty;
  final double min;
  final double max;

  @override
  Widget build(BuildContext context) {
    final fraction = max > 0 ? (qty / max).clamp(0.0, 1.0) : 0.0;
    final color = _resolveBarColor(qty, min, max);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // Arka plan
            Container(
              height: 6,
              decoration: BoxDecoration(color: MedColors.surface3, borderRadius: BorderRadius.circular(3)),
            ),
            // Dolu kısım
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 6,
              width: constraints.maxWidth * fraction,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
            ),
          ],
        );
      },
    );
  }

  Color _resolveBarColor(double qty, double min, double max) {
    if (qty == 0) return MedColors.surface3;
    if (max <= 0) return MedColors.green;
    if (qty / max <= 0.2) return MedColors.red;
    if (qty <= min) return MedColors.amber;
    return MedColors.green;
  }
}

// ─────────────────────────────────────────────────────────────────
// Atama badge
// ─────────────────────────────────────────────────────────────────

class _AssignmentBadge extends StatelessWidget {
  const _AssignmentBadge({required this.label, required this.color, required this.bg});

  factory _AssignmentBadge.drug() =>
      const _AssignmentBadge(label: 'İlaç Atanmış', color: MedColors.blue, bg: MedColors.blueLight);

  factory _AssignmentBadge.patient() =>
      const _AssignmentBadge(label: 'Hasta Atanmış', color: MedColors.green, bg: MedColors.greenLight);

  factory _AssignmentBadge.unassigned() =>
      const _AssignmentBadge(label: 'Atanmamış', color: MedColors.text3, bg: MedColors.surface3);

  final String label;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: MedFonts.mono,
          fontSize: 9,
          fontWeight: FontWeight.w500,
          color: color,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
