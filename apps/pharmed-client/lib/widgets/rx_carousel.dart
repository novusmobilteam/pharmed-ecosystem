// [SWREQ-PRES-UI-01] Reçete kalem listesini prescriptionId bazında gruplar,
// RxGroupCard'larla carousel olarak gösterir.
//
// Kullanım:
//   RxCarousel(items: allItems)                   // tüm kalemler
//   RxCarousel(items: pendingItems)               // önceden filtrelenmiş
//   RxCarousel(items: items, emptyVariant: EmptyStateVariant.noData)
//
// Filtreleme bu widget'ın sorumluluğu DEĞİLDİR.
// Caller, gösterilmesini istediği PrescriptionItem listesini geçer.

import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import 'widgets.dart';

/// Reçete kalemlerini prescriptionId bazında gruplandırıp
/// [RxGroupCard] listesi olarak gösteren carousel widget'ı.
///
/// Widget filtreleme yapmaz; [items] olduğu gibi gruplandırılır.
/// Filtre uygulayarak çağırmak caller'ın sorumluluğundadır.
class RxCarousel extends StatelessWidget {
  const RxCarousel({
    super.key,
    required this.items,
    this.emptyVariant = EmptyStateVariant.error,
    this.padding = const EdgeInsets.all(MedSpacing.xl4),
    this.itemSpacing = MedSpacing.xl2,
  });

  /// Gösterilecek reçete kalemleri.
  /// Boş geçilirse [emptyVariant]'a göre boş durum widget'ı gösterilir.
  final List<PrescriptionItem> items;

  /// Liste boşken gösterilecek empty-state varyantı.
  final EmptyStateVariant emptyVariant;

  /// ListView padding'i. Default: [MedSpacing.xl4] (32px) her yönde.
  final EdgeInsetsGeometry padding;

  /// Kartlar arası dikey boşluk. Default: [MedSpacing.xl2] (20px).
  final double itemSpacing;

  /// [items]'ı prescriptionId bazında gruplar.
  ///
  /// - [Prescription] nesnesi ilgili item'dan alınır; yoksa id ile stub oluşturulur.
  /// - Sıralama: prescriptionDate descending (en yeni üstte).
  List<({Prescription prescription, List<PrescriptionItem> items})> _buildGroups() {
    final map = <int, ({Prescription prescription, List<PrescriptionItem> items})>{};

    for (final item in items) {
      final id = item.prescriptionId;
      if (id == null) continue;

      if (map.containsKey(id)) {
        map[id] = (prescription: map[id]!.prescription, items: [...map[id]!.items, item]);
      } else {
        final prescription = item.prescription ?? Prescription(id: id, prescriptionDate: item.prescriptionDate);
        map[id] = (prescription: prescription, items: [item]);
      }
    }

    final sorted = map.values.toList()
      ..sort((a, b) {
        final dateA = a.prescription.prescriptionDate;
        final dateB = b.prescription.prescriptionDate;
        if (dateA == null && dateB == null) return 0;
        if (dateA == null) return 1;
        if (dateB == null) return -1;
        return dateB.compareTo(dateA);
      });

    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return EmptyStateWidget(variant: emptyVariant);
    }

    final groups = _buildGroups();

    if (groups.isEmpty) {
      return EmptyStateWidget(variant: emptyVariant);
    }

    return ListView.separated(
      itemCount: groups.length,
      separatorBuilder: (_, _) => SizedBox(height: itemSpacing),
      itemBuilder: (context, index) {
        final group = groups[index];
        return RxGroupCard(
          prescription: group.prescription,
          items: group.items,
          // Yalnızca ilk kart başlangıçta açık
          initiallyExpanded: index == 0,
        );
      },
    );
  }
}
