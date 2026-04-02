// lib/features/cabin/presentation/widgets/cabin_summary_view.dart
//
// [SWREQ-UI-CAB-001]
// Dashboard sol panelinde kabinin genel durumunu salt okunur olarak gösterir.
// Stok durumuna göre renk kodlanmış çekmece grid'i sunar.
//
// KULLANIM:
//   CabinSummaryView.fromData(
//     data: cabinVisualizerData,
//     powerStatus: LedStatus.on,
//     alertStatus: LedStatus.off,
//   )
//
// BAĞIMLILIK:
//   - pharmed_core: CabinVisualizerData, DrawerSlotVisual, DrawerStatus
//   - pharmed_ui: MedColors, MedFonts, MedTextStyles, MedRadius, LedIndicator
//
// Sınıf: Class B — Yanlış stok rengi yanlış müdahale tetikleyebilir.

import 'package:flutter/material.dart';
import 'package:pharmed_ui/src/widgets/atoms/led_indicator.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

// ─────────────────────────────────────────────────────────────────
// CabinSummaryView
// ─────────────────────────────────────────────────────────────────

/// Dashboard özeti için salt okunur kabin görsel bileşeni.
///
/// Kabindeki çekmece yapısını ve stok durumunu renk kodlu olarak gösterir.
/// Tıklama davranışı yoktur — yalnızca bilgi amaçlıdır.
///
/// [DrawerSlotVisual] tipine göre 3 farklı render üretir:
/// - [KubicSlotVisual]: NxM grid (4×4 veya 4×5)
/// - [UnitDoseSlotVisual]: yatay renkli bloklar
/// - [SerumSlotVisual]: çok satır yüksekliğinde tek blok
class CabinSummaryView extends StatelessWidget {
  const CabinSummaryView({
    super.key,
    required this.cabinId,
    required this.powerStatus,
    required this.alertStatus,
    required this.slots,
  });

  /// Named constructor — [CabinVisualizerData]'dan doğrudan üretir.
  factory CabinSummaryView.fromData({
    Key? key,
    required CabinVisualizerData data,
    required LedStatus powerStatus,
    required LedStatus alertStatus,
  }) {
    return CabinSummaryView(
      key: key,
      cabinId: 'CB-${data.cabinId.toString().padLeft(3, '0')}',
      powerStatus: powerStatus,
      alertStatus: alertStatus,
      slots: data.slots,
    );
  }

  /// Kabin kimlik etiketi (örn: "CB-304")
  final String cabinId;
  final LedStatus powerStatus;
  final LedStatus alertStatus;

  /// Render edilecek çekmece listesi.
  /// [DrawerSlotVisual] tipine göre farklı görsel üretilir.
  final List<DrawerSlotVisual> slots;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFD8E0EC),
        border: Border.all(color: MedColors.border2, width: 2),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(14),
          topRight: Radius.circular(14),
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
        boxShadow: const [
          BoxShadow(color: Color(0x1F1E3C64), blurRadius: 40, offset: Offset(0, 12)),
          BoxShadow(color: Color(0x141E3C64), blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CabinHeader(cabinId: cabinId, powerStatus: powerStatus, alertStatus: alertStatus),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < slots.length; i++) ...[
                  _SlotView(slot: slots[i]),
                  if (i < slots.length - 1) const SizedBox(height: 4),
                ],
              ],
            ),
          ),
          const _CabinFooter(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────────────

class _CabinHeader extends StatelessWidget {
  const _CabinHeader({required this.cabinId, required this.powerStatus, required this.alertStatus});

  final String cabinId;
  final LedStatus powerStatus;
  final LedStatus alertStatus;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFC4CEDF), Color(0xFFB4C0D4)],
        ),
        border: Border(bottom: BorderSide(color: MedColors.border2, width: 2)),
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
      ),
      child: Row(
        children: [
          LedIndicator(status: powerStatus),
          const SizedBox(width: 5),
          LedIndicator(status: alertStatus),
          const Spacer(),
          Text(
            cabinId,
            style: TextStyle(
              fontFamily: MedFonts.mono,
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF3A4D66),
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Footer (tekerlekler)
// ─────────────────────────────────────────────────────────────────

class _CabinFooter extends StatelessWidget {
  const _CabinFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 14,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFB4C0D4), Color(0xFFA0AEC0)],
        ),
        border: Border(top: BorderSide(color: MedColors.border2, width: 1.5)),
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [_Wheel(), const SizedBox(width: 18), _Wheel()],
      ),
    );
  }
}

