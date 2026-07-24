// [SWREQ-UI-LOCATIONGUIDE-001] [IEC 62304 §5.5]
// Kabin operasyon ekranlarında (dolum, alım, sayım, iade, imha) kullanıcıya
// "hangi çekmeceye, hangi bölmeye/göze" yönlendirme yapan salt okunur konum rehberi.
//
// İki bölümden oluşur:
//   1. Kabin Genel Bakış — tüm çekmece listesi, aktif/tamamlandı/sırada/dahil değil
//      durumları. Aktif çekmece highlight'lı, tıklanınca scroll ile görünür hale gelir.
//   2. Konum Rehberi — aktif çekmecenin görsel yapısı:
//        - Kübik     → 4×N grid, aktif lid mavi, tamamlanan yeşil ✓, sıradaki soluk.
//        - Birim Doz → üstten bakış: yan yana bölmeler, aktif bölme(ler) mavi, diğerleri soluk.
//
// Ekrandan bağımsız — yalnızca [DrawerQueueItem] listesi + [activeIndex] alır.
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:collection/collection.dart';

class CabinLocationGuide extends StatelessWidget {
  const CabinLocationGuide({super.key, required this.items, required this.activeIndex});

  /// Tüm çekmeceler (kuyruğa girenler + girmeyenler).
  final List<DrawerQueueItem> items;

  /// Aktif job'ın index'i ([items] içindeki).
  final int activeIndex;

  DrawerQueueItem? get _activeItem => items.firstWhereOrNull((i) => i.status == DrawerQueueStatus.active);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MedColors.surface,
        border: Border.all(color: MedColors.border),
        borderRadius: MedRadius.lgAll,
        boxShadow: MedShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Kabin Genel Bakış — sabit yükseklik, max 5 çekmece görünür
          _OverviewSection(items: items, activeIndex: activeIndex),
          Divider(height: 1, thickness: 1, color: MedColors.border),
          // Konum Rehberi — kalan alanı kaplar
          Expanded(child: _activeItem == null ? const SizedBox.shrink() : _LocationSection(item: _activeItem!)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 1. Kabin Genel Bakış
// ─────────────────────────────────────────────────────────────────────────────

class _OverviewSection extends StatelessWidget {
  const _OverviewSection({required this.items, required this.activeIndex});

  final List<DrawerQueueItem> items;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    final inQueue = items.where((i) => i.isInQueue).length;
    final completed = items.where((i) => i.status == DrawerQueueStatus.completed).length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text('KABİN GENEL BAKIŞ', style: MedTextStyles.monoXs(color: MedColors.text3)),
              const Spacer(),
              Text('$completed/$inQueue', style: MedTextStyles.monoXs(color: MedColors.text3)),
            ],
          ),
          const SizedBox(height: 8),
          // Max ~5 çekmece görünür, fazlası scroll
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 220),
            child: SingleChildScrollView(
              child: Column(
                children: List.generate(items.length, (i) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: _OverviewRow(item: items[i], isActive: i == activeIndex),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewRow extends StatelessWidget {
  const _OverviewRow({required this.item, required this.isActive});

  final DrawerQueueItem item;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final Color borderColor;
    final Color bgColor;
    final Color textColor;

    switch (item.status) {
      case DrawerQueueStatus.active:
        borderColor = MedColors.blue;
        bgColor = MedColors.blueLight;
        textColor = MedColors.blue;
      case DrawerQueueStatus.completed:
        borderColor = MedColors.green;
        bgColor = MedColors.greenLight;
        textColor = MedColors.text;
      case DrawerQueueStatus.failed:
        borderColor = MedColors.red;
        bgColor = MedColors.redLight;
        textColor = MedColors.text;
      case DrawerQueueStatus.pending:
        borderColor = MedColors.border;
        bgColor = MedColors.surface;
        textColor = MedColors.text;
      case DrawerQueueStatus.notInQueue:
        borderColor = MedColors.border;
        bgColor = MedColors.surface2;
        textColor = MedColors.text3;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor, width: isActive ? 1.5 : 1),
        borderRadius: MedRadius.mdAll,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.address, style: MedTextStyles.bodySm(color: textColor)),
                Text(
                  item.isKubik ? 'Kübik Çekmece' : 'Birim Doz Çekmece',
                  style: MedTextStyles.monoXs(color: MedColors.text3),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _StatusIndicator(status: item.status),
        ],
      ),
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  const _StatusIndicator({required this.status});

  final DrawerQueueStatus status;

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      DrawerQueueStatus.completed => Icon(
        PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
        size: 16,
        color: MedColors.green,
      ),
      DrawerQueueStatus.failed => Icon(PhosphorIcons.xCircle(PhosphorIconsStyle.fill), size: 16, color: MedColors.red),
      DrawerQueueStatus.active => Container(
        width: 20,
        height: 4,
        decoration: BoxDecoration(color: MedColors.blue, borderRadius: BorderRadius.circular(999)),
      ),
      DrawerQueueStatus.notInQueue => Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: MedColors.surface2,
          border: Border.all(color: MedColors.border2),
          borderRadius: BorderRadius.circular(3),
        ),
      ),
      DrawerQueueStatus.pending => Container(
        width: 20,
        height: 4,
        decoration: BoxDecoration(color: MedColors.border2, borderRadius: BorderRadius.circular(999)),
      ),
    };
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. Konum Rehberi
// ─────────────────────────────────────────────────────────────────────────────

