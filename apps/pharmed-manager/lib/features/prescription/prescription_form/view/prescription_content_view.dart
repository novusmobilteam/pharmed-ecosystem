part of 'new_prescription_dialog.dart';

class PrescriptionContentView extends StatelessWidget {
  const PrescriptionContentView({super.key});

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<PrescriptionFormNotifier>();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MedButton(
            label: 'Ekle',
            variant: MedButtonVariant.secondary,
            prefixIcon: Icon(PhosphorIcons.plus()),
            onPressed: notifier.addEmptyItem,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: notifier.items.isEmpty
                ? EmptyStateWidget(
                    title: 'Reçeteye henüz ilaç eklemediniz.',
                    description: 'Eklediğiniz ilaçlar burada görüntülenecektir.',
                  )
                : ListView.separated(
                    itemCount: notifier.items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 6),
                    itemBuilder: (_, i) => _ItemCard(index: i),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({required this.index});

  final int index;

  String _timesSummary(List<DateTime>? times) {
    if (times == null || times.isEmpty) return 'Saat eklenmedi';
    final first = times.first.toTimeOfDay;
    final firstStr = first != null
        ? '${first.hour.toString().padLeft(2, '0')}:${first.minute.toString().padLeft(2, '0')}'
        : '-';
    if (times.length == 1) return firstStr;
    return '$firstStr · +${times.length - 1}';
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<PrescriptionFormNotifier>();
    final item = notifier.items[index];
    final isSelected = notifier.selectedIndex == index;
    final isValid = notifier.isItemValid(item);

    Color borderColor;
    Color bgColor;
    if (isSelected) {
      borderColor = MedColors.blue;
      bgColor = MedColors.blueLight;
    } else if (!isValid) {
      borderColor = MedColors.amber;
      bgColor = MedColors.surface;
      bgColor = MedColors.amberLight;
    } else {
      borderColor = MedColors.border;
      bgColor = MedColors.surface;
    }

    return InkWell(
      onTap: () => notifier.selectItem(index),
      borderRadius: MedRadius.mdAll,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor),
          borderRadius: MedRadius.mdAll,
          boxShadow: MedShadows.sm,
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: borderColor, shape: BoxShape.circle),
              child: Text('${index + 1}', style: MedTextStyles.bodySm(color: Colors.white)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.medicine?.name ?? 'Henüz ilaç seçilmedi',
                    style: MedTextStyles.bodyLg(
                      weight: FontWeight.w600,
                      color: item.medicine == null ? MedColors.text3 : MedColors.text,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        '${(item.dosePiece ?? 0).toStringAsFixed(0)} ${item.medicine?.operationUnit ?? 'ad'}',
                        style: MedTextStyles.monoSm(color: MedColors.text2),
                      ),
                      Text('·', style: MedTextStyles.monoSm(color: MedColors.text4)),
                      Text(item.requestType?.label ?? '-', style: MedTextStyles.monoSm(color: MedColors.text2)),
                      Text('·', style: MedTextStyles.monoSm(color: MedColors.text4)),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(PhosphorIcons.clock(), size: 11, color: MedColors.text3),
                          const SizedBox(width: 4),
                          Text(_timesSummary(item.times), style: MedTextStyles.monoSm(color: MedColors.text2)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () => notifier.removeItemAt(index),
              borderRadius: MedRadius.mdAll,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Icon(PhosphorIcons.xCircle(), size: 22, color: borderColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