class _Wheel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 15,
      height: 7,
      decoration: BoxDecoration(
        color: const Color(0xFF6A7A90),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: const Color(0xFF505E72)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Slot dispatcher
// ─────────────────────────────────────────────────────────────────

/// Slot tipine göre doğru render widget'ını seçer.
///
/// Public field promote sorunu nedeniyle local variable kullanılır.
class _SlotView extends StatelessWidget {
  const _SlotView({required this.slot});

  final DrawerSlotVisual slot;

  @override
  Widget build(BuildContext context) {
    final s = slot;
    return switch (s) {
      KubicSlotVisual() => _KubicSlotView(slot: s),
      UnitDoseSlotVisual() => _UnitDoseSlotView(slot: s),
      SerumSlotVisual() => _SerumSlotView(slot: s),
    };
  }
}

// ─────────────────────────────────────────────────────────────────
// Renk yardımcısı
// ─────────────────────────────────────────────────────────────────

/// [DrawerStatus]'a karşılık gelen arka plan ve kenar renklerini döndürür.
///
/// Tüm slot render widget'ları bu yardımcıyı kullanır.
final class _StatusColors {
  const _StatusColors({required this.bg, required this.border});

  final Color bg;
  final Color border;

  /// [DrawerStatus]'a göre renk çifti döndürür.
  static _StatusColors of(DrawerStatus status) => switch (status) {
    DrawerStatus.full => const _StatusColors(bg: Color(0xFFEDF6FF), border: Color(0xFF90C4F5)),
    DrawerStatus.low => const _StatusColors(bg: Color(0xFFFFFBEB), border: Color(0xFFFCD34D)),
    DrawerStatus.critical => const _StatusColors(bg: Color(0xFFFFF5F5), border: Color(0xFFFCA5A5)),
    DrawerStatus.empty => _StatusColors(bg: MedColors.surface3, border: MedColors.border2),
  };
}

// ─────────────────────────────────────────────────────────────────
// Kübik slot
// ─────────────────────────────────────────────────────────────────

/// Kübik çekmece özeti — NxM grid, her hücre 14px kare.
///
/// [KubicSlotVisual.cells] düz liste olarak gelir,
/// [KubicSlotVisual.columnCount]'a göre satırlara bölünür.
class _KubicSlotView extends StatelessWidget {
  const _KubicSlotView({required this.slot});

  final KubicSlotVisual slot;

  @override
  Widget build(BuildContext context) {
    // Düz listeyi satırlara böl
    final rows = <List<DrawerStatus>>[];
    for (int i = 0; i < slot.cells.length; i += slot.columnCount) {
      rows.add(slot.cells.sublist(i, (i + slot.columnCount).clamp(0, slot.cells.length)));
    }

    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFFDCE8F5),
        border: Border.all(color: const Color(0xFFA8BEDB), width: 1.5),
        borderRadius: BorderRadius.circular(7),
        boxShadow: const [BoxShadow(color: Color(0x1F1E3C64), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int r = 0; r < rows.length; r++) ...[
            Row(
              children: [
                for (int c = 0; c < rows[r].length; c++) ...[
                  Expanded(child: _KubicCell(status: rows[r][c])),
                  if (c < rows[r].length - 1) const SizedBox(width: 3),
                ],
              ],
            ),
            if (r < rows.length - 1) const SizedBox(height: 3),
          ],
        ],
      ),
    );
  }
}

