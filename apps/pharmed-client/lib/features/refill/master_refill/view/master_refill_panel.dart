// lib/features/refill/master_refill/presentation/widget/master_refill_panel.dart
//
// [SWREQ-CLI-MREFILL-003] [IEC 62304 §5.5]
// Master kabin dolum sağ paneli.
//
// Göz/çekmece seçilmemişse: yönlendirici boş state
// Kübik göz seçilmişse:     ilaç bilgisi + stok kartı + tekil input + çekmece aç butonu
// Birim doz seçilmişse:     her göz için satır bazlı input + çekmece aç butonu
//
// Input alanları TextField bazlıdır — dokunmatik ekranda sistem klavyesi/numpad kullanılır.
// didUpdateWidget ile dışarıdan value güncellemesi desteklenir (_QtyInput pattern).
//
// Sınıf: Class B

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../../core/enums/cabin_operation_mode.dart';
import '../../../../../widgets/operation_panel_base.dart';
import '../../../../core/cabin_operation/cabin_operation.dart';
import '../../refill.dart';
import '../notifier/refill_step_input.dart';

class MasterRefillPanel extends StatelessWidget {
  const MasterRefillPanel({
    super.key,
    required this.state,
    required this.drawerStage,
    required this.onFillingQuantityChanged,
    required this.onCountQuantityChanged,
    required this.onMiadDateChanged,
    required this.onStepFillingChanged,
    required this.onStepCountChanged,
    required this.onStepMiadChanged,
    required this.onOpenDrawer,
    required this.onConfirmClose,
    required this.onSave,
    required this.onCancelDrawer,
  });

  final MasterRefillState state;
  final MasterDrawerStage drawerStage;

  final ValueChanged<double> onFillingQuantityChanged;
  final ValueChanged<double> onCountQuantityChanged;
  final ValueChanged<DateTime?> onMiadDateChanged;

  final void Function(int index, double value) onStepFillingChanged;
  final void Function(int index, double value) onStepCountChanged;
  final void Function(int index, DateTime? date) onStepMiadChanged;

  final VoidCallback onOpenDrawer;
  final VoidCallback onConfirmClose;
  final VoidCallback onSave;
  final VoidCallback onCancelDrawer;

  bool get _isSaving => state is MasterRefillSaving;

