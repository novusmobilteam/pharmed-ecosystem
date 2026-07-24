// Master kabin işlem ekranlarının (dolum, sayım, iade...) ortak hücre
// listesi/grid'i. MasterRefillExecutionPanel'deki _UnitDoseBody.cellList()'ten
// çıkarıldı — hangi kartın render edileceğini BİLMİYOR, sadece [itemBuilder]
// çağırıyor. Böylece Sayım/İade kendi kart widget'larını (CountCellCard,
// RefundCellCard) aynı liste↔grid geçiş mantığıyla kullanabiliyor.

import 'package:flutter/material.dart';

class CabinOperationCellGrid extends StatelessWidget {
  const CabinOperationCellGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.singleColumnThreshold = 6,
    this.targetItemWidth = 300,
    this.gap = 12,
    this.minColumns = 1,
    this.maxColumns = 4,
    this.shrinkWrap = false,
    this.physics,
  });

  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;

  /// Bu sayının altında (dahil) tek sütun liste; üstünde genişliğe göre
  /// grid'e geçilir. 0 verilirse hiçbir zaman tek sütun listeye düşmez,
  /// her zaman grid kullanılır (ör. seçim ekranlarındaki kart grid'i).
  final int singleColumnThreshold;

  /// Grid modunda hedeflenen kart genişliği — gerçek genişlik mevcut alana
  /// göre bölünüp hesaplanır, bu sadece sütun sayısını belirlemek için hedef.
  final double targetItemWidth;

  final double gap;

  /// Grid modunda sütun sayısı bu aralıkla sınırlanır.
  final int minColumns;
  final int maxColumns;

  /// Tek sütun liste modunda ListView'a geçilir. Çağıran bu listeyi zaten
  /// yükseklik-kısıtlı bir Expanded/SizedBox içine koyuyorsa false (varsayılan)
  /// bırakılabilir; liste kendi scroll'unu yönetir. Sabit yükseklik yoksa
  /// (ör. bir Column içinde doğrudan) shrinkWrap: true + uygun physics gerekir.
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    if (itemCount <= singleColumnThreshold) {
      return ListView.separated(
        padding: EdgeInsets.zero,
        shrinkWrap: shrinkWrap,
        physics: physics,
        itemCount: itemCount,
        separatorBuilder: (_, _) => SizedBox(height: gap),
        itemBuilder: itemBuilder,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = (constraints.maxWidth / (targetItemWidth + gap)).floor().clamp(minColumns, maxColumns);
        final cardWidth = (constraints.maxWidth - gap * (columns - 1)) / columns;
        final rowCount = (itemCount / columns).ceil();

        return SingleChildScrollView(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var row = 0; row < rowCount; row++) ...[
                if (row != 0) SizedBox(height: gap),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var col = 0; col < columns; col++) ...[
                        if (col != 0) SizedBox(width: gap),
                        Builder(
                          builder: (context) {
                            final index = row * columns + col;
                            if (index >= itemCount) return SizedBox(width: cardWidth);
                            return SizedBox(width: cardWidth, child: itemBuilder(context, index));
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
