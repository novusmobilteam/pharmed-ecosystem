// [SWREQ-PRES-UI-01] Reçete kalem listesini prescriptionId (RxGroupCard) ya
// da gün (RxDayGroupCard) bazında gruplayıp liste olarak gösterir.
//
// Kullanım:
//   RxCarousel(items: allItems)                   // tüm kalemler, reçete bazlı
//   RxCarousel(items: allItems, groupBy: RxGroupBy.day) // gün bazlı
//   RxCarousel(items: pendingItems)               // önceden filtrelenmiş
//   RxCarousel(items: items, emptyVariant: EmptyStateVariant.noData)
//
// Filtreleme bu widget'ın sorumluluğu DEĞİLDİR.
// Caller, gösterilmesini istediği PrescriptionItem listesini geçer.

import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import 'widgets.dart';

/// Kalemlerin hangi başlık altında toplanacağı.
enum RxGroupBy {
  /// Reçete numarası altında (varsayılan).
  prescription,

  /// Gün altında: kalemin uygulama zamanının (yoksa reçete tarihinin) günü.
  /// Yeni gün üstte, gün içinde saate göre sıralı.
  day,
}

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
    this.groupBy = RxGroupBy.prescription,
  });

  final RxGroupBy groupBy;

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

  /// [items]'ı güne göre gruplar. Gün: item.time ?? reçete tarihi.
  List<({DateTime? day, List<PrescriptionItem> items})> _buildDayGroups() {
    DateTime? dayOf(PrescriptionItem i) {
      final d = i.time ?? i.prescription?.prescriptionDate ?? i.prescriptionDate;
      return d == null ? null : DateTime(d.year, d.month, d.day);
    }

    final map = <DateTime?, List<PrescriptionItem>>{};
    for (final item in items) {
      map.putIfAbsent(dayOf(item), () => []).add(item);
    }

    final groups = [
      for (final e in map.entries)
        (
          day: e.key,
          items: e.value
            ..sort((a, b) {
              final ta = a.time, tb = b.time;
              if (ta == null && tb == null) return 0;
              if (ta == null) return 1;
              if (tb == null) return -1;
              return ta.compareTo(tb);
            }),
        ),
    ];
    groups.sort((a, b) {
      if (a.day == null && b.day == null) return 0;
      if (a.day == null) return 1;
      if (b.day == null) return -1;
      return b.day!.compareTo(a.day!);
    });
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return EmptyStateWidget(variant: emptyVariant);
    }

    if (groupBy == RxGroupBy.day) {
      final days = _buildDayGroups();
      // Bugünün grubu varsa o, yoksa en yeni gün açık başlar.
      final today = todayDateOnly();
      final openIndex = days.indexWhere((g) => g.day == today);
      return ListView.separated(
        itemCount: days.length,
        separatorBuilder: (_, _) => const SizedBox(height: MedSpacing.md),
        itemBuilder: (context, index) {
          final group = days[index];
          return RxDayGroupCard(
            day: group.day,
            items: group.items,
            initiallyExpanded: index == (openIndex >= 0 ? openIndex : 0),
          );
        },
      );
    }

    final groups = _buildGroups();

    if (groups.isEmpty) {
      return EmptyStateWidget(variant: emptyVariant);
    }

    return ListView.separated(
      itemCount: groups.length,
      separatorBuilder: (_, _) => SizedBox(height: 6),
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