  @override
  Widget build(BuildContext context) {
    return OperationPanelBase(
      mode: CabinOperationMode.refill,
      child: switch (state) {
        MasterRefillUninitialized() ||
        MasterRefillLoading() => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        MasterRefillIdle() => const _EmptyHint(message: 'Dolum yapmak için sol panelden bir çekmece seçin.'),
        MasterRefillDrawerSelected() => const _EmptyHint(message: 'Çekmeceden bir göz seçin.'),
        MasterRefillCellSelected ready => _ReadyBody(
          group: ready.selectedGroup,
          selectedUnit: ready.selectedUnit,
          stepInputs: ready.stepInputs,
          fillingQuantity: ready.fillingQuantity,
          countQuantity: ready.countQuantity,
          miadDate: ready.miadDate,
          assignments: ready.assignments,
          stocks: ready.stocks,
          drawerStage: drawerStage,
          isSaving: _isSaving,
          canSave: ready.canSave,
          onFillingQuantityChanged: onFillingQuantityChanged,
          onCountQuantityChanged: onCountQuantityChanged,
          onMiadDateChanged: onMiadDateChanged,
          onStepFillingChanged: onStepFillingChanged,
          onStepCountChanged: onStepCountChanged,
          onStepMiadChanged: onStepMiadChanged,
          onOpenDrawer: onOpenDrawer,
          onConfirmClose: onConfirmClose,
          onSave: onSave,
          onCancelDrawer: onCancelDrawer,
        ),
        MasterRefillSaving(:final selectedGroup, :final selectedUnit) ||
        MasterRefillSuccess(:final selectedGroup, :final selectedUnit) => _ReadyBody(
          group: selectedGroup,
          selectedUnit: selectedUnit,
          stepInputs: null,
          fillingQuantity: 0,
          countQuantity: 0,
          miadDate: null,
          assignments: state.assignments,
          stocks: state.stocks,
          drawerStage: drawerStage,
          isSaving: true,
          canSave: false,
          onFillingQuantityChanged: onFillingQuantityChanged,
          onCountQuantityChanged: onCountQuantityChanged,
          onMiadDateChanged: onMiadDateChanged,
          onStepFillingChanged: onStepFillingChanged,
          onStepCountChanged: onStepCountChanged,
          onStepMiadChanged: onStepMiadChanged,
          onOpenDrawer: onOpenDrawer,
          onConfirmClose: onConfirmClose,
          onSave: onSave,
          onCancelDrawer: onCancelDrawer,
        ),
        MasterRefillError(:final previousState) => switch (previousState) {
          MasterRefillCellSelected ready => _ReadyBody(
            group: ready.selectedGroup,
            selectedUnit: ready.selectedUnit,
            stepInputs: ready.stepInputs,
            fillingQuantity: ready.fillingQuantity,
            countQuantity: ready.countQuantity,
            miadDate: ready.miadDate,
            assignments: ready.assignments,
            stocks: ready.stocks,
            drawerStage: drawerStage,
            isSaving: false,
            canSave: ready.canSave,
            onFillingQuantityChanged: onFillingQuantityChanged,
            onCountQuantityChanged: onCountQuantityChanged,
            onMiadDateChanged: onMiadDateChanged,
            onStepFillingChanged: onStepFillingChanged,
            onStepCountChanged: onStepCountChanged,
            onStepMiadChanged: onStepMiadChanged,
            onOpenDrawer: onOpenDrawer,
            onConfirmClose: onConfirmClose,
            onSave: onSave,
            onCancelDrawer: onCancelDrawer,
          ),
          _ => const _EmptyHint(message: 'Bir göz seçin.'),
        },
      },
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(PhosphorIcons.squaresFour(), size: 36, color: MedColors.text4),
          const SizedBox(height: 10),
          Text(
            message,
            style: MedTextStyles.bodySm(color: MedColors.text3),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ReadyBody extends StatelessWidget {
  const _ReadyBody({
    required this.group,
    required this.selectedUnit,
    required this.stepInputs,
    required this.fillingQuantity,
    required this.countQuantity,
    required this.miadDate,
    required this.assignments,
    required this.stocks,
    required this.drawerStage,
    required this.isSaving,
    required this.canSave,
    required this.onFillingQuantityChanged,
    required this.onCountQuantityChanged,
    required this.onMiadDateChanged,
    required this.onStepFillingChanged,
    required this.onStepCountChanged,
    required this.onStepMiadChanged,
    required this.onOpenDrawer,
    required this.onConfirmClose,
    required this.onSave,
    required this.onCancelDrawer,
  });

  final DrawerGroup group;
  final DrawerUnit selectedUnit;
  final List<RefillStepInput>? stepInputs;
  final double fillingQuantity;
  final double countQuantity;
  final DateTime? miadDate;
  final List<MedicineAssignment> assignments;
  final List<CabinStock> stocks;
  final MasterDrawerStage drawerStage;
  final bool isSaving;
  final bool canSave;

  final ValueChanged<double> onFillingQuantityChanged;
  final ValueChanged<double> onCountQuantityChanged;
  final ValueChanged<DateTime?> onMiadDateChanged;
  final void Function(int index, double value) onStepFillingChanged;
  final void Function(int index, double value) onStepCountChanged;
  final void Function(int index, DateTime? date) onStepMiadChanged;
  final VoidCallback onOpenDrawer;
  final VoidCallback onConfirmClose;
  final VoidCallback onSave;
  final VoidCallback onCancelDrawer;

  bool get _isUnitDose => stepInputs != null;
  bool get _isDrawerOpened => drawerStage is MasterDrawerOpened;

  @override
  Widget build(BuildContext context) {
    final isLocked = !_isDrawerOpened || isSaving;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: _isUnitDose
              ? _UnitDoseInputList(
                  stepInputs: stepInputs!,
                  assignments: assignments,
                  stocks: stocks,
                  isLocked: isLocked,
                  onFillingChanged: onStepFillingChanged,
                  onCountChanged: onStepCountChanged,
                  onMiadChanged: onStepMiadChanged,
                )
              : _KubikInputSection(
                  selectedUnit: selectedUnit,
                  assignments: assignments,
                  stocks: stocks,
                  fillingQuantity: fillingQuantity,
                  countQuantity: countQuantity,
                  miadDate: miadDate,
                  isLocked: isLocked,
                  onFillingChanged: onFillingQuantityChanged,
                  onCountChanged: onCountQuantityChanged,
                  onMiadChanged: onMiadDateChanged,
                ),
        ),
        const SizedBox(height: 12),
        _SaveButton(onSave: onSave, isSaving: isSaving, enabled: canSave && _isDrawerOpened),
      ],
    );
  }
}

class _KubikInputSection extends StatelessWidget {
  const _KubikInputSection({
    required this.selectedUnit,
    required this.assignments,
    required this.stocks,
    required this.fillingQuantity,
    required this.countQuantity,
    required this.miadDate,
    required this.isLocked,
    required this.onFillingChanged,
    required this.onCountChanged,
    required this.onMiadChanged,
  });

