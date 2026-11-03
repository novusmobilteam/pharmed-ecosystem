// [SWREQ-UI-STATIONSCOPE-001] [IEC 62304 §5.5]
//
// İstasyon geneli seçim ekranlarının sol paneli: üstte istasyondaki tüm
// kabinlerin mini görselleri (kabin şeridi), altta görüntülenen kabinin iç
// yerleşimi. Kabine dokunmak yalnızca hangi kabinin iç yerleşiminin
// gösterileceğini değiştirir — seçim kabinler arası korunur. Rozet, o
// kabinde seçili kalem sayısını gösterir.
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

class StationCabinSelectionPanel extends StatelessWidget {
  const StationCabinSelectionPanel({
    super.key,
    required this.cabins,
    required this.viewedCabinId,
    required this.onCabinTap,
    required this.interior,
    this.selectedCountByCabin = const {},
  });

  final List<Cabin> cabins;
  final int? viewedCabinId;
  final ValueChanged<int> onCabinTap;
  final Map<int, int> selectedCountByCabin;

  /// Görüntülenen kabinin iç yerleşimi — genelde [CabinOverviewSelectionPanel].
  final Widget interior;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: MedSpacing.lg,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StationCabinStrip(
          cabins: cabins,
          viewedCabinId: viewedCabinId,
          selectedCountByCabin: selectedCountByCabin,
          onCabinTap: onCabinTap,
        ),
        Expanded(child: interior),
      ],
    );
  }
}

class StationCabinStrip extends StatelessWidget {
  const StationCabinStrip({
    super.key,
    required this.cabins,
    required this.viewedCabinId,
    required this.onCabinTap,
    this.selectedCountByCabin = const {},
  });

  final List<Cabin> cabins;
  final int? viewedCabinId;
  final ValueChanged<int> onCabinTap;
  final Map<int, int> selectedCountByCabin;

  static const double _cardWidth = 132;
  static const double _cardHeight = 176;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: MedSpacing.insetLg,
      decoration: MedDecoration.panelDecoration,
      child: Column(
        spacing: MedSpacing.md,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(context.l10n.cabinSelection_stripTitle, style: MedTextStyles.titleMd()),
              const SizedBox(width: MedSpacing.lg),
              Expanded(
                child: Text(
                  context.l10n.cabinSelection_stripHint,
                  style: MedTextStyles.bodySm(color: MedColors.text3),
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(
            height: _cardHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: cabins.length,
              separatorBuilder: (_, _) => const SizedBox(width: MedSpacing.lg),
              itemBuilder: (context, index) {
                final cabin = cabins[index];
                final id = cabin.id;
                final count = id == null ? 0 : (selectedCountByCabin[id] ?? 0);
                return _StripCard(
                  cabin: cabin,
                  isViewed: id != null && id == viewedCabinId,
                  selectedCount: count,
                  width: _cardWidth,
                  height: _cardHeight,
                  onTap: id == null ? null : () => onCabinTap(id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StripCard extends StatelessWidget {
  const _StripCard({
    required this.cabin,
    required this.isViewed,
    required this.selectedCount,
    required this.width,
    required this.height,
    this.onTap,
  });

  final Cabin cabin;
  final bool isViewed;
  final int selectedCount;
  final double width;
  final double height;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isViewed,
      label: cabin.name,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Stack(
          children: [
            CabinTypeReferenceView(
              cabin: cabin,
              isActive: isViewed,
              dimWhenInactive: false,
              width: width,
              height: height,
            ),
            if (selectedCount > 0)
              Positioned(
                top: MedSpacing.sm,
                right: MedSpacing.sm,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: MedSpacing.md, vertical: 2),
                  decoration: BoxDecoration(color: MedColors.blue, borderRadius: MedRadius.xlAll),
                  child: Text(
                    context.l10n.cabinSelection_selectedCountBadge(selectedCount),
                    style: MedTextStyles.monoXs(color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Sağ listenin kabin filtresi: "Tümü" + her kabin.
class StationCabinFilterBar extends StatelessWidget {
  const StationCabinFilterBar({
    super.key,
    required this.cabins,
    required this.selectedCabinId,
    required this.onChanged,
  });

  final List<Cabin> cabins;

  /// null → Tümü.
  final int? selectedCabinId;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    if (cabins.length < 2) return const SizedBox.shrink();
    final index = selectedCabinId == null ? 0 : cabins.indexWhere((c) => c.id == selectedCabinId) + 1;
    return MedSegmentedButton(
      labels: [context.l10n.filter_all, for (final c in cabins) c.name ?? '—'],
      selectedIndex: index < 0 ? 0 : index,
      onChanged: (i) => onChanged(i == 0 ? null : cabins[i - 1].id),
    );
  }
}
