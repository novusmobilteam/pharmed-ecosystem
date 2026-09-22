part of 'overview_panel.dart';

// Aktif kabinin çekmece/bölüm listesini gösterir — her satır bir
// DrawerQueueItem'ın durumunu (dolu/düşük/kritik/boş) ve kuyruktaki
// konumunu taşır. Altta, o an işlem gören çekmecenin/gözün konum
// breadcrumb'ı gösterilir.
class CabinLayoutOverviewPanel extends StatelessWidget {
  const CabinLayoutOverviewPanel({super.key, required this.cabin, required this.items});

  final Cabin cabin;
  final List<DrawerQueueItem> items;

  @override
  Widget build(BuildContext context) {
    final activeItem = items.firstWhereOrNull((i) => i.status == DrawerQueueStatus.active);

    return Container(
      padding: MedSpacing.insetXl,
      decoration: MedDecoration.panelDecoration.copyWith(border: Border.all(color: MedColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(cabin.name ?? '', style: MedTextStyles.titleMd())),
              MedChip(
                label: context.l10n.cabinOverview_workingCabinBadge,
                background: MedColors.blueLight,
                foreground: MedColors.blue,
                size: MedChipSize.md,
                showBorder: false,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  for (var i = 0; i < items.length; i++) ...[
                    _DrawerRow(item: items[i]),
                    if (i < items.length - 1) const SizedBox(height: 6),
                  ],
                ],
              ),
            ),
          ),
          if (activeItem != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: MedSpacing.insetMd,
              decoration: BoxDecoration(
                color: MedColors.surface2,
                borderRadius: MedRadius.mdAll,
                border: Border.all(color: MedColors.border),
              ),
              child: Row(
                children: [
                  Text(
                    context.l10n.cabinOverview_locationGuideLabel,
                    style: MedTextStyles.monoXs(color: MedColors.text3),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${cabin.name} › ${activeItem.address}',
                      style: MedTextStyles.monoXs(),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DrawerRow extends StatelessWidget {
  const _DrawerRow({required this.item});
  final DrawerQueueItem item;

  @override
  Widget build(BuildContext context) {
    final (Color border, Color bg, Color text) = switch (item.status) {
      DrawerQueueStatus.active => (MedColors.blue, MedColors.blueLight, MedColors.blue),
      DrawerQueueStatus.completed => (MedColors.green, MedColors.greenLight, MedColors.text),
      DrawerQueueStatus.failed => (MedColors.red, MedColors.redLight, MedColors.text),
      DrawerQueueStatus.pending => (MedColors.border, MedColors.surface, MedColors.text),
      DrawerQueueStatus.notInQueue => (MedColors.border, MedColors.surface2, MedColors.text3),
    };

    final Widget trailing = switch (item.status) {
      DrawerQueueStatus.completed => Icon(
        PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
        size: 16,
        color: MedColors.green,
      ),
      DrawerQueueStatus.failed => Icon(PhosphorIcons.xCircle(PhosphorIconsStyle.fill), size: 16, color: MedColors.red),
      DrawerQueueStatus.active => MedChip(
        label: context.l10n.cabinOverview_activeDrawerBadge,
        background: MedColors.blue,
        foreground: Colors.white,
        size: MedChipSize.sm,
        showBorder: false,
      ),
      _ => const SizedBox.shrink(),
    };

    return Container(
      padding: MedSpacing.insetXl,
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border, width: item.status == DrawerQueueStatus.active ? 1.5 : 1),
        borderRadius: MedRadius.mdAll,
      ),
      child: Row(
        children: [
          _MiniDrawerShape(item: item, accentColor: border),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.address, style: MedTextStyles.titleSm(color: text)),
                Text(
                  item.isKubik
                      ? context.l10n.cabinOverview_cubicDrawerSubtitle
                      : context.l10n.cabinOverview_unitDoseDrawerSubtitle,
                  style: MedTextStyles.monoXs(color: MedColors.text3),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

/// Satırın solunda, çekmecenin fiziksel tipini şematik olarak özetleyen
/// çok küçük bir görsel — kübikte bir grid, birim dozda göz sayısı kadar
/// yan yana dikdörtgen. DrawerLayoutOverviewPanel'in (aktif göz odaklı,
/// büyük) aksine burada TEK amaç "bu ne tip çekmece, kaç gözü var"
/// bilgisini satır seviyesinde vermek — hangi hücrenin aktif olduğunu
/// göstermez, o bilgi zaten büyük panelde var.
class _MiniDrawerShape extends StatelessWidget {
  const _MiniDrawerShape({required this.item, required this.accentColor});

  final DrawerQueueItem item;
  final Color accentColor;

  static const double _boxSize = 32;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: _boxSize, height: _boxSize, child: item.isKubik ? _kubikGrid() : _unitDoseRow());
  }

  Widget _kubikGrid() {
    final cellCount = item.units.length > 0 ? item.units.length : 16;
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: cellCount,
      itemBuilder: (context, i) => Container(
        decoration: BoxDecoration(
          color: accentColor.withAlpha(60),
          border: Border.all(color: accentColor, width: 0.5),
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }

  Widget _unitDoseRow() {
    final unitCount = item.units.isNotEmpty ? item.units.length : 1;
    return Row(
      spacing: 2,
      children: List.generate(
        unitCount,
        (i) => Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: accentColor.withAlpha(60),
              border: Border.all(color: accentColor, width: 0.5),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ),
      ),
    );
  }
}
