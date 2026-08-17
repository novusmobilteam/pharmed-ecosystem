part of 'drug_assignment_view.dart';

class AssignmentSection extends StatelessWidget {
  const AssignmentSection({super.key, this.assignment, this.onClear});

  final MedicineAssignment? assignment;

  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HeaderView(),
        Divider(color: MedColors.text2, height: 1, thickness: 2),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: DrugSelectionView()),
              VerticalDivider(color: MedColors.text3, width: 1, thickness: 1),
              Expanded(
                child: Consumer<DrugAssignmentNotifier>(
                  builder: (BuildContext context, DrugAssignmentNotifier notifier, Widget? child) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 12.0, left: 42.0, right: 42.0),
                      child: SizedBox(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              spacing: MedSpacing.lg,
                              children: [
                                MedLabeledDoseStepper(
                                  title: 'Minimum Miktar',
                                  //description: 'Bu seviyenin altı sipariş önerir',
                                  value: (notifier.minQty ?? 0).toDouble(),
                                  onChanged: (v) => notifier.onMinQtyChanged(v.toInt()),
                                ),
                                MedLabeledDoseStepper(
                                  title: 'Kritik Miktar',
                                  //description: 'Bu seviyede kritik uyarı verilir',
                                  value: (notifier.criticalQty ?? 0).toDouble(),
                                  onChanged: (v) => notifier.onCriticalQtyChanged(v.toInt()),
                                ),
                                MedLabeledDoseStepper(
                                  title: 'Maksimum Miktar',
                                  //description: 'Gözün alabileceği en fazla adet',
                                  value: (notifier.maxQty ?? 0).toDouble(),
                                  onChanged: (v) => notifier.onMaxQtyChanged(v.toInt()),
                                ),
                              ],
                            ),
                            Spacer(),
                            if (notifier.isAssigned)
                              GestureDetector(
                                onTap: () => notifier.deleteAssignment(
                                  onFailed: (String? msg) => MessageUtils.showErrorSnackbar(context, msg),
                                  onSuccess: () {
                                    MessageUtils.showSuccessSnackbar(
                                      context,
                                      context.l10n.common_operationSuccessMessage,
                                    );
                                  },
                                ),
                                child: SizedBox(
                                  height: 35,
                                  child: notifier.isLoading(notifier.deleteOp)
                                      ? Align(alignment: Alignment.centerLeft, child: MedLoadingIndicator())
                                      : Text('Atamayı Kaldır', style: MedTextStyles.titleMd(color: MedColors.blue)),
                                ),
                              ),

                            MedRectangleButton(
                              isActive: notifier.canSave,
                              isLoading: notifier.isLoading(notifier.submitOp),
                              label: notifier.isAssigned ? 'Değişiklikleri Kaydet' : 'Atama Kaydet',
                              suffixIcon: PhosphorIcons.check(),
                              foregroundColor: Colors.white,
                              onTap: () => notifier.saveAssignment(
                                onFailed: (String? msg) => MessageUtils.showErrorSnackbar(context, msg),
                                onSuccess: () {
                                  MessageUtils.showSuccessSnackbar(
                                    context,
                                    context.l10n.common_operationSuccessMessage,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class HeaderView extends StatelessWidget {
  const HeaderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DrugAssignmentNotifier>(
      builder: (BuildContext context, DrugAssignmentNotifier notifier, Widget? child) {
        bool isEmpty = !notifier.isAssigned;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(isEmpty ? 'Yeni Atama' : 'Atamayı Düzenle', style: MedTextStyles.titleXl()),
                  GestureDetector(
                    onTap: notifier.clearSelection,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: MedSpacing.insetXl.left * 2,
                        vertical: MedSpacing.insetLg.top,
                      ),
                      decoration: BoxDecoration(border: Border.all()),
                      child: Text('Vazgeç', style: MedTextStyles.titleMd()),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class DrugSelectionView extends StatelessWidget {
  const DrugSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DrugAssignmentNotifier>(
      builder: (context, notifier, child) {
        if (notifier.isLoading(notifier.fetchDrugsOp) && notifier.items.isEmpty) {
          return const Center(child: MedLoadingIndicator());
        }

        if (notifier.items.isEmpty) {
          return Center(child: Text('İlaç bulunamadı', style: MedTextStyles.bodyMd()));
        }

        return Padding(
          padding: const EdgeInsets.only(top: 12.0, right: 16.0),
          child: Column(
            spacing: 6.0,
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'İlaç Ara',
                  hintStyle: MedTextStyles.monoSm(),
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.zero)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.zero)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.zero)),
                ),
                onChanged: notifier.search,
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: notifier.items.length,
                  separatorBuilder: (context, index) => Divider(height: 1, color: MedColors.border),
                  itemBuilder: (context, index) {
                    final drug = notifier.items[index];
                    final isSelected = drug.id == notifier.selectedDrug?.id;

                    return GestureDetector(
                      onTap: () => notifier.onDrugSelected(drug),
                      child: Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.symmetric(vertical: 4.0),
                        height: 60,
                        decoration: BoxDecoration(color: isSelected ? MedColors.blueLight : null),
                        child: Row(
                          spacing: 6.0,
                          children: [
                            isSelected
                                ? Icon(PhosphorIconsFill.circle, color: MedColors.blue)
                                : Icon(PhosphorIcons.circle()),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(drug.name ?? '', style: MedTextStyles.bodyLg(weight: FontWeight.bold)),
                                Text(drug.barcode ?? '', style: MedTextStyles.monoMd()),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (notifier.totalPages > 1)
                PaginationBar(
                  totalPages: notifier.totalPages,
                  currentPage: notifier.currentPage,
                  isLoading: notifier.isTableLoading,
                  canGoPrev: notifier.canGoPrev,
                  canGoNext: notifier.canGoNext,
                  onPreviousPage: notifier.previousPage,
                  onNextPage: notifier.nextPage,
                  goToPage: notifier.setPage,
                ),
            ],
          ),
        );
      },
    );
  }
}