  final DrawerUnit selectedUnit;
  final List<MedicineAssignment> assignments;
  final List<CabinStock> stocks;
  final double fillingQuantity;
  final double countQuantity;
  final DateTime? miadDate;
  final bool isLocked;
  final ValueChanged<double> onFillingChanged;
  final ValueChanged<double> onCountChanged;
  final ValueChanged<DateTime?> onMiadChanged;

  @override
  Widget build(BuildContext context) {
    final assignment = assignments.firstWhereOrNull((a) => a.cabinDrawerId == selectedUnit.id);
    final stock = stocks.firstWhereOrNull((s) => s.cabinDrawerDetail?.drawerUnit?.id == selectedUnit.id);

    return SingleChildScrollView(
      child: Opacity(
        opacity: isLocked ? 0.5 : 1.0,
        child: IgnorePointer(
          ignoring: isLocked,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              if (assignment != null) _MedicineInfoCard(assignment: assignment, stock: stock),
              Row(
                spacing: 8,
                children: [
                  Expanded(
                    child: TextInputField(
                      label: 'Sayım Miktarı',
                      initialValue: countQuantity.formatFractional,
                      onChanged: (value) {},
                      // onChanged: onCountChanged,
                    ),
                  ),
                  Expanded(
                    child: TextInputField(
                      label: 'Dolum Miktarı',
                      initialValue: fillingQuantity.formatFractional,
                      onChanged: (value) {},
                      // onChanged: onFillingChanged,
                    ),
                  ),
                ],
              ),
              DateInputField(label: 'Son Kullanma Tarihi', initialValue: miadDate, onDateSelected: onMiadChanged),
            ],
          ),
        ),
      ),
    );
  }
}

class _UnitDoseInputList extends StatelessWidget {
  const _UnitDoseInputList({
    required this.stepInputs,
    required this.assignments,
    required this.stocks,
    required this.isLocked,
    required this.onFillingChanged,
    required this.onCountChanged,
    required this.onMiadChanged,
  });

