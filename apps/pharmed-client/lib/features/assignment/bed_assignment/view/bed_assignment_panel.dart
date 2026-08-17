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

import '../notifier/bed_assignment_notifier.dart';

part '../widgets/bed_card.dart';
part '../widgets/action_buttons.dart';
part '../widgets/bed_selector.dart';

class BedAssignmentPanel extends StatelessWidget {
  const BedAssignmentPanel({super.key, required this.notifier});

  final BedAssignmentNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final isSaving = notifier.isLoading(notifier.saveOp);

    if (isSaving) {
      return const _SavingContent();
    }

    if (!notifier.isCellSelected) {
      return const _PlaceholderContent();
    }

    return _CellSelectedContent(notifier: notifier);
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
  const _CellSelectedContent({required this.notifier});

  final BedAssignmentNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (notifier.existingAssignment == null) _BedSelector(notifier: notifier),
        if (notifier.selectedBed != null) _BedCard(notifier: notifier),
        const SizedBox(height: 20),
        _ActionButtons(
          existingAssignment: notifier.existingAssignment,
          selectedBed: notifier.selectedBed,
          onSave: notifier.saveAssignment,
          onDelete: notifier.deleteAssignment,
        ),
      ],
    );
  }
}
