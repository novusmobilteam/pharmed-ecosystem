// [SWREQ-MGR-RX-006] [IEC 62304 §5.5]
// Reçete grup kartı — accordion detay + RFID altyapısı.
// [interactive] = true  → checkbox seçim + toplu onay/iptal/red
// [interactive] = false → salt görüntüleme
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import 'rx_movement_block.dart';

class RxGroupCard extends StatefulWidget {
  const RxGroupCard({
    super.key,
    required this.prescriptionId,
    required this.items,
    required this.permissions,
    this.canOverrideRfidLock = false, // <-- isAdmin yerine
    this.onApprove,
    this.onReject,
    this.onRejectAfterApprove,
    this.onCancel,
    this.onRfidTap,
    this.onRfidDelete,
  });

  final int prescriptionId;
  final List<PrescriptionItem> items;
  final PrescriptionActionPermissions permissions;
  final bool canOverrideRfidLock;
  final Future<void> Function(List<PrescriptionItem>)? onApprove;
  final Future<void> Function(List<PrescriptionItem>)? onReject;
  final Future<void> Function(List<PrescriptionItem>)? onCancel;
  final Future<void> Function(List<PrescriptionItem>)? onRejectAfterApprove;
  final Future<void> Function(PrescriptionItem item)? onRfidTap;
  final Future<void> Function(PrescriptionItem item)? onRfidDelete;

  @override
  State<RxGroupCard> createState() => _RxGroupCardState();
}

class _RxGroupCardState extends State<RxGroupCard> {
  final Set<int> _selectedIds = {};
  bool _isExpanded = true;

  bool get _interactive => widget.permissions.hasAny;
  bool get _hasSelection => _selectedIds.isNotEmpty;

  bool _isItemSelectable(PrescriptionItem item) {
    final s = item.status;
    if (s == null) return false;
    return (widget.permissions.canApprove && s.canApprove) ||
        (widget.permissions.canReject && s.canReject) ||
        (widget.permissions.canCancel && s.canCancel) ||
        (widget.permissions.canRejectAfterApprove || s.canFill);
  }

  List<PrescriptionItem> get _selectableItems => widget.items.where(_isItemSelectable).toList();
  List<PrescriptionItem> get _selectedItems => widget.items.where((i) => _selectedIds.contains(i.id)).toList();

  bool get _areAllSelectableSelected {
    final selectable = _selectableItems;
    if (selectable.isEmpty) return false;
    return selectable.every((i) => _selectedIds.contains(i.id));
  }

  bool get _canApproveSelected =>
      widget.permissions.canApprove &&
      _selectedItems.isNotEmpty &&
      _selectedItems.every((i) => i.status?.canApprove ?? false);

  bool get _canRejectSelected =>
      widget.permissions.canReject &&
      _selectedItems.isNotEmpty &&
      _selectedItems.every((i) => i.status?.canReject ?? false);

  bool get _canCancelSelected =>
      widget.permissions.canCancel &&
      _selectedItems.isNotEmpty &&
      _selectedItems.every((i) => i.status?.canCancel ?? false);

  bool get _canRejectAfterApprovedSelected =>
      _selectedItems.isNotEmpty && _selectedItems.every((i) => i.status?.canFill ?? false);

  bool get _hasPartialSelection {
    if (_selectableItems.isEmpty) return false;
    final selectedSelectable = _selectableItems.where((i) => _selectedIds.contains(i.id)).length;
    return selectedSelectable > 0 && selectedSelectable < _selectableItems.length;
  }

