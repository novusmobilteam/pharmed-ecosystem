import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

/// Master kabinin fiziksel görünümü — HMI ekran şeridi + çekmece kartları
/// yığını şeklinde bir "cihaz kabuğu" render eder.
///
/// SADECE CabinType.master için kullanılır — çağıran taraf bu kontrolü
/// yapmalıdır (widget kendi içinde tip kontrolü yapmaz).
///
/// İki kullanım modu:
/// - Kabin dizaynı: [onSlotTap] verilir, her çekmece kartı ayrı ayrı
///   tıklanabilir olur, [selectedSlotId] ile seçili çekmece mavi border
///   ile vurgulanır. [onCabinTap]/[isWholeCabinSelected] kullanılmaz.
/// - Kabin seçim ekranı (operasyon öncesi): [onSlotTap] null bırakılır
///   (çekmece kartları tıklanamaz hale gelir), bunun yerine [onCabinTap] +
///   [isWholeCabinSelected] ile TÜM widget'ın etrafına ince bir border
///   basılır.
///
/// Serum çekmeceleri şimdilik detaylı grid yerine placeholder olarak
/// gösterilir — iç tasarımına henüz karar verilmedi.
class MasterCabinDeviceVisual extends StatelessWidget {
  const MasterCabinDeviceVisual({
    super.key,
    required this.groups,
    this.selectedSlotId,
    this.onSlotTap,
    this.isWholeCabinSelected = false,
    this.onCabinTap,
    this.isMaster = false,
  });

  final List<DrawerGroup> groups;
  final int? selectedSlotId;
  final ValueChanged<DrawerGroup>? onSlotTap;
  final bool isWholeCabinSelected;
  final VoidCallback? onCabinTap;
  final bool isMaster;

  static const int _kubikColumnCount = 4;
  static const double _cellSpacing = 4;

  @override
  Widget build(BuildContext context) {
    final shell = Container(
      padding: MedSpacing.insetXl,
      decoration: BoxDecoration(
        color: MedColors.surface3,
        borderRadius: MedRadius.mdAll,
        border: Border.all(
          color: isWholeCabinSelected ? MedColors.blue : MedColors.border,
          width: isWholeCabinSelected ? 3 : 1,
        ),
        boxShadow: MedShadows.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isMaster) const _HmiScreenStrip(),
          const SizedBox(height: MedSpacing.lg),
          for (final group in groups) ...[
            _DrawerFaceCard(
              group: group,
              isSelected: onSlotTap != null && group.slot.id == selectedSlotId,
              onTap: onSlotTap != null ? () => onSlotTap!(group) : null,
              kubikColumnCount: _kubikColumnCount,
              cellSpacing: _cellSpacing,
            ),
            if (group != groups.last) const SizedBox(height: MedSpacing.md),
          ],
        ],
      ),
    );

    if (onCabinTap == null) return shell;

    return GestureDetector(onTap: onCabinTap, child: shell);
  }
}

class _HmiScreenStrip extends StatelessWidget {
  const _HmiScreenStrip();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 86,
      padding: MedSpacing.insetMd,
      decoration: BoxDecoration(color: MedColors.text, borderRadius: MedRadius.mdAll),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _ProgressBarSegment(widthFraction: 0.65, color: MedColors.blue),
                SizedBox(height: 4),
                _ProgressBarSegment(widthFraction: 0.35, color: MedColors.text3),
              ],
            ),
          ),
          const SizedBox(width: MedSpacing.sm),
          Text(
            'HMI',
            textAlign: TextAlign.right,
            style: MedTextStyles.monoSm(weight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _ProgressBarSegment extends StatelessWidget {
  const _ProgressBarSegment({required this.widthFraction, required this.color});

  final double widthFraction;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Container(
        height: 5,
        width: constraints.maxWidth * widthFraction,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
      ),
    );
  }
}

class _DrawerFaceCard extends StatelessWidget {
  const _DrawerFaceCard({
    required this.group,
    required this.isSelected,
    required this.onTap,
    required this.kubikColumnCount,
    required this.cellSpacing,
  });

