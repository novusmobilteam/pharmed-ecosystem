part of 'cabin_design_dialog.dart';

class _CabinListPanel extends StatelessWidget {
  const _CabinListPanel({
    required this.cabins,
    required this.selectedCabinId,
    required this.onCabinTap,
    required this.onAddCabinTap,
  });

  final List<Cabin> cabins;
  final int? selectedCabinId;
  final ValueChanged<int> onCabinTap;
  final VoidCallback onAddCabinTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: MedColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: MedSpacing.insetXl * 1.5,
            child: Row(
              children: [
                Text(
                  context.l10n.cabinDesign_cabinList_sectionTitle,
                  style: MedTextStyles.titleSm(color: MedColors.text3),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: MedColors.surface3, borderRadius: MedRadius.smAll),
                  child: Text(
                    context.l10n.cabinDesign_cabinList_countBadge(cabins.length),
                    style: MedTextStyles.monoSm(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: MedSpacing.insetXl.left * 1.5),
              itemCount: cabins.length,
              separatorBuilder: (_, _) => const SizedBox(height: MedSpacing.xs),
              itemBuilder: (_, i) {
                final cabin = cabins[i];
                final id = cabin.id;
                return _CabinListItem(
                  cabin: cabin,
                  isSelected: id != null && id == selectedCabinId,
                  onTap: id != null ? () => onCabinTap(id) : null,
                );
              },
            ),
          ),

          Padding(
            padding: MedSpacing.insetXl * 1.5,
            child: MedButton(
              fullWidth: true,
              label: context.l10n.cabinDesign_cabinList_addCabinButton,
              prefixIcon: Icon(PhosphorIcons.plus()),
              onPressed: onAddCabinTap,
              variant: MedButtonVariant.secondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _CabinListItem extends StatelessWidget {
  const _CabinListItem({required this.cabin, required this.isSelected, required this.onTap});

  final Cabin cabin;
  final bool isSelected;
  final VoidCallback? onTap;

  bool get _isPassive => cabin.status == Status.passive;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: MedSpacing.insetXl,
        decoration: BoxDecoration(
          color: isSelected ? MedColors.blueLight : MedColors.surface,
          border: Border.all(color: isSelected ? MedColors.blue : MedColors.border2),
          borderRadius: MedRadius.mdAll,
        ),
        child: Row(
          spacing: 12.0,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // TODO: canlı bağlantı durumu henüz bağlanmadı (donanım probu
                // gerektiriyor — "Cihazı Tara" akışıyla birlikte ele alınacak).
                // Şimdilik sadece pasif/aktif ayrımı gösteriliyor.
                color: _isPassive ? MedColors.text4 : MedColors.green,
              ),
            ),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          cabin.name ?? '—',
                          style: MedTextStyles.bodyLg(color: MedColors.text).copyWith(fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (_isPassive) ...[
                        const SizedBox(width: MedSpacing.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: MedColors.text4, borderRadius: MedRadius.smAll),
                          child: Text(
                            context.l10n.cabinDesign_cabinList_passiveBadge.toUpperCase(),
                            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (cabin.type != null) Text(cabin.type!.label, style: MedTextStyles.bodyMd(color: MedColors.text3)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