  final List<RefillStepInput> stepInputs;
  final List<MedicineAssignment> assignments;
  final List<CabinStock> stocks;
  final bool isLocked;
  final void Function(int index, double value) onFillingChanged;
  final void Function(int index, double value) onCountChanged;
  final void Function(int index, DateTime? date) onMiadChanged;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: !isLocked ? 0.5 : 1.0,
      child: IgnorePointer(
        ignoring: !isLocked,
        child: ListView.separated(
          padding: EdgeInsets.zero,
          itemCount: stepInputs.length,
          separatorBuilder: (_, _) => Divider(height: 1, color: MedColors.border2),
          itemBuilder: (context, index) {
            final input = stepInputs[index];
            final assignment = assignments.firstWhereOrNull((a) => a.cabinDrawerId == input.unit.id);
            final stock = stocks.firstWhereOrNull((s) => s.cabinDrawerDetail?.drawerUnit?.id == input.unit.id);
            return _UnitDoseRow(
              index: index,
              input: input,
              assignment: assignment,
              stock: stock,
              onFillingChanged: (v) => onFillingChanged(index, v),
              onCountChanged: (v) => onCountChanged(index, v),
              onMiadChanged: (d) => onMiadChanged(index, d),
            );
          },
        ),
      ),
    );
  }
}

class _UnitDoseRow extends StatelessWidget {
  const _UnitDoseRow({
    required this.index,
    required this.input,
    required this.assignment,
    required this.stock,
    required this.onFillingChanged,
    required this.onCountChanged,
    required this.onMiadChanged,
  });

  final int index;
  final RefillStepInput input;
  final MedicineAssignment? assignment;
  final CabinStock? stock;
  final ValueChanged<double> onFillingChanged;
  final ValueChanged<double> onCountChanged;
  final ValueChanged<DateTime?> onMiadChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: MedColors.blueLight, borderRadius: BorderRadius.circular(6)),
                child: Text('${index + 1}', style: MedTextStyles.monoSm(color: MedColors.blue)),
              ),
            ],
          ),
          Column(
            spacing: 6.0,
            children: [
              Row(
                spacing: 6,
                children: [
                  Expanded(
                    child: TextInputField(
                      label: 'Sayım Miktarı',
                      initialValue: input.countQuantity.formatFractional,
                      onChanged: (value) {},
                      // onChanged: onCountChanged,
                    ),
                  ),
                  Expanded(
                    child: TextInputField(
                      label: 'Dolum Miktarı',
                      initialValue: input.fillingQuantity.formatFractional,
                      // onChanged: onFillingChanged,
                      onChanged: (value) {},
                    ),
                  ),
                ],
              ),
              DateInputField(initialValue: input.miadDate, onDateSelected: onMiadChanged),
            ],
          ),
        ],
      ),
    );
  }
}

class _MedicineInfoCard extends StatelessWidget {
  const _MedicineInfoCard({required this.assignment, required this.stock});

  final MedicineAssignment assignment;
  final CabinStock? stock;

  @override
  Widget build(BuildContext context) {
    final qty = stock?.quantity?.toDouble() ?? 0;
    final maxQty = assignment.maxQuantity?.toDouble() ?? 0;
    final critQty = assignment.criticalQuantity?.toDouble() ?? 0;
    final minQty = assignment.minQuantity?.toDouble() ?? 0;

    Color stockColor = MedColors.green;
    if (qty <= critQty) {
      stockColor = MedColors.red;
    } else if (qty <= minQty) {
      stockColor = MedColors.amber;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: MedColors.surface2,
        border: Border.all(color: MedColors.border),
        borderRadius: MedRadius.mdAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Row(
            children: [
              Icon(PhosphorIcons.pill(), size: 16, color: MedColors.blue),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  assignment.medicine?.name ?? '—',
                  style: MedTextStyles.titleSm(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (assignment.medicine?.barcode != null)
            Text(assignment.medicine!.barcode!, style: MedTextStyles.monoSm(color: MedColors.text3)),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: maxQty > 0 ? (qty / maxQty).clamp(0.0, 1.0) : 0,
                    minHeight: 6,
                    backgroundColor: MedColors.border2,
                    valueColor: AlwaysStoppedAnimation(stockColor),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text('${qty.toInt()} / ${maxQty.toInt()}', style: MedTextStyles.monoSm(color: stockColor)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.onSave, required this.isSaving, required this.enabled});

  final VoidCallback onSave;
  final bool isSaving;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return MedButton(label: 'Doluma Başla', isLoading: isSaving, onPressed: enabled ? onSave : null);
  }
}
