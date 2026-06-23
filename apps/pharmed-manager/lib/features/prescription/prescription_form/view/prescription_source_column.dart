part of 'new_prescription_dialog.dart';

class PrescriptionSourceColumn extends StatefulWidget {
  const PrescriptionSourceColumn({super.key});

  @override
  State<PrescriptionSourceColumn> createState() => _PrescriptionSourceColumnState();
}

class _PrescriptionSourceColumnState extends State<PrescriptionSourceColumn> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            indicatorWeight: 1,
            dividerColor: Colors.transparent,
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: [
              Tab(
                child: Text('Geçmiş', style: MedTextStyles.bodyMd().copyWith(fontWeight: FontWeight.bold)),
              ),
              Tab(
                child: Text('Şablonlar', style: MedTextStyles.bodyMd().copyWith(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          Expanded(child: TabBarView(children: [_HistoryTab(), _TemplatesTabPlaceholder()])),
        ],
      ),
    );
  }
}

class _TemplatesTabPlaceholder extends StatelessWidget {
  const _TemplatesTabPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(PhosphorIcons.bookmarksSimple(), size: 32, color: MedColors.text4),
            const SizedBox(height: 12),
            Text(
              'Şablonlar yakında',
              textAlign: TextAlign.center,
              style: MedTextStyles.bodySm(color: MedColors.text3),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryTab extends StatelessWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context) {
    final history = context.watch<PrescriptionHistoryNotifier>();
    final hasPatient = context.watch<PrescriptionFormNotifier>().hasPatient;

    if (!hasPatient) {
      return EmptyStateWidget(
        title: 'Hasta seçin',
        description: 'Geçmiş reçeteleri görmek için önce hasta seçimi yapın',
      );
    }

    return history.isFetching
        ? const Center(child: MedLoadingIndicator())
        : history.items.isEmpty
        ? EmptyStateWidget(title: 'Reçete bulunamadı', description: 'Bu hasta için geçmiş reçete yok')
        : _HistoryList(items: history.items);
  }
}

class _HistoryList extends StatelessWidget {
  const _HistoryList({required this.items});

  final List<PrescriptionItem> items;

  /// Reçete bazında grupla — items prescriptionId'ye göre toplanır.
  Map<int, List<PrescriptionItem>> get _grouped {
    final map = <int, List<PrescriptionItem>>{};
    for (final item in items) {
      final pid = item.prescription?.id;
      if (pid == null) continue;
      map.putIfAbsent(pid, () => []).add(item);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final groups = _grouped.entries.toList()
      ..sort((a, b) {
        final ad = a.value.first.prescription?.prescriptionDate;
        final bd = b.value.first.prescription?.prescriptionDate;
        if (ad == null || bd == null) return 0;
        return bd.compareTo(ad); // yeni → eski
      });

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      shrinkWrap: true,
      itemCount: groups.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final entry = groups[i];
        return _HistoryGroupCard(prescriptionId: entry.key, items: entry.value);
      },
    );
  }
}

class _HistoryGroupCard extends StatefulWidget {
  const _HistoryGroupCard({required this.prescriptionId, required this.items});

  final int prescriptionId;
  final List<PrescriptionItem> items;

  @override
  State<_HistoryGroupCard> createState() => _HistoryGroupCardState();
}

class _HistoryGroupCardState extends State<_HistoryGroupCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final first = widget.items.first;
    final date = first.prescription?.prescriptionDate?.formattedDate ?? '-';
    final doctor = first.doctor?.fullName ?? '-';
    final count = widget.items.length;

    return Container(
      decoration: BoxDecoration(
        color: MedColors.surface,
        border: Border.all(color: MedColors.border),
        borderRadius: MedRadius.mdAll,
        boxShadow: MedShadows.sm,
      ),
      child: Column(
        children: [
          /// Header
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              borderRadius: MedRadius.mdAll,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '#${widget.prescriptionId} - $date',
                          style: MedTextStyles.bodySm(color: MedColors.text, weight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(doctor, style: MedTextStyles.bodySm(color: MedColors.text3)),
                      ],
                    ),
                  ),
                  Icon(
                    _expanded
                        ? PhosphorIcons.caretUp(PhosphorIconsStyle.bold)
                        : PhosphorIcons.caretDown(PhosphorIconsStyle.bold),
                    size: 14,
                    color: MedColors.text4,
                  ),
                ],
              ),
            ),
          ),

          /// İlaç Listesi
          if (_expanded) ...[
            Container(height: 1, color: MedColors.border2),
            SizedBox(height: 12.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ...widget.items.map(
                  (it) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            it.medicine?.name ?? '-',
                            style: MedTextStyles.bodyMd().copyWith(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${(it.dosePiece ?? 0).toStringAsFixed(0)} ${it.medicine?.operationUnit ?? ''}',
                          style: MedTextStyles.bodySm(color: MedColors.text3),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 10),

                /// Reçeteye Ekle
                GestureDetector(
                  onTap: () {
                    context.read<PrescriptionFormNotifier>().importItems(widget.items);
                  },
                  child: Container(
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: MedColors.blue,
                      borderRadius: BorderRadius.only(
                        bottomLeft: MedRadius.mdAll.bottomLeft,
                        bottomRight: MedRadius.mdAll.bottomLeft,
                      ),
                    ),
                    child: Row(
                      spacing: 4.0,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(PhosphorIcons.plus(), size: 16, color: MedColors.blueLight),
                        Text(
                          'Reçeteye Ekle ($count)',
                          style: MedTextStyles.bodyMd().copyWith(
                            color: MedColors.blueLight,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