class _LocationSection extends StatelessWidget {
  const _LocationSection({required this.item});

  final DrawerQueueItem item;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('KONUM REHBERİ', style: MedTextStyles.monoXs(color: MedColors.text3)),
          const SizedBox(height: 4),
          Text(item.address, style: MedTextStyles.titleLg()),
          const SizedBox(height: 14),
          item.isKubik ? _KubikGrid(item: item) : _UnitDoseTopView(item: item),
          const SizedBox(height: 12),
          item.isKubik ? const _KubikLegend() : _UnitDoseLegend(item: item),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Kübik Grid (4×N)
// ─────────────────────────────────────────────────────────────────────────────

class _KubikGrid extends StatelessWidget {
  const _KubikGrid({required this.item});

  final DrawerQueueItem item;

  static const int _cols = 4;

  @override
  Widget build(BuildContext context) {
    final count = item.units.length;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFDCE8F5),
        border: Border.all(color: const Color(0xFFA8BEDB), width: 1.5),
        borderRadius: MedRadius.mdAll,
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _cols,
          crossAxisSpacing: 5,
          mainAxisSpacing: 5,
          mainAxisExtent: 48,
        ),
        itemCount: count,
        itemBuilder: (_, i) => _KubikCell(
          index: i,
          isActive: item.activeTargetIndex == i,
          isCompleted: item.completedTargetIndexes.contains(i),
          isNotInQueue: !item.isInQueue,
        ),
      ),
    );
  }
}

class _KubikCell extends StatelessWidget {
  const _KubikCell({
    required this.index,
    required this.isActive,
    required this.isCompleted,
    required this.isNotInQueue,
  });

  final int index;
  final bool isActive;
  final bool isCompleted;
  final bool isNotInQueue;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color border;
    final Color textColor;
    final List<BoxShadow>? shadow;

