part of 'cabin_fault_view.dart';

class FaultHistoryView extends StatelessWidget {
  const FaultHistoryView({super.key, required this.records});

  final List<CabinFault> records;

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      title: 'Bakım/Arıza Geçmişi',
      child: ListView.builder(
        itemCount: records.length,
        itemBuilder: (BuildContext context, int index) {
          final record = records.elementAt(index);
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: FaultHistoryItem(record: record),
          );
        },
      ),
    );
  }
}

class FaultHistoryItem extends StatelessWidget {
  const FaultHistoryItem({super.key, required this.record});

  final CabinFault record;

  @override
  Widget build(BuildContext context) {
    // Kayıt tamamlanmış mı? (endDate var mı?)
    final bool isResolved = record.endDate != null;
    final status = record.workingStatus ?? CabinWorkingStatus.working;

    return Container(
      decoration: AppDimensions.cardDecoration(context),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 8,
              decoration: BoxDecoration(
                color: isResolved ? Colors.green : status.color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          status.label,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isResolved ? Colors.green : status.color,
                              ),
                        ),
                        if (!isResolved)
                          Badge(
                            label: Text(
                              'Aktif',
                              style: context.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                            backgroundColor: status.color,
                          ),
                        if (isResolved)
                          Badge(
                            label: Text(
                              'Tamamlandı',
                              style: context.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                            backgroundColor: Colors.green,
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _DateRow(
                      label: 'Başlangıç Tarihi:',
                      date: record.startDate?.formattedDate,
                    ),
                    const SizedBox(height: 4),
                    if (record.endDate != null)
                      _DateRow(
                        label: 'Bitiş Tarihi:',
                        date: record.endDate?.formattedDate ?? 'Devam ediyor...',
                        isResolved: isResolved,
                      ),
                    if (record.description != null && record.description!.isNotEmpty) ...[
                      SizedBox(height: 5),
                      Text(
                        record.description!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateRow extends StatelessWidget {
  final String label;
  final String? date;
  final bool isResolved;

  const _DateRow({
    required this.label,
    this.date,
    this.isResolved = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        ),
        const SizedBox(width: 4),
        Text(
          date ?? '-',
          style: TextStyle(
            fontSize: 13,
            color: isResolved ? Colors.black87 : Colors.blueGrey,
          ),
        ),
      ],
    );
  }
}