  void _toggleItem(int id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _toggleSelectAll() {
    setState(() {
      if (_areAllSelectableSelected) {
        _selectedIds.clear();
      } else {
        _selectedIds
          ..clear()
          ..addAll(_selectableItems.map((i) => i.id!));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final firstItem = widget.items.first;
    final prescriptionDate = firstItem.prescription?.prescriptionDate?.formattedDate ?? '-';
    final doctorName = firstItem.doctor?.fullName ?? context.l10n.rxGroup_unknownDoctorFallback;

    return Container(
      decoration: BoxDecoration(
        color: MedColors.surface,
        borderRadius: MedRadius.lgAll,
        border: Border.all(color: MedColors.border),
        boxShadow: MedShadows.sm,
      ),
      child: ClipRRect(
        borderRadius: MedRadius.lgAll,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _RxHeader(
              prescriptionId: widget.prescriptionId,
              prescriptionDate: prescriptionDate,
              doctorName: doctorName,
              itemCount: widget.items.length,
              isExpanded: _isExpanded,
              onTap: () => setState(() => _isExpanded = !_isExpanded),
            ),
            if (_isExpanded) ...[
              if (_interactive && _selectableItems.isNotEmpty)
                _SelectAllBar(
                  isAllSelected: _areAllSelectableSelected,
                  isPartial: _hasPartialSelection,
                  selectableCount: _selectableItems.length,
                  onTap: _toggleSelectAll,
                ),
              ...widget.items.map((item) {
                final canModifyTag = widget.canOverrideRfidLock || (item.status?.canModifyRfid ?? false);
                return _RxDrugBlock(
                  item: item,
                  isSelected: _selectedIds.contains(item.id),
                  interactive: _interactive,
                  onCheckTap: () => _toggleItem(item.id!),
                  onRfidTap: (widget.onRfidTap != null && canModifyTag) ? () => widget.onRfidTap!(item) : null,
                  onRfidDelete: (widget.onRfidDelete != null && canModifyTag) ? () => widget.onRfidDelete!(item) : null,
                );
              }),
              if (_interactive && _hasSelection)
                _RxActionBar(
                  selectedCount: _selectedIds.length,
                  canApprove: _canApproveSelected,
                  canReject: _canRejectSelected,
                  canCancel: _canCancelSelected,
                  canRejectAfterApprove: _canRejectAfterApprovedSelected,
                  onApprove: widget.onApprove != null && _canApproveSelected
                      ? () async {
                          await widget.onApprove!(_selectedItems);
                          setState(() => _selectedIds.clear());
                        }
                      : null,
                  onReject: widget.onReject != null && _canRejectSelected
                      ? () async {
                          await widget.onReject!(_selectedItems);
                          setState(() => _selectedIds.clear());
                        }
                      : null,
                  onCancel: widget.onCancel != null && _canCancelSelected
                      ? () async {
                          await widget.onCancel!(_selectedItems);
                          setState(() => _selectedIds.clear());
                        }
                      : null,
                  onRejectAfterApprove: widget.onRejectAfterApprove != null && _canRejectAfterApprovedSelected
                      ? () async {
                          await widget.onRejectAfterApprove!(_selectedItems);
                          setState(() => _selectedIds.clear());
                        }
                      : null,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RxHeader extends StatelessWidget {
  const _RxHeader({
    required this.prescriptionId,
    required this.prescriptionDate,
    required this.doctorName,
    required this.itemCount,
    required this.isExpanded,
    required this.onTap,
  });

  final int prescriptionId;
  final String prescriptionDate;
  final String doctorName;
  final int itemCount;
  final bool isExpanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: MedColors.surface2,
          border: Border(bottom: BorderSide(color: isExpanded ? MedColors.border2 : Colors.transparent)),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(color: MedColors.blueLight, borderRadius: MedRadius.mdAll),
              child: Icon(PhosphorIcons.notepad(PhosphorIconsStyle.duotone), size: 16, color: MedColors.blue),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.rxGroup_headerTitle(prescriptionId),
                    style: MedTextStyles.monoMd(color: MedColors.text, weight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    context.l10n.rxGroup_headerSubtitle(doctorName, prescriptionDate),
                    style: MedTextStyles.monoSm(),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: MedColors.surface3,
                borderRadius: MedRadius.xlAll,
                border: Border.all(color: MedColors.border),
              ),
              child: Text(context.l10n.rxGroup_itemCountBadge(itemCount), style: MedTextStyles.monoXs()),
            ),
            const SizedBox(width: 8),
            Icon(
              isExpanded
                  ? PhosphorIcons.caretUp(PhosphorIconsStyle.bold)
                  : PhosphorIcons.caretDown(PhosphorIconsStyle.bold),
              size: 13,
              color: MedColors.text4,
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectAllBar extends StatelessWidget {
  const _SelectAllBar({
    required this.isAllSelected,
    required this.isPartial,
    required this.selectableCount,
    required this.onTap,
  });

  final bool isAllSelected;
  final bool isPartial;
  final int selectableCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: MedColors.surface,
          border: Border(bottom: BorderSide(color: MedColors.border2)),
        ),
        child: Row(
          children: [
            MedCheckbox(
              value: isAllSelected,
              partial: isPartial && !isAllSelected,
              size: MedCheckboxSize.sm,
              onChanged: (_) => onTap(),
            ),
            const SizedBox(width: 10),
            Text(
              isAllSelected ? context.l10n.common_deselectAllButton : context.l10n.common_selectAllButton,
              style: MedTextStyles.bodySm(color: MedColors.blue, weight: FontWeight.w600),
            ),
            const Spacer(),
            Text(
              context.l10n.rxGroup_selectableCountLabel(selectableCount),
              style: MedTextStyles.monoXs(color: MedColors.text3),
            ),
          ],
        ),
      ),
    );
  }
}

class _RxDrugBlock extends StatefulWidget {
  const _RxDrugBlock({
    required this.item,
    required this.isSelected,
    required this.interactive,
    required this.onCheckTap,
    this.onRfidTap,
    this.onRfidDelete,
  });

  final PrescriptionItem item;
  final bool isSelected;
  final bool interactive;
  final VoidCallback onCheckTap;
  final Future<void> Function()? onRfidTap;
  final Future<void> Function()? onRfidDelete;

  @override
  State<_RxDrugBlock> createState() => _RxDrugBlockState();
}

class _RxDrugBlockState extends State<_RxDrugBlock> {
  bool _isAccordionOpen = false;
  bool _isRfidLoading = false;
  bool _isLoading = false;
  bool _hasLoaded = false;
  List<PrescriptionItemMovement>? _movements;

  bool get _isSelectable =>
      widget.interactive &&
      ((widget.item.status?.canApprove ?? false) ||
          (widget.item.status?.canReject ?? false) ||
          (widget.item.status?.canCancel ?? false) ||
          (widget.item.status?.canFill ?? false));

  Future<void> _loadMovements() async {
    if (_hasLoaded || _isLoading) return;
    final itemId = widget.item.id;
    if (itemId == null) return;

    setState(() => _isLoading = true);

    final useCase = context.read<GetPrescriptionItemMovementsUseCase>();
    final result = await useCase.call(itemId);

    result.when(
      ok: (movements) => setState(() {
        _movements = movements;
        _isLoading = false;
        _hasLoaded = true;
      }),
      error: (_) => setState(() => _isLoading = false),
    );
  }

  Future<void> _handleRfidTap() async {
    if (_isRfidLoading || widget.onRfidTap == null) return;
    setState(() => _isRfidLoading = true);
    try {
      await widget.onRfidTap!();
    } finally {
      if (mounted) setState(() => _isRfidLoading = false);
    }
  }

  Future<void> _handleRfidDelete() async {
    if (_isRfidLoading || widget.onRfidDelete == null) return;
    setState(() => _isRfidLoading = true);
    try {
      await widget.onRfidDelete!();
    } finally {
      if (mounted) setState(() => _isRfidLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: MedColors.border2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DrugRow(
            item: widget.item,
            isSelected: widget.isSelected,
            isSelectable: _isSelectable,
            isAccordionOpen: _isAccordionOpen,
            interactive: widget.interactive,
            onCheckTap: () {
              widget.onCheckTap();
              if (!_isAccordionOpen) {
                setState(() => _isAccordionOpen = true);
              }
            },
            onRowTap: () {
              setState(() => _isAccordionOpen = !_isAccordionOpen);
            },
          ),
          if (_isAccordionOpen)
            _DrugAccordion(
              item: widget.item,
              isRfidLoading: _isRfidLoading,
              movements: _movements,
              isLoadingMovements: _isLoading,
              hasLoadedMovements: _hasLoaded,
              onRfidTap: widget.onRfidTap != null ? _handleRfidTap : null,
              onRfidDelete: widget.onRfidDelete != null ? _handleRfidDelete : null,
              onLoadMovements: _loadMovements,
            ),
        ],
      ),
    );
  }
}

class _DrugRow extends StatelessWidget {
  const _DrugRow({
    required this.item,
    required this.isSelected,
    required this.isSelectable,
    required this.isAccordionOpen,
    required this.interactive,
    required this.onCheckTap,
    required this.onRowTap,
  });

  final PrescriptionItem item;
  final bool isSelected;
  final bool isSelectable;
  final bool isAccordionOpen;
  final bool interactive;
  final VoidCallback onCheckTap;
  final VoidCallback onRowTap;

  @override
  Widget build(BuildContext context) {
    Color bgColor = Colors.transparent;
    if (isSelected && isAccordionOpen) {
      bgColor = MedColors.blueLight.withValues(alpha: 0.8);
    } else if (isSelected) {
      bgColor = MedColors.blueLight;
    } else if (isAccordionOpen) {
      bgColor = MedColors.surface3;
    }

    return Container(
      color: bgColor,
      child: Row(
        children: [
          if (interactive)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
              child: MedCheckbox(
                value: isSelected,
                size: MedCheckboxSize.sm,
                enabled: isSelectable,
                onChanged: (_) => onCheckTap(),
              ),
            )
          else
            const SizedBox(width: 14),
          Expanded(
            child: InkWell(
              onTap: onRowTap,
              child: Padding(
                padding: const EdgeInsets.only(right: 14, top: 10, bottom: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.medicine?.name ?? context.l10n.common_unknownName,
                            style: MedTextStyles.bodyMd(
                              color: isSelected ? MedColors.blue : MedColors.text,
                              weight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (item.medicine?.barcode != null)
                            Text(item.medicine!.barcode!, style: MedTextStyles.monoXs()),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    DoseChip(item: item),
                    const SizedBox(width: 8),
                    if (item.time != null) ...[TimeChip(time: item.time!), const SizedBox(width: 6)],
                    if (item.status != null) MedRxMovementChip(status: item.status!),
                    const SizedBox(width: 8),
                    Icon(
                      isAccordionOpen
                          ? PhosphorIcons.caretUp(PhosphorIconsStyle.bold)
                          : PhosphorIcons.caretDown(PhosphorIconsStyle.bold),
                      size: 12,
                      color: isAccordionOpen ? MedColors.blue : MedColors.text4,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DrugAccordion extends StatelessWidget {
  const _DrugAccordion({
    required this.item,
    required this.isRfidLoading,
    required this.isLoadingMovements,
    required this.hasLoadedMovements,
    required this.onLoadMovements,
    this.movements,
    this.onRfidTap,
    this.onRfidDelete,
  });

  final PrescriptionItem item;
  final bool isRfidLoading;
  final bool isLoadingMovements;
  final bool hasLoadedMovements;
  final VoidCallback onLoadMovements;
  final List<PrescriptionItemMovement>? movements;
  final VoidCallback? onRfidTap;
  final VoidCallback? onRfidDelete;

  bool get _needRfid {
    if (item.medicine == null) return false;
    if (!item.medicine!.isDrug) return false;
    return (item.medicine as Drug).isRfidEnable;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: MedColors.border2)),
      ),
      padding: const EdgeInsets.fromLTRB(50, 12, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_needRfid) ...[
            _RfidSection(item: item, onTap: onRfidTap, isLoading: isRfidLoading, onDelete: onRfidDelete),
            const SizedBox(height: 12),
          ],
          RxMovementBlock(
            lastMovement: item.lastMovement,
            medicine: item.medicine,
            movements: movements,
            isLoading: isLoadingMovements,
          ),
          if (!hasLoadedMovements && !isLoadingMovements && (item.lastMovement?.type.canShowHistory ?? false)) ...[
            const SizedBox(height: MedSpacing.md),
            Center(
              child: TextButton(
                onPressed: onLoadMovements,
                child: Text(context.l10n.movement_showAll, style: MedTextStyles.bodySm(color: MedColors.text3)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RfidSection extends StatelessWidget {
  const _RfidSection({required this.item, required this.isLoading, this.onTap, this.onDelete});

  final PrescriptionItem item;
  final bool isLoading;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  bool get _hasTag => item.rfidTag != null;
  bool get _isEditable => onTap != null || onDelete != null;
  // Yeşil "aktif" görünüm yalnızca etiket VAR ve düzenlenebilir durumdaysa.
  bool get _showActiveState => _hasTag && _isEditable;

  String get _tagDisplay => item.rfidTag ?? '—';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _showActiveState ? MedColors.greenLight : MedColors.surface,
        borderRadius: MedRadius.mdAll,
        border: Border.all(
          color: _showActiveState ? MedColors.green : MedColors.border,
          width: _showActiveState ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: _showActiveState ? MedColors.green.withValues(alpha: 0.15) : MedColors.surface3,
              borderRadius: MedRadius.smAll,
            ),
            child: Icon(
              PhosphorIcons.tag(PhosphorIconsStyle.duotone),
              size: 15,
              color: _showActiveState ? MedColors.green : MedColors.text3,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.l10n.rxGroup_rfidTagLabel, style: MedTextStyles.monoXs(color: MedColors.text3)),
                const SizedBox(height: 2),
                if (isLoading)
                  Text(context.l10n.rxGroup_rfidTagLoadingLabel, style: MedTextStyles.monoMd(color: MedColors.text4))
                else
                  Text(
                    _hasTag ? _tagDisplay : context.l10n.rxGroup_rfidTagUnassignedLabel,
                    style: MedTextStyles.monoMd(
                      color: _showActiveState ? MedColors.green : (_hasTag ? MedColors.text2 : MedColors.text4),
                    ),
                  ),
              ],
            ),
          ),
          if (isLoading)
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: _showActiveState ? MedColors.green : MedColors.blue,
              ),
            )
          else ...[
            if (_hasTag && onDelete != null) ...[
              MedButton(
                label: context.l10n.common_deleteTooltip,
                variant: MedButtonVariant.danger,
                size: MedButtonSize.sm,
                onPressed: onDelete!,
              ),
              const SizedBox(width: 6),
            ],
            if (onTap != null)
              MedButton(
                label: _hasTag ? context.l10n.rxGroup_rfidChangeButton : context.l10n.rxGroup_rfidAssignButton,
                size: MedButtonSize.sm,
                variant: _hasTag ? MedButtonVariant.primary : MedButtonVariant.success,

                onPressed: onTap!,
              ),
          ],
        ],
      ),
    );
  }
}

class _RxActionBar extends StatelessWidget {
  const _RxActionBar({
    required this.selectedCount,
    required this.canApprove,
    required this.canReject,
    required this.canCancel,
    required this.canRejectAfterApprove,
    this.onApprove,
    this.onReject,
    this.onCancel,
    this.onRejectAfterApprove,
  });

  final int selectedCount;
  final bool canApprove;
  final bool canReject;
  final bool canCancel;
  final bool canRejectAfterApprove;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onCancel;
  final VoidCallback? onRejectAfterApprove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: MedColors.surface2,
        border: Border(top: BorderSide(color: MedColors.border)),
      ),
      child: Row(
        children: [
          Text(context.l10n.rxGroup_selectedCountBar(selectedCount), style: MedTextStyles.monoSm()),
          const Spacer(),
          if (canApprove && onApprove != null) ...[
            _ActionChip(
              label: context.l10n.rxGroup_approveAction,
              icon: PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
              color: MedColors.green,
              bgColor: MedColors.greenLight,
              onTap: onApprove!,
            ),
            const SizedBox(width: 8),
          ],
          if (canReject && onReject != null) ...[
            _ActionChip(
              label: context.l10n.rxGroup_rejectAction,
              icon: PhosphorIcons.xCircle(PhosphorIconsStyle.fill),
              color: MedColors.red,
              bgColor: MedColors.redLight,
              onTap: onReject!,
            ),
            const SizedBox(width: 8),
          ],
          if (canCancel && onCancel != null)
            _ActionChip(
              label: context.l10n.common_cancelButton,
              icon: PhosphorIcons.prohibit(PhosphorIconsStyle.fill),
              color: MedColors.amber,
              bgColor: MedColors.amberLight,
              onTap: onCancel!,
            ),

          if (canRejectAfterApprove && onRejectAfterApprove != null) ...[
            _ActionChip(
              label: context.l10n.rxGroup_rejectAction,
              icon: PhosphorIcons.xCircle(PhosphorIconsStyle.fill),
              color: MedColors.red,
              bgColor: MedColors.redLight,
              onTap: onRejectAfterApprove!,
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: MedRadius.mdAll,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: MedRadius.mdAll,
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 5),
            Text(
              label,
              style: MedTextStyles.monoSm(color: color, weight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
