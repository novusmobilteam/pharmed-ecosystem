// [SWREQ-UI-CABIN-SELECTION-001] [IEC 62304 §5.5]
// Kabin-scoped bir operasyon route'una girmeden önce istasyondaki
// kabinlerden birini seçtiren ekran. Sadece master-tipi istasyonlarda
// gösterilir (mobil istasyonlarda DashboardNotifier.navigateTo() bu
// ekranı hiç tetiklemez, doğrudan tek kabine gider).
//
// Seçim iki adımlı: dokunma sadece görsel olarak vurgular (yerel state),
// "Devam Et" onaylayana kadar hiçbir şey notifier'a bildirilmez.
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../widgets/widgets.dart';

class CabinSelectionView extends StatefulWidget {
  const CabinSelectionView({
    super.key,
    required this.cabins,
    required this.cabinDataByCabinId,
    required this.onCabinSelected,
  });

  final List<Cabin> cabins;
  final Map<int, CabinVisualizerData> cabinDataByCabinId;
  final ValueChanged<int> onCabinSelected;

  @override
  State<CabinSelectionView> createState() => _CabinSelectionViewState();
}

class _CabinSelectionViewState extends State<CabinSelectionView> {
  int? _selectedCabinId;

  bool _isSelectable(Cabin cabin) {
    if (cabin.status == Status.passive) return false;
    if (cabin.id == null) return false;
    if (widget.cabinDataByCabinId[cabin.id] == null) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 24.0,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: MedSpacing.xl,
          children: widget.cabins.map((cabin) {
            return SizedBox(
              width: 300,
              child: _CabinSelectionCard(
                cabin: cabin,
                data: cabin.id != null ? widget.cabinDataByCabinId[cabin.id] : null,
                isSelectable: _isSelectable(cabin),
                isSelected: cabin.id != null && cabin.id == _selectedCabinId,
                onTap: () => setState(() => _selectedCabinId = cabin.id),
              ),
            );
          }).toList(),
        ),
        SizedBox(
          width: 300,
          child: MedButton(
            label: context.l10n.cabinSelection_continueButton,
            onPressed: _selectedCabinId != null ? () => widget.onCabinSelected(_selectedCabinId!) : null,
          ),
        ),
      ],
    );
  }
}

class _CabinSelectionCard extends StatelessWidget {
  const _CabinSelectionCard({
    required this.cabin,
    required this.data,
    required this.isSelectable,
    required this.isSelected,
    required this.onTap,
  });

  final Cabin cabin;
  final CabinVisualizerData? data;
  final bool isSelectable;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isPassive = cabin.status == Status.passive;
    final isDataMissing = data == null && !isPassive;

    return Opacity(
      opacity: isSelectable ? 1.0 : 0.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  cabin.name ?? '—',
                  style: MedTextStyles.titleSm(color: MedColors.text),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isPassive) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: MedColors.text4, borderRadius: MedRadius.smAll),
                  child: Text(
                    context.l10n.cabinDesign_cabinList_passiveBadge.toUpperCase(),
                    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
              ] else if (isDataMissing) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: MedColors.red, borderRadius: MedRadius.smAll),
                  child: Text(
                    context.l10n.cabinSelection_dataUnavailableLabel,
                    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
              ],
            ],
          ),

          Text(cabin.type?.label ?? '—', style: MedTextStyles.bodySm(color: MedColors.text3)),
          const SizedBox(height: MedSpacing.sm),
          MasterCabinDeviceVisual(
            groups: data?.groups ?? const [],
            isMaster: cabin.type == CabinType.master,
            isWholeCabinSelected: isSelected,
            onCabinTap: isSelectable ? onTap : null,
          ),
        ],
      ),
    );
  }
}
