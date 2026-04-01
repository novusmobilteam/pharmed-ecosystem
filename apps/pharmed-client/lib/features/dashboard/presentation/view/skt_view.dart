part of 'dashboard_screen.dart';

class SktView extends StatelessWidget {
  const SktView({super.key, required this.skt, required this.isStale});

  final List<CabinStock> skt;
  final bool isStale;

  @override
  Widget build(BuildContext context) {
    final items = skt.map((stock) {
      return SktItem(
        medicineName: stock.medicine?.name ?? '—',
        detail: [
          //stock.assignment?.cabin?.name,
          if (stock.quantity != null) '${stock.quantity} ${stock.assignment?.operationUnit ?? ''}',
          //if (stock.lotNumber != null) 'Lot: ${stock.lotNumber}',
        ].join(' · '),
        status: stock.sktStatus,
        daysRemaining: stock.remainingDay,
      );
    }).toList();

    return SktList(items: items, isStale: isStale);
  }
}
