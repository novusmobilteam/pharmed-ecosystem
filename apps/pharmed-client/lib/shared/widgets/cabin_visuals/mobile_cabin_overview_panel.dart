// lib/shared/widgets/mobile_cabin_overview_panel.dart
//
// [SWREQ-UI-CAB-007]
// Mobil kabin işlemleri ekranının sol paneli.
// MobileSlotVisual listesini tıklanabilir çekmece kartları olarak gösterir.
//
// Standart kabindeki CabinOverviewPanel'in mobil karşılığı.
// DrawerGroup yerine MobileSlotVisual kullanır.
//
// KULLANIM:
//   MobileCabinOverviewPanel(
//     slots: data.slots.whereType<MobileSlotVisual>().toList(),
//     selectedSlotId: _selectedSlotId,
//     mode: CabinOperationMode.assign,
//     onSlotTap: (slot) => notifier.onSlotTap(slot),
//   )
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:pharmed_client/core/enums/cabin_operation_mode.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

// ─────────────────────────────────────────────────────────────────
// MobileCabinOverviewPanel
// ─────────────────────────────────────────────────────────────────

class MobileCabinOverviewPanel extends StatelessWidget {
  const MobileCabinOverviewPanel({
    super.key,
    required this.slots,
    required this.mode,
    required this.onSlotTap,
    this.selectedSlotId,
  });

  final List<MobileSlotVisual> slots;
  final CabinOperationMode mode;
  final void Function(MobileSlotVisual slot) onSlotTap;
  final int? selectedSlotId;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFD8E0EC),
        border: Border.all(color: MedColors.border2, width: 2),
        borderRadius: MedRadius.lgAll,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PanelHeader(),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < slots.length; i++) ...[
                  _SlotItem(
                    slot: slots[i],
                    index: i,
                    isSelected: slots[i].slotId == selectedSlotId,
                    mode: mode,
                    onTap: () => onSlotTap(slots[i]),
                  ),
                  if (i < slots.length - 1) const SizedBox(height: 5),
                ],
              ],
            ),
          ),
          _PanelFooter(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// _SlotItem — tek çekmece kartı
// ─────────────────────────────────────────────────────────────────

class _SlotItem extends StatelessWidget {
  const _SlotItem({
    required this.slot,
    required this.index,
    required this.isSelected,
    required this.mode,
    required this.onTap,
  });

  final MobileSlotVisual slot;
  final int index;
  final bool isSelected;
  final CabinOperationMode mode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 60,
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFDCEEFF), Color(0xFFCEE0F7)],
                )
              : const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFEDF1F8), Color(0xFFDDE5F0)],
                ),
          border: Border.all(color: isSelected ? MedColors.blue : MedColors.border2, width: isSelected ? 2 : 1.5),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(7, 5, 7, 4),
              child: Row(
                children: [
                  // Tip etiketi
                  Text(
                    'MOBİL',
                    style: TextStyle(
                      fontFamily: MedFonts.sans,
                      fontSize: 9,
                      letterSpacing: 0.8,
                      color: MedColors.text3,
                    ),
                  ),
                  const Spacer(),
                  // Göz sayısı
                  Text(
                    '${slot.totalCells} göz',
                    style: TextStyle(fontFamily: MedFonts.mono, fontSize: 9, color: MedColors.text3),
                  ),
                ],
              ),
            ),
            // Satır önizlemesi — rowColumns mini bar
            Padding(
              padding: const EdgeInsets.fromLTRB(7, 0, 7, 0),
              child: _RowPreview(slot: slot, isSelected: isSelected),
            ),
            const Spacer(),
            _DrawerHandle(),
            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// _RowPreview — slot'un satır yapısını mini olarak gösterir
// ─────────────────────────────────────────────────────────────────

class _RowPreview extends StatelessWidget {
  const _RowPreview({required this.slot, required this.isSelected});

  final MobileSlotVisual slot;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    // Her satırı tek bir bar olarak temsil et
    return Row(
      spacing: 2,
      children: slot.rowColumns.take(6).map((cols) {
        return Expanded(
          child: Container(
            height: 5,
            decoration: BoxDecoration(
              color: isSelected ? MedColors.blue.withOpacity(0.4) : MedColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Yardımcı widget'lar — CabinOverviewPanel ile aynı görsel dil
// ─────────────────────────────────────────────────────────────────

class _PanelHeader extends StatelessWidget {
  const _PanelHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFC4CEDF), Color(0xFFB4C0D4)],
        ),
        border: Border(bottom: BorderSide(color: Color(0xFFE8ECF3), width: 2)),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
      ),
    );
  }
}

class _PanelFooter extends StatelessWidget {
  const _PanelFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFB4C0D4), Color(0xFFA0AEC0)],
        ),
        border: Border(top: BorderSide(color: Color(0xFFE8ECF3), width: 1.5)),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
      ),
    );
  }
}

class _DrawerHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 6,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFA0B0C4), Color(0xFF9AADC0), Color(0xFFA0B0C4)],
        ),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: const Color(0xFF7A90A8)),
      ),
    );
  }
}
