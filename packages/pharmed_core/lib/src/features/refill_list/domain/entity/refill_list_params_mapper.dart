// Dolum listesi (/fiilingDetail/fill) kayıt gövdesi. Göz adresi, miktar ve
// SKT kuralı CabinOperationParamsMapper.cellRows'tan gelir — bu dosya yalnızca
// satırları FillingListRefillParams'a çevirir ve her satıra liste kaydının
// id'sini ekler (backend kaydı bu id ile eşleştiriyor). Bir hedef tek bir
// RefillListDetail satırından geldiği için, ürettiği tüm göz satırları aynı
// id'yi taşır.
//
// Saf domain — Flutter bağımsız.
//
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

abstract final class RefillListParamsMapper {
  static List<CabinRefillParams> toParamsForTarget(CabinOperationTarget target) {
    final detailId = target.sourceId;
    assert(detailId != null, 'Dolum listesi dışındaki bir hedef için çağrıldı');
    if (detailId == null) return const [];

    return [
      for (final r in CabinOperationParamsMapper.cellRows(target))
        FillingListRefillParams(
          id: detailId,
          cabinDrawerDetailId: r.detailId,
          quantity: r.quantity ?? 0,
          censusQuantity: r.countQuantity ?? 0,
          miadDate: r.miadDate ?? kEmptyCellMiad,
        ),
    ];
  }
}
