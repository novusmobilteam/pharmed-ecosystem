import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../notifier/stock_movement_summary.dart';
import 'stock_movement_palette.dart';

/// Zaman içinde hareketler — her gün/saat için hareket tipleri yan yana
/// (gruplu çubuk grafik).
class StockMovementTimelineChart extends StatelessWidget {
  const StockMovementTimelineChart({super.key, required this.summary});

  final StockMovementSummary summary;

  /// Eksende en fazla bu kadar etiket gösterilir; 30 günlük aralıkta yazılar üst üste binmez.
  static const int _maxAxisLabels = 8;
  static const double _leftAxisWidth = 36;
  static const double _rodsSpace = 1.5;

  @override
  Widget build(BuildContext context) {
    final points = summary.timeline;

    // Grupta yalnızca aralıkta en az bir hareketi olan tipler yer alır;
    // sıra enum sırasıdır, böylece her grupta aynı tip aynı konumdadır.
    final present = summary.byType.map((t) => t.type).toSet();
    final types = StationTransactionType.values.where(present.contains).toList();

    final maxCount = points.fold<int>(0, (m, p) => p.countsByType.values.fold(m, math.max));
    // %15 pay: en uzun çubuğun üstündeki sayı grafiğin tepesine taşmasın.
    final maxY = _niceCeil((maxCount * 1.15).ceil());
    final labelEvery = (points.length / _maxAxisLabels).ceil().clamp(1, math.max(points.length, 1));

    return LayoutBuilder(
      builder: (context, constraints) {
        final rodWidth = _rodWidth(constraints.maxWidth - _leftAxisWidth, points.length, types.length);

        return BarChart(
          BarChartData(
            maxY: maxY,
            alignment: BarChartAlignment.spaceAround,
            barGroups: [for (var i = 0; i < points.length; i++) _group(i, points[i], types, rodWidth)],
            gridData: FlGridData(
              drawVerticalLine: false,
              horizontalInterval: maxY / 4,
              getDrawingHorizontalLine: (_) => const FlLine(color: MedColors.border, strokeWidth: 1),
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(),
              rightTitles: const AxisTitles(),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: _leftAxisWidth,
                  interval: maxY / 4,
                  getTitlesWidget: (value, meta) => SideTitleWidget(
                    meta: meta,
                    child: Text(value.toInt().toString(), style: MedTextStyles.monoXs()),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  getTitlesWidget: (value, meta) {
                    final i = value.toInt();
                    if (i < 0 || i >= points.length || i % labelEvery != 0) return const SizedBox.shrink();
                    return SideTitleWidget(
                      meta: meta,
                      child: Text(_axisLabel(points[i].bucketStart), style: MedTextStyles.monoXs()),
                    );
                  },
                ),
              ),
            ),
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) => StockMovementPalette.tooltipBg,
                //borderRadius: MedRadius.mdAll,
                tooltipPadding: MedSpacing.insetMd,
                fitInsideHorizontally: true,
                fitInsideVertically: true,
                getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                    _tooltipItem(context, points[group.x], types, rodIndex),
              ),
            ),
          ),
          duration: const Duration(milliseconds: 250),
        );
      },
    );
  }

  /// Grup genişliğinin ~%75'i çubuklara ayrılır, kalanı günler arası boşluktur.
  double _rodWidth(double chartWidth, int groupCount, int rodCount) {
    if (groupCount == 0 || rodCount == 0) return 8;
    final groupWidth = chartWidth / groupCount * 0.75;
    final width = (groupWidth - _rodsSpace * (rodCount - 1)) / rodCount;
    return width.clamp(2.0, 18.0);
  }

  BarChartGroupData _group(int x, StockMovementTimePoint point, List<StationTransactionType> types, double width) {
    BarChartRodLabel label(StationTransactionType type) =>
        _rodLabel(point.countsByType[type] ?? 0, StockMovementPalette.of(type), width);

    return BarChartGroupData(
      x: x,
      barsSpace: _rodsSpace,
      barRods: [
        // Sıfır olan tipler de 0 yükseklikli çubuk olarak kalır; konumlar kaymaz.
        for (final type in types)
          BarChartRodData(
            toY: (point.countsByType[type] ?? 0).toDouble(),
            width: width,
            color: StockMovementPalette.of(type),
            borderRadius: BorderRadius.vertical(top: Radius.circular(math.min(3, width / 2))),
            label: label(type),
          ),
      ],
    );
  }

  /// Çubuğun tepesine yazılan adet etiketi.
  ///
  /// Yazı çubuk + boşluk genişliğine sığıyorsa yatay, sığmıyor ama dikey
  /// sığıyorsa 90° döndürülmüş yazılır. İkisi de sığmıyorsa (30 günlük
  /// aralıkta çok ince çubuklar) komşu etiketler üst üste bineceği için
  /// gizlenir; değer yine tooltip'ten okunur.
  BarChartRodLabel _rodLabel(int count, Color color, double rodWidth) {
    if (count == 0) return const BarChartRodLabel(show: false);

    final text = '$count';
    final style = MedTextStyles.monoXs().copyWith(color: color, fontWeight: FontWeight.w600);
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    final slot = rodWidth + _rodsSpace;

    if (painter.width <= slot) {
      return BarChartRodLabel(text: text, style: style, offset: const Offset(0, 3));
    }
    if (painter.height <= slot + 2) {
      // Döndürülen yazı merkezi etrafında döner; alt ucu çubuğun 3px
      // üstünde kalsın diye (genişlik - yükseklik) / 2 kadar yukarı itilir.
      return BarChartRodLabel(
        text: text,
        style: style,
        angle: -90,
        offset: Offset(0, 3 + (painter.width - painter.height) / 2),
      );
    }
    return const BarChartRodLabel(show: false);
  }

  /// fl_chart dokunulan grubun her çubuğu için bir satır ister ve hepsini
  /// tek kutuda alt alta gösterir. İlk satıra tarih ve toplam eklenir;
  /// sıfır olan tipler null döndürülerek gizlenir.
  BarTooltipItem? _tooltipItem(
    BuildContext context,
    StockMovementTimePoint point,
    List<StationTransactionType> types,
    int rodIndex,
  ) {
    const base = TextStyle(color: Colors.white, fontSize: 12);
    final type = types[rodIndex];
    final count = point.countsByType[type] ?? 0;
    final line = TextSpan(
      text: '● ${type.label(context)}: $count',
      style: base.copyWith(color: StockMovementPalette.of(type)),
    );

    final isFirstVisible = types.take(rodIndex).every((t) => (point.countsByType[t] ?? 0) == 0);

    if (count == 0) {
      // Hiç hareket yoksa yine de başlık görünsün.
      if (rodIndex == 0 && point.total == 0) {
        return BarTooltipItem(_header(point), base.copyWith(fontWeight: FontWeight.w700));
      }
      return null;
    }

    if (!isFirstVisible) return BarTooltipItem('', base, textAlign: TextAlign.left, children: [line]);

    return BarTooltipItem(
      '${_header(point)}\n',
      base.copyWith(fontWeight: FontWeight.w700),
      textAlign: TextAlign.left,
      children: [
        TextSpan(text: '${context.l10n.movement_chart_tooltipTotal(point.total)}\n', style: base),
        line,
      ],
    );
  }

  String _header(StockMovementTimePoint point) => summary.bucket == StockMovementBucket.hour
      ? '${StockMovementDateFormat.dayMonth(point.bucketStart)} ${StockMovementDateFormat.hour(point.bucketStart)}'
      : StockMovementDateFormat.full(point.bucketStart);

  String _axisLabel(DateTime d) => summary.bucket == StockMovementBucket.hour
      ? StockMovementDateFormat.hour(d)
      : StockMovementDateFormat.dayMonth(d);

  /// Y ekseni üst sınırı: 4 eşit, "yuvarlak" aralığa bölünen en küçük değer
  /// (örn. 7 → 8, 37 → 40, 180 → 200).
  static double _niceCeil(int value) {
    if (value <= 4) return 4;
    final raw = value / 4;
    final magnitude = math.pow(10, (math.log(raw) / math.ln10).floor()).toDouble();
    for (final m in const [1, 2, 5, 10]) {
      if (m * magnitude >= raw) return m * magnitude * 4;
    }
    return raw.ceil() * 4.0;
  }
}