    if (isCompleted) {
      bg = MedColors.greenLight;
      border = MedColors.green;
      textColor = MedColors.green;
      shadow = null;
    } else if (isActive) {
      bg = MedColors.blueLight;
      border = MedColors.blue;
      textColor = MedColors.blue;
      shadow = [const BoxShadow(color: Color(0x331A6FD8), blurRadius: 6, offset: Offset(0, 2))];
    } else if (isNotInQueue) {
      bg = MedColors.surface2;
      border = MedColors.border;
      textColor = MedColors.text4;
      shadow = null;
    } else {
      bg = MedColors.surface;
      border = MedColors.border;
      textColor = MedColors.text4;
      shadow = null;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border, width: isActive ? 2 : 1.5),
        borderRadius: BorderRadius.circular(6),
        boxShadow: shadow,
      ),
      child: Center(
        child: isCompleted
            ? Icon(PhosphorIcons.check(PhosphorIconsStyle.bold), size: 14, color: MedColors.green)
            : Text('${index + 1}', style: MedTextStyles.monoXs(color: textColor)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Birim Doz — Üstten Bakış (yan yana bölmeler)
// ─────────────────────────────────────────────────────────────────────────────

class _UnitDoseTopView extends StatelessWidget {
  const _UnitDoseTopView({required this.item});

  final DrawerQueueItem item;

  @override
  Widget build(BuildContext context) {
    final units = item.units;
    if (units.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFD8E4F0),
        border: Border.all(color: const Color(0xFFA0B8D0), width: 1.5),
        borderRadius: MedRadius.mdAll,
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (int ui = 0; ui < units.length; ui++) ...[
              Expanded(
                child: _UnitDoseColumn(
                  unitIndex: ui,
                  label: String.fromCharCode(65 + ui), // A, B, C...
                  isActive: item.isInQueue && (item.activeUnitIndexes.isEmpty || item.activeUnitIndexes.contains(ui)),
                  isNotInQueue: !item.isInQueue,
                ),
              ),
              if (ui < units.length - 1)
                Container(
                  width: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(color: const Color(0xFFA0B8D0), borderRadius: BorderRadius.circular(2)),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _UnitDoseColumn extends StatelessWidget {
  const _UnitDoseColumn({
    required this.unitIndex,
    required this.label,
    required this.isActive,
    required this.isNotInQueue,
  });

  final int unitIndex;
  final String label;
  final bool isActive;
  final bool isNotInQueue;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color border;
    final Color labelColor;

    if (isNotInQueue) {
      bg = MedColors.surface2;
      border = MedColors.border;
      labelColor = MedColors.text4;
    } else if (isActive) {
      bg = MedColors.blueLight;
      border = MedColors.blue;
      labelColor = MedColors.blue;
    } else {
      bg = MedColors.surface;
      border = MedColors.border;
      labelColor = MedColors.text3;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border, width: isActive ? 2 : 1),
        borderRadius: BorderRadius.circular(6),
        boxShadow: isActive ? [const BoxShadow(color: Color(0x221A6FD8), blurRadius: 4)] : null,
      ),
      child: Center(
        child: Text(
          label,
          style: MedTextStyles.monoSm(color: labelColor),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Legend'lar
// ─────────────────────────────────────────────────────────────────────────────

class _KubikLegend extends StatelessWidget {
  const _KubikLegend();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _LegendItem(color: MedColors.blue, bg: MedColors.blueLight, label: 'Şu an dolduruluyor'),
        const SizedBox(height: 4),
        _LegendItem(color: MedColors.green, bg: MedColors.greenLight, label: 'Tamamlandı'),
        const SizedBox(height: 4),
        _LegendItem(color: MedColors.border, bg: MedColors.surface, label: 'Sırada'),
      ],
    );
  }
}

class _UnitDoseLegend extends StatelessWidget {
  const _UnitDoseLegend({required this.item});

  final DrawerQueueItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _LegendItem(color: MedColors.blue, bg: MedColors.blueLight, label: 'Hedef bölme'),
        if (item.units.length > 1 &&
            item.activeUnitIndexes.isNotEmpty &&
            item.activeUnitIndexes.length < item.units.length) ...[
          const SizedBox(height: 4),
          _LegendItem(color: MedColors.border, bg: MedColors.surface, label: 'Bu işleme dahil değil'),
        ],
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.bg, required this.label});

  final Color color;
  final Color bg;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: bg,
            border: Border.all(color: color, width: 1.5),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(label, style: MedTextStyles.bodySm(color: MedColors.text2)),
        ),
      ],
    );
  }
}
