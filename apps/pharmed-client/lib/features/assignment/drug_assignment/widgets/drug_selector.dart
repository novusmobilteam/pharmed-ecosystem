part of '../view/drug_assignment_panel.dart';

class _DrugSelector extends StatelessWidget {
  const _DrugSelector({required this.selectedDrug, required this.onTap});

  final Medicine? selectedDrug;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasSelection = selectedDrug != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MedLabel(
          text: context.l10n.assignment_drugSectionLabel,
          variant: MedLabelVariant.monoDetail,
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              color: hasSelection ? MedColors.blueLight : MedColors.surface2,
              border: Border.all(color: hasSelection ? MedColors.blue : MedColors.border, width: 1.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    hasSelection ? (selectedDrug!.name ?? '—') : context.l10n.assignment_drugSelectorHint,
                    style: TextStyle(
                      fontFamily: MedFonts.sans,
                      fontSize: 13,
                      fontWeight: hasSelection ? FontWeight.w600 : FontWeight.w400,
                      color: hasSelection ? MedColors.blue : MedColors.text3,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.search_rounded, size: 16, color: hasSelection ? MedColors.blue : MedColors.text3),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
