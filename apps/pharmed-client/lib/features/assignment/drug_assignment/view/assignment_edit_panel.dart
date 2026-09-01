part of 'drug_assignment_view.dart';

class _AssignmentEditPanel extends StatelessWidget {
  const _AssignmentEditPanel({required this.state, required this.notifier});

  final DrugAssignmentCellSelected state;
  final DrugAssignmentNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 2, color: MedColors.border),
        color: MedColors.surface,
        borderRadius: MedRadius.mdAll,
      ),
      padding: MedSpacing.insetXl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 4,
                  child: _MedicineSelectionPanel(state: state, notifier: notifier),
                ),
                VerticalDivider(width: 55),
                Expanded(
                  flex: 2,
                  child: _QuantityFormPanel(state: state, notifier: notifier),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MedicineSelectionPanel extends StatelessWidget {
  const _MedicineSelectionPanel({required this.state, required this.notifier});

  final DrugAssignmentCellSelected state;
  final DrugAssignmentNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final page = state.selectedPage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (state.isAssigned) ...[
          MedSegmentedButton(
            selectedIndex: state.listMode.index,
            onChanged: notifier.onListModeChanged,
            labels: [
              context.l10n.assignment_edit_equivalentMedicinesSegment,
              context.l10n.assignment_edit_allMedicinesSegment,
            ],
          ),
          const SizedBox(height: MedSpacing.md),
        ],
        MedTextInputField(
          onChanged: (value) => notifier.onSearchChanged(value),
          hintText: context.l10n.assignment_edit_searchHint,
        ),
        const SizedBox(height: MedSpacing.md),
        Expanded(
          child: page.isLoading
              ? const Center(child: MedLoadingIndicator())
              : page.error != null
              ? const EmptyStateWidget(variant: EmptyStateVariant.error, size: EmptyStateSize.compact)
              : page.items.isEmpty
              ? const EmptyStateWidget(variant: EmptyStateVariant.noResults, size: EmptyStateSize.compact)
              : ListView.separated(
                  itemCount: page.items.length,
                  separatorBuilder: (_, _) => const Divider(height: 1, color: MedColors.border2),
                  itemBuilder: (context, index) {
                    final medicine = page.items[index];
                    return _MedicineListItem(
                      medicine: medicine,
                      isSelected: state.selectedDrug?.id == medicine.id,
                      isInCabin: notifier.isMedicineAlreadyInCabin(state, medicine),
                      onTap: () => notifier.onDrugSelected(medicine),
                    );
                  },
                ),
        ),
        if (page.totalCount > page.pageSize) ...[
          const SizedBox(height: MedSpacing.sm),
          _PaginationBar(page: page, onPrevious: notifier.onPreviousPage, onNext: notifier.onNextPage),
        ],
      ],
    );
  }
}

class _MedicineListItem extends StatelessWidget {
  const _MedicineListItem({
    required this.medicine,
    required this.isSelected,
    required this.isInCabin,
    required this.onTap,
  });

  final Medicine medicine;
  final bool isSelected;
  final bool isInCabin;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        color: isSelected ? MedColors.blueLight : null,
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              size: 18,
              color: isSelected ? MedColors.blue : MedColors.border,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medicine.name ?? '-',
                    style: MedTextStyles.bodyMd(color: MedColors.text, weight: FontWeight.w600),
                  ),
                  Text(
                    medicine.name ?? '-',
                    style: MedTextStyles.bodySm(color: MedColors.text3),
                  ), // alt satır — bkz. not
                ],
              ),
            ),
            if (isInCabin)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: MedColors.surface3, borderRadius: MedRadius.smAll),
                child: Text(
                  context.l10n.assignment_edit_inCabinBadge,
                  style: TextStyle(fontFamily: MedFonts.mono, fontSize: 9, color: MedColors.text3),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PaginationBar extends StatelessWidget {
  const _PaginationBar({required this.page, required this.onPrevious, required this.onNext});

  final MedicinePageState page;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton.icon(
          onPressed: page.hasPreviousPage ? onPrevious : null,
          icon: Icon(PhosphorIcons.caretLeft(), size: 14),
          label: Text(context.l10n.assignment_edit_previousPage),
        ),
        Text(
          context.l10n.assignment_edit_pageIndicator(page.page + 1, page.totalPages),
          style: MedTextStyles.bodySm(color: MedColors.text3),
        ),
        TextButton.icon(
          onPressed: page.hasNextPage ? onNext : null,
          icon: Icon(PhosphorIcons.caretRight(), size: 14),
          label: Text(context.l10n.assignment_edit_nextPage),
        ),
      ],
    );
  }
}

class _QuantityFormPanel extends StatelessWidget {
  const _QuantityFormPanel({required this.state, required this.notifier});

  final DrugAssignmentCellSelected state;
  final DrugAssignmentNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final medicine = state.selectedDrug ?? state.assignment.medicine;
    final suffix = medicine?.fillingUnitLocalized(context) ?? context.l10n.common_defaultUnitFallback;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MedButton(
          label: context.l10n.assignment_edit_cancelButton,
          variant: MedButtonVariant.ghost,
          size: MedButtonSize.sm,
          fullWidth: true,
          onPressed: notifier.cancelEditing,
        ),
        SizedBox(height: 16.0),
        MedValueCard(
          label: context.l10n.common_minLabel,
          value: state.minQty?.toString() ?? '0',
          density: MedValueCardDensity.compact,
          suffix: suffix,
          onTap: () async {
            final result = await showNumpadView(context, initialValue: state.minQty?.toCustomString() ?? '');
            if (result != null) {
              notifier.onMinQtyChanged(int.tryParse(result));
            }
          },
        ),
        SizedBox(height: 12.0),
        MedValueCard(
          label: context.l10n.common_maxLabel,
          value: state.maxQty?.toString() ?? '0',
          density: MedValueCardDensity.compact,
          suffix: suffix,
          onTap: () async {
            final result = await showNumpadView(context, initialValue: state.maxQty?.toCustomString() ?? '');
            if (result != null) {
              notifier.onMaxQtyChanged(int.tryParse(result));
            }
          },
        ),
        SizedBox(height: 12.0),
        MedValueCard(
          label: context.l10n.common_criticalLabel,
          value: state.criticalQty?.toString() ?? '0',
          density: MedValueCardDensity.compact,
          suffix: suffix,
          onTap: () async {
            final result = await showNumpadView(context, initialValue: state.criticalQty?.toCustomString() ?? '');
            if (result != null) {
              notifier.onCriticalQtyChanged(int.tryParse(result));
            }
          },
        ),

        const Spacer(),
        if (state.isAssigned) ...[
          MedButton(
            label: context.l10n.assignment_edit_removeLink,
            fullWidth: true,
            variant: MedButtonVariant.danger,
            onPressed: notifier.deleteAssignment,
          ),
          const SizedBox(height: MedSpacing.sm),
        ],
        MedButton(
          label: context.l10n.assignment_edit_saveButton,
          fullWidth: true,
          onPressed: state.canSave ? notifier.saveAssignment : null,
        ),
      ],
    );
  }
}
