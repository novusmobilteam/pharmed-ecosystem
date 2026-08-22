import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CabinOperationSearchField extends StatelessWidget {
  const CabinOperationSearchField({super.key, required this.onChanged, this.hintText});

  final ValueChanged<String> onChanged;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: MedColors.surface,
        borderRadius: MedRadius.mdAll,
        border: Border.all(color: MedColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(PhosphorIcons.magnifyingGlass(), color: MedColors.text3, size: 18),
          Expanded(
            child: TextFormField(
              style: MedTextStyles.titleSm().copyWith(fontWeight: FontWeight.normal, color: MedColors.text4),
              decoration: InputDecoration(
                filled: false,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                border: InputBorder.none,
                hintText: hintText ?? context.l10n.refill_hint_searchMedicine,
                // hintText: context.l10n.patientListPanel_searchHint,
                hintStyle: MedTextStyles.titleSm().copyWith(fontWeight: FontWeight.normal, color: MedColors.text4),
              ),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
