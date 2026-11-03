import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

part 'cabin_type_master.dart';
part 'cabin_type_cabinet.dart';
part 'cabin_type_freezer.dart';
part 'cabin_type_open_cabinet.dart';
part 'cabin_type_serum.dart';
part 'cabin_type_open.dart';

// Bir kabinin TİPİNE göre (Master/Cabinet/Freezer/OpenCabinet/OpenCabin/
// Serum) şematik, küçültülmüş bir görsel çizen referans kart. Gerçek
// kabin dizaynı ekranındaki büyük/detaylı görsellerin YERİNE geçmez —
// bu, dar alanlarda (execution ekranının kabin şeridi, seçim ekranlarının
// kabin şeridi gibi) "bu hangi tip kabin, hangisi bu" bilgisini bir bakışta
// verecek kadar sade bir özet.
//
// Tüm tip çizimleri aynı görsel dili paylaşır (_CabinBody: gövde + ayaklar,
// _Handle: kol, _Led: durum ışığı) ve yalnızca flex/oranla ölçeklenir —
// sabit piksel yükseklik kullanılmaz, böylece 120×170'ten 170×250'ye her
// boyutta taşma olmaz.
//
// isActive true iken kart mavi border + açık mavi zeminle vurgulanır; false
// iken (dimWhenInactive true ise) soluk (opacity 0.5) "şu an pasif, sadece
// bilgi amaçlı" görünümü alır. Kabin tipi ne olursa olsun bu vurgu mantığı
// ORTAK — sarmalayıcı bu ikiliği tek noktadan uygular.
class CabinTypeReferenceView extends StatelessWidget {
  const CabinTypeReferenceView({
    super.key,
    required this.cabin,
    this.isActive = false,
    this.width = 170,
    this.height = 250,
    this.dimWhenInactive = true,
  });

  /// Adı, tipi (CabinType) ve altta gösterilecek etiket bilgisini taşıyan
  /// domain nesnesi. Fiziksel çekmece/göz detayına inmez — o detay her
  /// tipin kendi çiziminde statik/şematik olarak çizilir, cabin'den
  /// TÜRETİLMEZ.
  final Cabin cabin;

  /// Bu kabin şu an işlem gören / görüntülenen kabin mi.
  final bool isActive;

  /// Kartın toplam genişliği/yüksekliği — varsayılan (170x250) tek kart
  /// gösterimi için, StationCabinsOverview gibi çok-kabinli şeritlerde
  /// mevcut alana göre hesaplanıp geçirilir.
  final double width;
  final double height;

  /// false iken pasif kart soluklaştırılmaz — seçim ekranının kabin
  /// şeridinde tüm kabinler seçilebilir olduğu için yalnızca border vurgusu
  /// kullanılır.
  final bool dimWhenInactive;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isActive || !dimWhenInactive ? 1.0 : 0.5,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: isActive ? MedColors.blueLight : MedColors.surface,
          borderRadius: MedRadius.lgAll,
          boxShadow: isActive ? null : MedShadows.sm,
          border: Border.all(color: isActive ? MedColors.blue : MedColors.border, width: isActive ? 2.0 : 1.0),
        ),
        padding: MedSpacing.insetSm,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Center(
                // Kabinler dikey dikdörtgendir — dar/uzun alanda da oran korunur.
                child: AspectRatio(aspectRatio: _aspectRatio, child: _typeView()),
              ),
            ),
            const SizedBox(height: MedSpacing.md),
            Text(
              cabin.name ?? '—',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: MedTextStyles.bodyMd(
                color: isActive ? MedColors.blueDark : MedColors.text,
                weight: FontWeight.bold,
              ),
            ),
            if (cabin.type != null)
              Text(
                cabin.type!.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: MedTextStyles.bodySm(color: MedColors.text3),
              ),
          ],
        ),
      ),
    );
  }

  /// Genişlik / yükseklik. Açık raflar ve serum biraz daha geniş durur.
  double get _aspectRatio => switch (cabin.type) {
    CabinType.openCabin || CabinType.openCabinet => 0.78,
    CabinType.serum => 0.72,
    _ => 0.62,
  };

  /// cabin.type'a göre doğru şematik görseli seçer. Bilinmeyen/null tip
  /// için CabinTypeMaster'a düşer (görsel olarak "boş" göstermemek için
  /// bir varsayılan gerekiyordu — yeni bir CabinType eklenip buraya
  /// karşılığı unutulursa sessizce Master gibi görünür).
  Widget _typeView() {
    switch (cabin.type) {
      case CabinType.master:
        return const CabinTypeMaster();
      case CabinType.cabinet:
        return const CabinTypeCabinet();
      case CabinType.freezer:
        return const CabinTypeFreezer();
      case CabinType.openCabinet:
        return const CabinTypeOpenCabinet();
      case CabinType.openCabin:
        return const CabinTypeOpen();
      case CabinType.serum:
        return const CabinTypeSerum();
      default:
        return const CabinTypeMaster();
    }
  }
}

// ── Ortak çizim parçaları ────────────────────────────────────────────────

/// Kabin gövdesi: hafif gradyanlı dış kasa + iç çerçeve + iki ayak.
/// [tint] verilirse gövde o renge çalar (ör. buzdolabı mavisi).
class _CabinBody extends StatelessWidget {
  const _CabinBody({required this.child, this.tint, this.innerPadding = 4.0});

  final Widget child;
  final Color? tint;
  final double innerPadding;

  @override
  Widget build(BuildContext context) {
    final edge = tint ?? MedColors.cabinBorder;
    final top = tint == null ? MedColors.cabinBg : Color.alphaBlend(tint!.withAlpha(30), MedColors.surface);
    final bottom = tint == null ? MedColors.cabinInner : Color.alphaBlend(tint!.withAlpha(55), MedColors.surface);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.all(innerPadding),
            decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [top, bottom]),
              borderRadius: MedRadius.mdAll,
              border: Border.all(color: edge, width: 1.2),
            ),
            child: child,
          ),
        ),
        // Ayaklar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_foot(edge), _foot(edge)]),
        ),
      ],
    );
  }

  Widget _foot(Color color) => Container(
    width: 10,
    height: 4,
    decoration: BoxDecoration(
      color: color,
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(2)),
    ),
  );
}

/// İç panel (kapak/çekmece/kapı yüzü).
BoxDecoration _faceDecoration({Color? color, Color? border}) => BoxDecoration(
  color: color ?? MedColors.surface,
  borderRadius: MedRadius.smAll,
  border: Border.all(color: border ?? MedColors.cabinBorder, width: 0.8),
);

/// Kol. [vertical] true → dikey çubuk (kapı), false → yatay çubuk (çekmece).
class _Handle extends StatelessWidget {
  const _Handle({this.vertical = false, this.color});

  final bool vertical;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: vertical ? null : 0.32,
      heightFactor: vertical ? 0.28 : null,
      child: Container(
        width: vertical ? 3 : null,
        height: vertical ? null : 3,
        decoration: BoxDecoration(color: color ?? MedColors.text3, borderRadius: MedRadius.smAll),
      ),
    );
  }
}

/// Küçük durum ışığı.
class _Led extends StatelessWidget {
  const _Led({this.color = MedColors.ledGreen});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 5,
      height: 5,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color.withAlpha(110), blurRadius: 3)],
      ),
    );
  }
}
