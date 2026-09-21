import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import 'cabin_type_reference_view.dart';

// Bir istasyondaki TÜM fiziksel kabinleri, hangisinin şu an aktif işlem
// gördüğünü belirterek yan yana (Wrap ile) gösteren şerit.
//
// Aktif kabin — hem listenin BAŞINA alınır (öne çıkarma) hem de
// CabinTypeReferenceView'a isActive:true geçilerek görsel olarak
// vurgulanır (kalın/mavi border + tam opaklık). Diğer tüm kabinler soluk
// (opacity 0.5) ve normal border ile "pasif, bilgi amaçlı" görünür.
//
// Master intake execution ekranında, o an işlem yapılan job'ın
// (IntakeDrawerJob.cabinId) hangi kabine ait olduğunu göstermek için
// kullanılır — alım farklı kabinlerden sırayla yapılabildiği için
// kullanıcı her adımda "şu an hangi kabindeyim" bilgisini buradan alır.
class StationCabinsOverview extends StatelessWidget {
  const StationCabinsOverview({super.key, required this.cabins, required this.activeCabinId});

  /// İstasyonda tanımlı tüm fiziksel kabinler (aktif olan da dahil, bu
  /// listenin bir alt kümesi değil — tam liste).
  final List<Cabin> cabins;

  /// O an işlem yapılan kabinin id'si. null ise (örn. henüz kuyruk
  /// başlamadıysa) hiçbir kabin öne çıkarılmaz/vurgulanmaz.
  final int? activeCabinId;

  static const double _spacing = 12.0;
  static const double _minCardWidth = 120.0;
  static const double _maxCardWidth = 150.0;
  static const double _cardHeight = 220.0;

  /// Aynı anda gösterilecek en fazla kabin sayısı — daha fazlası varsa,
  /// aktif kabini İÇEREN bir pencereye daraltılır (kaydırma yerine).
  static const int _maxVisible = 4;

  /// [cabins]'in orijinal sırasını KORUYARAK, en fazla [_maxVisible]
  /// genişliğinde, aktif kabini mutlaka içeren ardışık bir alt liste döner.
  /// Aktif kabin yoksa (activeCabinId null/eşleşmiyor) baştan [_maxVisible]
  /// kadarını döner.
  List<Cabin> _visibleWindow() {
    if (cabins.length <= _maxVisible) return cabins;

    final activeIndex = cabins.indexWhere((c) => c.id == activeCabinId);
    if (activeIndex < 0) return cabins.take(_maxVisible).toList();

    // Aktif kabini mümkünse pencerenin ortasına yakın tut.
    var start = activeIndex - (_maxVisible ~/ 2);
    start = start.clamp(0, cabins.length - _maxVisible);
    return cabins.sublist(start, start + _maxVisible);
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visibleWindow();
    if (visible.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final count = visible.length;
        final totalSpacing = _spacing * (count - 1);
        final evenWidth = (constraints.maxWidth - totalSpacing) / count;
        final cardWidth = evenWidth.clamp(_minCardWidth, _maxCardWidth);

        // count her zaman <= _maxVisible olduğundan minCardWidth'in altına
        // düşme (kaydırma gerektiren) senaryosu artık olmamalı — evenWidth
        // zaten _maxVisible'a göre yeterince geniş kalır. Yine de savunma
        // amaçlı clamp bırakıyoruz.
        final rowWidth = cardWidth * count + totalSpacing;

        return SizedBox(
          height: _cardHeight,
          child: SizedBox(
            width: rowWidth,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < count; i++) ...[
                  CabinTypeReferenceView(
                    cabin: visible[i],
                    isActive: visible[i].id == activeCabinId,
                    width: cardWidth,
                    height: _cardHeight,
                  ),
                  if (i < count - 1) const SizedBox(width: _spacing),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
