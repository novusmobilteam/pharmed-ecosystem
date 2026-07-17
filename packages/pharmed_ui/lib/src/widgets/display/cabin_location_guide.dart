// [SWREQ-UI-LOCATIONGUIDE-001] [IEC 62304 §5.5]
// Kabin operasyon ekranlarında (dolum, alım, sayım, iade, imha) kullanıcıya
// "hangi çekmeceye, hangi göze" yönlendirme yapan salt okunur konum rehberi.
//
// İki bölümden oluşur:
//   1. Kabin Genel Bakış — tüm çekmece kuyruğu, aktif/tamamlandı/sırada durumları.
//   2. Konum Rehberi     — aktif çekmecenin görsel yapısı:
//        - Kübik       → 4×N grid, aktif lid mavi, tamamlanan yeşil ✓, sıradaki soluk.
//        - Birim Doz   → kolon(lar) + step'ler, anatomik gösterim (seçim yok).
//
// Ekrandan bağımsız — yalnızca [DrawerQueueItem] listesi alır.
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CabinLocationGuide extends StatelessWidget {
  const CabinLocationGuide({super.key, required this.items, required this.activeIndex});

  /// Tüm çekmece kuyruğu.
  final List<DrawerQueueItem> items;

  /// Aktif job'ın index'i.
  final int activeIndex;

  DrawerQueueItem? get _activeItem => (activeIndex >= 0 && activeIndex < items.length) ? items[activeIndex] : null;

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
          _OverviewSection(items: items, activeIndex: activeIndex),
          const Divider(height: 1, thickness: 1),
          Expanded(child: _activeItem == null ? const SizedBox.shrink() : _LocationSection(item: _activeItem!)),
        ],
      ),
    );
  }
}

// ── 1. Kabin Genel Bakış ──────────────────────────────────────────────────────

class _OverviewSection extends StatelessWidget {
  const _OverviewSection({required this.items, required this.activeIndex});

  final List<DrawerQueueItem> items;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    final completed = items.where((i) => i.status == DrawerQueueStatus.completed).length;
    final total = items.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text('KABİN GENEL BAKIŞ', style: MedTextStyles.monoXs(color: MedColors.text3)),
              const Spacer(),
              Text('$completed/$total', style: MedTextStyles.monoXs(color: MedColors.text3)),
            ],
          ),
          const SizedBox(height: 8),
          ...List.generate(items.length, (i) {
            final item = items[i];
            final isActive = i == activeIndex;
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: _OverviewRow(item: item, isActive: isActive),
            );
          }),
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
    final isCompleted = item.status == DrawerQueueStatus.completed;
    final isFailed = item.status == DrawerQueueStatus.failed;

    final borderColor = isActive
        ? MedColors.blue
        : isCompleted
        ? MedColors.green
        : MedColors.border;

    final bgColor = isActive
        ? MedColors.blueLight
        : isCompleted
        ? MedColors.greenLight
        : MedColors.surface;

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
                Text(item.address, style: MedTextStyles.bodySm(color: isActive ? MedColors.blue : MedColors.text)),
                Text(
                  item.isKubik ? 'Kübik Çekmece' : 'Birim Doz Çekmece',
                  style: MedTextStyles.monoXs(color: MedColors.text3),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isCompleted)
            Icon(PhosphorIcons.checkCircle(PhosphorIconsStyle.fill), size: 16, color: MedColors.green)
          else if (isFailed)
            Icon(PhosphorIcons.xCircle(PhosphorIconsStyle.fill), size: 16, color: MedColors.red)
          else if (isActive)
            Container(
              width: 20,
              height: 4,
              decoration: BoxDecoration(color: MedColors.blue, borderRadius: BorderRadius.circular(999)),
            )
          else
            Container(
              width: 20,
              height: 4,
              decoration: BoxDecoration(color: MedColors.border2, borderRadius: BorderRadius.circular(999)),
            ),
        ],
      ),
    );
  }
}

// ── 2. Konum Rehberi ──────────────────────────────────────────────────────────

class _LocationSection extends StatelessWidget {
  const _LocationSection({required this.item});

  final DrawerQueueItem item;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('KONUM REHBERİ', style: MedTextStyles.monoXs(color: MedColors.text3)),
          const SizedBox(height: 4),
          Text(item.address, style: MedTextStyles.titleLg()),
          const SizedBox(height: 14),
          item.isKubik ? _KubikGrid(item: item) : _UnitDoseLayout(item: item),
          const SizedBox(height: 14),
          item.isKubik ? const _KubikLegend() : const _UnitDoseLegend(),
        ],
      ),
    );
  }
}

// ── Kübik Grid ────────────────────────────────────────────────────────────────

class _KubikGrid extends StatelessWidget {
  const _KubikGrid({required this.item});

  final DrawerQueueItem item;

