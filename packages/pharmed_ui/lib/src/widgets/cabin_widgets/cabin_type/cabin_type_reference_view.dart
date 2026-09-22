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
// bu, dar alanlarda (execution ekranının kabin şeridi gibi) "bu hangi tip
// kabin, hangisi bu" bilgisini bir bakışta verecek kadar sade bir özet.
//
// isActive true iken kart kalın/mavi border ve tam opaklıkla vurgulanır;
// false iken soluk (opacity 0.5) ve normal border ile "şu an pasif, sadece
// bilgi amaçlı burada duruyor" görünümü alır. Kabin tipi ne olursa olsun
// bu vurgu mantığı ORTAK — her _typeView() implementasyonu kendi çizimine
// bakmadan, sarmalayıcı bu ikiliği tek noktadan uygular.
class CabinTypeReferenceView extends StatelessWidget {
  const CabinTypeReferenceView({
    super.key,
    required this.cabin,
    this.isActive = false,
    this.width = 170,
    this.height = 250,
  });

  /// Adı, tipi (CabinType) ve altta gösterilecek etiket bilgisini taşıyan
  /// domain nesnesi. Fiziksel çekmece/göz detayına inmez — o detay her
  /// tipin kendi _typeView() widget'ında (CabinTypeMaster vb.) statik/
  /// şematik olarak çizilir, cabin'den TÜRETİLMEZ.
  final Cabin cabin;

  /// Bu kabin şu an işlem gören (aktif job'un ait olduğu) kabin mi.
  final bool isActive;

  /// Kartın toplam genişliği/yüksekliği — varsayılan (170x250) tek kart
  /// gösterimi için, StationCabinsOverview gibi çok-kabinli şeritlerde
  /// mevcut alana göre hesaplanıp geçirilir.
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isActive ? 1.0 : 0.5,
      child: Container(
        height: height,
        width: width,
        alignment: Alignment.center,
        decoration: MedDecoration.panelDecoration.copyWith(
          borderRadius: MedRadius.mdAll,
          border: Border.all(color: isActive ? MedColors.blue : MedColors.border, width: isActive ? 2.0 : 1.0),
        ),
        padding: MedSpacing.insetMd,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(child: _typeView()),
            SizedBox(height: 8.0),
            if (cabin.name != null) Text(cabin.name!, style: MedTextStyles.monoMd()),
            if (cabin.type != null) Text(cabin.type!.label, style: MedTextStyles.bodySm()),
          ],
        ),
      ),
    );
  }

  /// cabin.type'a göre doğru şematik görseli seçer. Bilinmeyen/null tip
  /// için CabinTypeMaster'a düşer (görsel olarak "boş" göstermemek için
  /// bir varsayılan gerekiyordu — yeni bir CabinType eklenip buraya
  /// karşılığı unutulursa sessizce Master gibi görünür, bunu bilerek not
  /// düşüyorum).
  Widget _typeView() {
    switch (cabin.type) {
      case CabinType.master:
        return CabinTypeMaster();
      case CabinType.cabinet:
        return CabinTypeCabinet();
      case CabinType.freezer:
        return CabinTypeFreezer();
      case CabinType.openCabinet:
        return CabinTypeOpenCabinet();
      case CabinType.openCabin:
        return CabinTypeOpen();
      case CabinType.serum:
        return CabinTypeSerum();
      default:
        return CabinTypeMaster();
    }
  }
}