/// Kübik grid içindeki tek bir göz — 14px yükseklik.
class _KubicCell extends StatelessWidget {
  const _KubicCell({required this.status});

  final DrawerStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = _StatusColors.of(status);
    return Container(
      height: 14,
      decoration: BoxDecoration(
        color: colors.bg,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Birim Doz slot
// ─────────────────────────────────────────────────────────────────

/// Birim Doz çekmece özeti — compartmentlar yan yana renkli bloklar.
///
/// Her [DrawerStatus] bir [DrawerUnit]'e (yatay grup) karşılık gelir.
class _UnitDoseSlotView extends StatelessWidget {
  const _UnitDoseSlotView({required this.slot});

  final UnitDoseSlotVisual slot;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFD8E4F0),
        border: Border.all(color: const Color(0xFFA0B8D0), width: 1.5),
        borderRadius: BorderRadius.circular(7),
        boxShadow: const [BoxShadow(color: Color(0x1F1E3C64), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          for (int i = 0; i < slot.cells.length; i++) ...[
            Expanded(child: _UnitDoseCell(status: slot.cells[i])),
            if (i < slot.cells.length - 1) const SizedBox(width: 2),
          ],
        ],
      ),
    );
  }
}

/// Birim doz içindeki tek bir compartment bloğu — 24px yükseklik.
class _UnitDoseCell extends StatelessWidget {
  const _UnitDoseCell({required this.status});

  final DrawerStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = _StatusColors.of(status);
    return Container(
      height: 24,
      decoration: BoxDecoration(
        color: colors.bg,
        border: Border.all(color: colors.border, width: 1.5),
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Serum slot
// ─────────────────────────────────────────────────────────────────

/// Serum çekmece özeti — [heightFactor] × birim yüksekliğinde tek blok.
///
/// Serum çekmeceleri fiziksel olarak daha büyük olduğundan
/// [heightFactor] katı yükseklikte gösterilir (varsayılan: 2).
///
/// TODO: Serum iç yapısı netleşince bu widget genişletilecek.
class _SerumSlotView extends StatelessWidget {
  const _SerumSlotView({required this.slot});

  final SerumSlotVisual slot;

  /// Birim yükseklik — [_UnitDoseCell] ile tutarlı
  static const _unitHeight = 24.0;

  /// Slotlar arası boşluk
  static const _gap = 4.0;

  @override
  Widget build(BuildContext context) {
    final height = slot.heightFactor * _unitHeight + (slot.heightFactor - 1) * _gap + 8; // padding
    final colors = _StatusColors.of(slot.status);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: colors.bg,
        border: Border.all(color: colors.border, width: 1.5),
        borderRadius: BorderRadius.circular(7),
      ),
      alignment: Alignment.center,
      child: Text(
        'SRM',
        style: TextStyle(fontFamily: MedFonts.mono, fontSize: 7, color: MedColors.text3, letterSpacing: 1),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Legend
// ─────────────────────────────────────────────────────────────────

/// Kabin altındaki renk açıklama satırı.
///
/// Tüm [DrawerStatus] değerlerini gösterir.
class CabinStatusLegend extends StatelessWidget {
  const CabinStatusLegend({super.key});

  static const _items = [
    (DrawerStatus.full, 'Dolu'),
    (DrawerStatus.low, 'Düşük'),
    (DrawerStatus.critical, 'Kritik'),
    (DrawerStatus.empty, 'Boş'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      decoration: BoxDecoration(
        color: MedColors.surface,
        border: Border.all(color: MedColors.border),
        borderRadius: MedRadius.mdAll,
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 4,
        children: _items.map((item) {
          final colors = _StatusColors.of(item.$1);
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: colors.bg,
                  border: Border.all(color: colors.border),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 4),
              Text(item.$2, style: MedTextStyles.bodySm(color: MedColors.text2)),
            ],
          );
        }).toList(),
      ),
    );
  }
}
