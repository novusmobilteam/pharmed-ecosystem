// [SWREQ-UI-CAB-006]
// Hasta bazlı atama sağ panel içeriği.
//
// Göz seçilmeden → placeholder
// Göz seçildi, atanmamış → yatış seçici butonu + Kaydet
// Göz seçildi, atanmış → hasta kimlik kartı + Değiştir / Atamayı Kaldır
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../notifier/bed_assignment_state.dart';

part '../widgets/bed_card.dart';
part '../widgets/action_buttons.dart';
part '../widgets/bed_selector.dart';

class BedAssignmentPanel extends StatelessWidget {
  const BedAssignmentPanel({
    super.key,
    required this.state,
    required this.onServiceSelected,
    required this.onRoomSelected,
    required this.onBedSelected,
    required this.onSave,
    required this.onDelete,
  });

  final BedAssignmentState state;
  final ValueChanged<HospitalService?> onServiceSelected;
  final ValueChanged<Room?> onRoomSelected;
  final ValueChanged<Bed?> onBedSelected;
  final VoidCallback onSave;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      BedAssignmentCellSelected s => _CellSelectedContent(
        state: s,
        onServiceSelected: onServiceSelected,
        onRoomSelected: onRoomSelected,
        onBedSelected: onBedSelected,
        onSave: onSave,
        onDelete: onDelete,
      ),
      BedAssignmentSaving _ => const _SavingContent(),
      _ => const _PlaceholderContent(),
    };
  }
}

class _PlaceholderContent extends StatelessWidget {
  const _PlaceholderContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: MedColors.surface3,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: MedColors.border, width: 1.5),
          ),
          child: Icon(Icons.person_outline_rounded, size: 22, color: MedColors.text4),
        ),
        const SizedBox(height: 12),
        Text(
          context.l10n.common_selectCellTitle,
          style: TextStyle(
            fontFamily: MedFonts.sans,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: MedColors.text3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          context.l10n.assignment_assignBedPlaceholder,
          style: MedTextStyles.bodySm(color: MedColors.text4),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _SavingContent extends StatelessWidget {
  const _SavingContent();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(32),
      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }
}

class _CellSelectedContent extends StatelessWidget {
  const _CellSelectedContent({
    required this.state,
    required this.onServiceSelected,
    required this.onRoomSelected,
    required this.onBedSelected,
    required this.onSave,
    required this.onDelete,
  });

  final BedAssignmentCellSelected state;
  final ValueChanged<HospitalService?> onServiceSelected;
  final ValueChanged<Room?> onRoomSelected;
  final ValueChanged<Bed?> onBedSelected;
  final VoidCallback onSave;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (state.existingAssignment == null)
          _BedSelector(
            state: state,
            onServiceSelected: onServiceSelected,
            onRoomSelected: onRoomSelected,
            onBedSelected: onBedSelected,
          ),
        if (state.selectedBed != null) _BedCard(state: state),
        const SizedBox(height: 20),
        _ActionButtons(
          existingAssignment: state.existingAssignment,
          selectedBed: state.selectedBed,
          onSave: onSave,
          onDelete: onDelete,
        ),
      ],
    );
  }
}