  static const int _crossAxisCount = 4;

  @override
  Widget build(BuildContext context) {
    final units = item.units;

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
          crossAxisCount: _crossAxisCount,
          crossAxisSpacing: 5,
          mainAxisSpacing: 5,
          mainAxisExtent: 52,
        ),
        itemCount: units.length,
        itemBuilder: (context, i) {
          //final unit = units[i];
          final isActive = item.activeTargetIndex == i;
          final isCompleted = item.completedTargetIndexes.contains(i);

          return _KubikCell(index: i, isActive: isActive, isCompleted: isCompleted);
        },
      ),
    );
  }
}

class _KubikCell extends StatelessWidget {
  const _KubikCell({required this.index, required this.isActive, required this.isCompleted});

  final int index;
  final bool isActive;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    final Color bgColor;
    final Color borderColor;
    final Color textColor;

    if (isCompleted) {
      bgColor = MedColors.greenLight;
      borderColor = MedColors.green;
      textColor = MedColors.green;
    } else if (isActive) {
      bgColor = MedColors.blueLight;
      borderColor = MedColors.blue;
      textColor = MedColors.blue;
    } else {
      bgColor = MedColors.surface;
      borderColor = MedColors.border;
      textColor = MedColors.text4;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor, width: isActive ? 2 : 1.5),
        borderRadius: BorderRadius.circular(6),
        boxShadow: isActive ? [const BoxShadow(color: Color(0x331A6FD8), blurRadius: 6, offset: Offset(0, 2))] : null,
      ),
      child: Center(
        child: isCompleted
            ? Icon(PhosphorIcons.check(PhosphorIconsStyle.bold), size: 16, color: MedColors.green)
            : Text('${index + 1}', style: MedTextStyles.monoSm(color: textColor)),
      ),
    );
  }
}

// ── Birim Doz Layout ──────────────────────────────────────────────────────────

class _UnitDoseLayout extends StatelessWidget {
  const _UnitDoseLayout({required this.item});

  final DrawerQueueItem item;

  @override
  Widget build(BuildContext context) {
    final units = item.units;
    final steps = item.numberOfSteps;

    if (units.isEmpty || steps == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFD8E4F0),
        border: Border.all(color: const Color(0xFFA0B8D0), width: 1.5),
        borderRadius: MedRadius.mdAll,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int ui = 0; ui < units.length; ui++) ...[
            Expanded(
              child: _UnitDoseColumn(unitIndex: ui, steps: steps),
            ),
            if (ui < units.length - 1)
              Container(
                width: 2,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: steps * 34.0, // her step ~34px
                decoration: BoxDecoration(color: const Color(0xFFA0B8D0), borderRadius: BorderRadius.circular(2)),
              ),
          ],
        ],
      ),
    );
  }
}

class _UnitDoseColumn extends StatelessWidget {
  const _UnitDoseColumn({required this.unitIndex, required this.steps});

  final int unitIndex;
  final int steps;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Kolon başlığı
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            String.fromCharCode(65 + unitIndex), // A, B, C...
            style: MedTextStyles.monoXs(color: MedColors.text3),
            textAlign: TextAlign.center,
          ),
        ),
        for (int s = 0; s < steps; s++)
          Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: _UnitDoseCell(stepNo: s + 1, columnLabel: String.fromCharCode(65 + unitIndex)),
          ),
      ],
    );
  }
}

class _UnitDoseCell extends StatelessWidget {
  const _UnitDoseCell({required this.stepNo, required this.columnLabel});

  final int stepNo;
  final String columnLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      decoration: BoxDecoration(
        color: MedColors.surface,
        border: Border.all(color: MedColors.border, width: 1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Center(
        child: Text('G$columnLabel·$stepNo', style: MedTextStyles.monoXs(color: MedColors.text3)),
      ),
    );
  }
}

// ── Legend'lar ────────────────────────────────────────────────────────────────

class _KubikLegend extends StatelessWidget {
  const _KubikLegend();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _LegendItem(color: MedColors.blue, bgColor: MedColors.blueLight, label: 'Şu an dolduruluyor'),
        const SizedBox(height: 4),
        _LegendItem(color: MedColors.green, bgColor: MedColors.greenLight, label: 'Tamamlandı'),
        const SizedBox(height: 4),
        _LegendItem(color: MedColors.border, bgColor: MedColors.surface, label: 'Sırada'),
      ],
    );
  }
}

class _UnitDoseLegend extends StatelessWidget {
  const _UnitDoseLegend();

  @override
  Widget build(BuildContext context) {
    return _LegendItem(
      color: MedColors.border,
      bgColor: MedColors.surface,
      label: 'İstediğiniz göze dolum yapabilirsiniz',
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.bgColor, required this.label});

  final Color color;
  final Color bgColor;
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
            color: bgColor,
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
