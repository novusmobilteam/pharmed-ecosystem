part of 'new_prescription_dialog.dart';

class PrescriptionTemplateView extends StatelessWidget {
  const PrescriptionTemplateView({super.key});

  @override
  Widget build(BuildContext context) {
    final n = context.watch<PrescriptionTemplatesNotifier>();

    if (n.isFetching) return const Center(child: MedLoadingIndicator());
    if (n.templates.isEmpty) {
      return EmptyStateWidget(
        title: context.l10n.prescriptionTemplateEmptyTitle,
        description: context.l10n.prescriptionTemplateEmptyDescription,
      );
    }

    final sorted = [...n.templates]..sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0)); // yeni → eski

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      shrinkWrap: true,
      itemCount: sorted.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _TemplateGroupCard(template: sorted[i]),
    );
  }
}

class _TemplateGroupCard extends StatefulWidget {
  const _TemplateGroupCard({required this.template});

  final PrescriptionTemplate template;

  @override
  State<_TemplateGroupCard> createState() => _TemplateGroupCardState();
}

class _TemplateGroupCardState extends State<_TemplateGroupCard> {
  bool _expanded = false;

  void _toggle() {
    setState(() => _expanded = !_expanded);
    if (_expanded) {
      final id = widget.template.id;
      if (id != null) context.read<PrescriptionTemplatesNotifier>().fetchItems(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.template;
    final id = t.id;
    final notifier = context.watch<PrescriptionTemplatesNotifier>();
    final items = id != null ? notifier.itemsOf(id) : null;
    final loading = id != null && notifier.isLoadingItems(id);

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
              onTap: _toggle,
              borderRadius: MedRadius.mdAll,
              child: Row(
                children: [
                  Icon(PhosphorIcons.bookmarkSimple(), size: 14, color: MedColors.text3),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      t.name ?? '#${t.id ?? '-'}',
                      style: MedTextStyles.bodySm(color: MedColors.text, weight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

          if (_expanded) ...[
            Container(height: 1, color: MedColors.border2),
            const SizedBox(height: 12),
            if (loading)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: MedLoadingIndicator()),
              )
            else if (items == null)
              // Expand edildi, fetch henüz başlamadı (id null kenar durumu)
              const SizedBox.shrink()
            else if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  context.l10n.prescriptionTemplateNoItemsMessage,
                  style: MedTextStyles.bodySm(color: MedColors.text3),
                ),
              )
            else
              _TemplateItemsList(items: items),
          ],
        ],
      ),
    );
  }
}

class _TemplateItemsList extends StatelessWidget {
  const _TemplateItemsList({required this.items});

  final List<PrescriptionTemplateItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...items.map(
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
                  '${(it.dosePiece ?? 0).toStringAsFixed(0)} ${it.medicine?.operationUnitLocalized(context) ?? ''}',
                  style: MedTextStyles.bodySm(color: MedColors.text3),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 10),

        GestureDetector(
          onTap: () {
            final mapped = items.map((e) => e.toPrescriptionItem()).toList();
            context.read<PrescriptionFormNotifier>().importItems(mapped);
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
                  context.l10n.prescriptionAddToRxButton(items.length),
                  style: MedTextStyles.bodyMd().copyWith(color: MedColors.blueLight, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