  final DrawerGroup group;
  final bool isSelected;
  final VoidCallback? onTap;
  final int kubikColumnCount;
  final double cellSpacing;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: MedSpacing.insetMd,
        decoration: BoxDecoration(
          color: MedColors.surface,
          borderRadius: MedRadius.mdAll,
          border: Border.all(color: isSelected ? MedColors.blue : MedColors.border2, width: isSelected ? 2 : 1),
          boxShadow: MedShadows.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _typeLabel(context),
              style: MedTextStyles.bodyMd(color: MedColors.text3, weight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: MedSpacing.sm),
            if (group.isSerum)
              _SerumPlaceholder()
            else if (group.isKubik)
              _KubikPreviewGrid(
                compartmentCount: group.compartmentCount,
                columnCount: kubikColumnCount,
                spacing: cellSpacing,
                isReturnDrawer: group.isReturnDrawer,
              )
            else
              _UnitDosePreviewRow(compartmentCount: group.compartmentCount, spacing: cellSpacing),
            const SizedBox(height: MedSpacing.sm),
            Center(
              child: Container(
                height: 3,
                width: 40,
                decoration: BoxDecoration(color: MedColors.border, borderRadius: BorderRadius.circular(2)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _typeLabel(BuildContext context) {
    if (group.isSerum) return context.l10n.enumCore_cabinTypeSerum;
    if (group.isKubik) {
      final rowCount = (group.compartmentCount / kubikColumnCount).ceil();
      return context.l10n.cabinDesign_detail_typeKubik(kubikColumnCount, rowCount);
    }
    return context.l10n.cabin_unitDoseTypeLabel;
  }
}

class _KubikPreviewGrid extends StatelessWidget {
  const _KubikPreviewGrid({
    required this.compartmentCount,
    required this.columnCount,
    required this.spacing,
    this.isReturnDrawer = false,
  });

  final int compartmentCount;
  final int columnCount;
  final double spacing;

  /// true → son sütun tek tek gözler yerine, tam yükseklikte birleşik TEK
  /// bir kutu olarak çizilir (fiziksel iade kutusu — CabinOverviewExecutionPanel
  /// içindeki _KubikGrid ile aynı görsel mantık, önizleme boyutuna uyarlanmış).
  final bool isReturnDrawer;

  static const double _cellExtent = 50;

  @override
  Widget build(BuildContext context) {
    if (!isReturnDrawer) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columnCount,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          mainAxisExtent: _cellExtent,
        ),
        itemCount: compartmentCount,
        itemBuilder: (_, __) => Container(
          decoration: BoxDecoration(
            color: MedColors.surface2,
            border: Border.all(color: MedColors.border2),
            borderRadius: MedRadius.smAll,
          ),
        ),
      );
    }

    // İade çekmecesi: son sütun tek fiziksel kutu — geri kalan gözler
    // normal grid'de, (columnCount - 1) sütunlu.
    final normalColumnCount = (columnCount - 1).clamp(1, columnCount);
    // Basitleştirilmiş varsayım: fiziksel iade kutusu her zaman TEK sütun
    // yüksekliği kadar (satır sayısı) yer kaplar — normal gözler geri kalanı.
    final rowCount = (compartmentCount / columnCount).ceil();
    final normalCount = compartmentCount - rowCount; // her satırdan 1 hücre iade kutusuna gider
    final gridHeight = rowCount * _cellExtent + (rowCount - 1) * spacing;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: normalColumnCount,
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: normalColumnCount,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
              mainAxisExtent: _cellExtent,
            ),
            itemCount: normalCount,
            itemBuilder: (_, _) => Container(
              decoration: BoxDecoration(
                color: MedColors.surface2,
                border: Border.all(color: MedColors.border2),
                borderRadius: MedRadius.smAll,
              ),
            ),
          ),
        ),
        SizedBox(width: spacing),
        Expanded(
          flex: 1,
          child: SizedBox(
            height: gridHeight,
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: MedColors.amberLight,
                border: Border.all(color: MedColors.amber, width: 1.5),
                borderRadius: MedRadius.smAll,
              ),
              child: Text(context.l10n.cabinDesign_returnBadge, style: MedTextStyles.monoSm(color: MedColors.amber)),
            ),
          ),
        ),
      ],
    );
  }
}

class _UnitDosePreviewRow extends StatelessWidget {
  const _UnitDosePreviewRow({required this.compartmentCount, required this.spacing});

  final int compartmentCount;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Row(
        spacing: spacing,
        children: List.generate(
          compartmentCount,
          (_) => Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: MedColors.surface2,
                border: Border.all(color: MedColors.border2),
                borderRadius: MedRadius.smAll,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SerumPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: MedColors.surface2,
        border: Border.all(color: MedColors.border2),
        borderRadius: MedRadius.smAll,
      ),
      child: Text(context.l10n.enumCore_cabinTypeSerum, style: MedTextStyles.bodySm(color: MedColors.text4)),
    );
  }
}
