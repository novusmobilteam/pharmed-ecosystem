import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../features/medicine/domain/entity/medicine.dart';
import '../../features/prescription/domain/entity/prescription_item.dart';
import '../core.dart';

/// Reçete grup kartı.
///
/// [interactive] = true  → Reçete ekranı: satır seçimi + toplu onay/iptal/red
/// [interactive] = false → Hasta istemleri ekranı: salt görüntüleme
class PrescriptionGroupCard extends StatefulWidget {
  final int prescriptionId;
  final List<PrescriptionItem> items;
  final bool interactive;

  /// Seçili itemlar onaylandığında
  final Future<void> Function(List<PrescriptionItem> items)? onApprove;

  /// Seçili itemlar reddedildiğinde
  final Future<void> Function(List<PrescriptionItem> items)? onReject;

  /// Seçili itemlar iptal edildiğinde
  final Future<void> Function(List<PrescriptionItem> items)? onCancel;

  const PrescriptionGroupCard({
    super.key,
    required this.prescriptionId,
    required this.items,
    this.interactive = false,
    this.onApprove,
    this.onReject,
    this.onCancel,
  });

  @override
  State<PrescriptionGroupCard> createState() => _PrescriptionGroupCardState();
}

class _PrescriptionGroupCardState extends State<PrescriptionGroupCard> {
  final Set<int> _selectedIds = {};
  bool _isExpanded = true;

  // Sadece onay bekleyenleri seçilebilir say
  List<PrescriptionItem> get _selectableItems => widget.items.where((i) => i.status?.isSelectable ?? false).toList();
  List<PrescriptionItem> get _selectedItems => _selectableItems.where((i) => _selectedIds.contains(i.id)).toList();

  bool get _allSelected => _selectableItems.isNotEmpty && _selectableItems.every((i) => _selectedIds.contains(i.id));
  // Tüm itemler onaylandıysa "Onayla" butonu görünmeyecek
  bool get _approvedAll =>
      _selectableItems.isNotEmpty && _selectableItems.every((i) => i.status == PrescriptionStatus.purchasePending);
  // Tüm itemler reddedildiye "Reddet" butonu görünmeyecek
  bool get _rejectedAll =>
      _selectableItems.isNotEmpty && _selectableItems.every((i) => i.status == PrescriptionStatus.rejected);
  // Tüm itemler iptal edildiyse "İptal Et" butonu görünmeyecek
  bool get _cancelledAll =>
      _selectableItems.isNotEmpty && _selectableItems.every((i) => i.status == PrescriptionStatus.cancelled);

  bool get _hasSelection => _selectedIds.isNotEmpty;

  /// Her zaman gösterilecek sabit kolonlar (sıralı).
  static const List<PrescriptionColumn> _fixedColumns = [
    PrescriptionColumn.medicine,
    PrescriptionColumn.dose,
    PrescriptionColumn.applicationUser,
    PrescriptionColumn.appliedQuantity,
    PrescriptionColumn.applicationDate,
  ];

  /// İade / Fire / İmha kolonları — en az bir item'da dolu ise eklenir.
  static const List<(PrescriptionColumn col, bool Function(PrescriptionItem) check)> _conditionalColumns = [
    (PrescriptionColumn.returnUser, _hasReturnUser),
    (PrescriptionColumn.returnQuantity, _hasReturnQuantity),
    (PrescriptionColumn.returnDate, _hasReturnDate),
    (PrescriptionColumn.wastageUser, _hasWastageUser),
    (PrescriptionColumn.wastageDate, _hasWastageDate),
    (PrescriptionColumn.destructionUser, _hasDestructionUser),
    (PrescriptionColumn.destructionDate, _hasDestructionDate),
  ];

  static bool _hasReturnUser(PrescriptionItem i) => i.returnUser != null;
  static bool _hasReturnQuantity(PrescriptionItem i) => i.returnQuantity != null;
  static bool _hasReturnDate(PrescriptionItem i) => i.returnDate != null;
  static bool _hasWastageUser(PrescriptionItem i) => i.wastageUser != null;
  static bool _hasWastageDate(PrescriptionItem i) => i.wastageDate != null;
  static bool _hasDestructionUser(PrescriptionItem i) => i.destructionUser != null;
  static bool _hasDestructionDate(PrescriptionItem i) => i.destructionDate != null;

  List<PrescriptionColumn> get _visibleColumns {
    final cols = [..._fixedColumns];

    for (final (col, check) in _conditionalColumns) {
      if (widget.items.any(check)) cols.add(col);
    }

    cols.add(PrescriptionColumn.status);
    return cols;
  }

  void _toggleItem(PrescriptionItem item) {
    setState(() {
      if (_selectedIds.contains(item.id)) {
        _selectedIds.remove(item.id);
      } else {
        _selectedIds.add(item.id!);
      }
    });
  }

  void _toggleAll() {
    setState(() {
      if (_allSelected) {
        _selectedIds.clear();
      } else {
        _selectedIds.addAll(_selectableItems.map((i) => i.id!));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final firstItem = widget.items.first;
    final prescriptionDate = firstItem.prescription?.prescriptionDate?.formattedDate ?? '-';
    final doctorName = firstItem.doctor?.fullName ?? 'Bilinmiyor';
    final colorScheme = context.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Header(
              prescriptionId: widget.prescriptionId,
              prescriptionDate: prescriptionDate,
              doctorName: doctorName,
              isExpanded: _isExpanded,
              itemCount: widget.items.length,
              onTap: () => setState(() => _isExpanded = !_isExpanded),
            ),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 220),
              crossFadeState: _isExpanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
              firstChild: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _TableHeader(
                    interactive: widget.interactive,
                    allSelected: _allSelected,
                    hasItems: _selectableItems.isNotEmpty,
                    onToggleAll: _toggleAll,
                    visibleColumns: _visibleColumns,
                  ),

                  // İlaç satırları
                  ...widget.items.map(
                    (item) => _ItemRow(
                      item: item,
                      isSelected: _selectedIds.contains(item.id),
                      interactive: widget.interactive,
                      onTap: () => _toggleItem(item),
                      visibleColumns: _visibleColumns,
                    ),
                  ),

                  if (widget.interactive && _hasSelection)
                    _ActionBar(
                      selectedCount: _selectedIds.length,
                      approvedAll: _approvedAll,
                      rejectedAll: _rejectedAll,
                      cancelledAll: _cancelledAll,
                      onApprove: widget.onApprove != null
                          ? () async {
                              await widget.onApprove!(_selectedItems);
                              setState(() => _selectedIds.clear());
                            }
                          : null,
                      onReject: widget.onReject != null
                          ? () async {
                              await widget.onReject!(_selectedItems);
                              setState(() => _selectedIds.clear());
                            }
                          : null,
                      onCancel: widget.onCancel != null
                          ? () async {
                              await widget.onCancel!(_selectedItems);
                              setState(() => _selectedIds.clear());
                            }
                          : null,
                    ),
                ],
              ),
              secondChild: const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final int prescriptionId;
  final String prescriptionDate;
  final String doctorName;
  final bool isExpanded;
  final int itemCount;
  final VoidCallback onTap;

  const _Header({
    required this.prescriptionId,
    required this.prescriptionDate,
    required this.doctorName,
    required this.isExpanded,
    required this.itemCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest,
          border: Border(
            bottom: BorderSide(
              color: isExpanded ? colorScheme.outlineVariant.withValues(alpha: 0.3) : Colors.transparent,
            ),
          ),
        ),
        child: Row(
          children: [
            // Sol: Reçete ikonu
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                PhosphorIcons.notepad(PhosphorIconsStyle.duotone),
                size: 18,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),

            // Orta: Bilgiler
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Reçete #$prescriptionId',
                        style: context.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '$itemCount kalem',
                          style: context.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSecondaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        PhosphorIcons.calendar(PhosphorIconsStyle.regular),
                        size: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        prescriptionDate,
                        style: context.textTheme.bodyMedium,
                      ),
                      const SizedBox(width: 10),
                      Icon(
                        PhosphorIcons.stethoscope(PhosphorIconsStyle.regular),
                        size: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          doctorName,
                          style: context.textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Sağ: Expand ikonu
            AnimatedRotation(
              turns: isExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                PhosphorIcons.caretDown(PhosphorIconsStyle.bold),
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  final bool interactive;
  final bool allSelected;
  final bool hasItems;
  final List<PrescriptionColumn> visibleColumns;
  final VoidCallback onToggleAll;

  const _TableHeader({
    required this.interactive,
    required this.allSelected,
    required this.hasItems,
    required this.visibleColumns,
    required this.onToggleAll,
  });

  @override
  Widget build(BuildContext context) {
    final style = context.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w900);

    return Container(
      padding: EdgeInsets.only(
        left: interactive ? 8 : 16,
        right: 16,
        top: 8,
        bottom: 8,
      ),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        border: Border(
          bottom: BorderSide(
            color: context.colorScheme.outlineVariant.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          if (interactive)
            SizedBox(
              width: 36,
              child: Checkbox(
                value: allSelected,
                tristate: false,
                onChanged: hasItems ? (_) => onToggleAll() : null,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ...visibleColumns.map(
            (col) => Expanded(
              flex: col.flex,
              child: Text(
                col.label,
                style: style,
                textAlign: col == PrescriptionColumn.status ? TextAlign.center : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  final PrescriptionItem item;
  final bool isSelected;
  final bool interactive;
  final List<PrescriptionColumn> visibleColumns;
  final VoidCallback onTap;

  const _ItemRow({
    required this.item,
    required this.isSelected,
    required this.interactive,
    required this.visibleColumns,
    required this.onTap,
  });

  String _doseText() => '${item.dosePiece?.formatFractional ?? '-'} ${item.medicine?.operationUnit ?? 'Adet'}';

  /// Her kolon için gösterilecek değeri döndürür.
  /// [medicine] kolonunu ayrıca handle ediyoruz (widget döndürüyor),
  /// bu yüzden o kolon burada boş string — özel widget ile render edilecek.
  String _valueFor(PrescriptionColumn col) => switch (col) {
        PrescriptionColumn.dose => _doseText(),
        PrescriptionColumn.applicationUser => item.applicationUser?.fullName ?? '-',
        PrescriptionColumn.appliedQuantity => _doseText(), // TODO: gerçek applied quantity
        PrescriptionColumn.applicationDate => item.applicationDate?.formattedDateTime ?? '-',
        PrescriptionColumn.returnUser => item.returnUser?.fullName ?? '-',
        PrescriptionColumn.returnQuantity => item.returnQuantity != null
            ? '${item.returnQuantity!.formatFractional} ${item.medicine?.operationUnit ?? 'Adet'}'
            : '-',
        PrescriptionColumn.returnDate => item.returnDate?.formattedDateTime ?? '-',
        PrescriptionColumn.wastageUser => item.wastageUser?.fullName ?? '-',
        PrescriptionColumn.wastageDate => item.wastageDate?.formattedDateTime ?? '-',
        PrescriptionColumn.destructionUser => item.destructionUser?.fullName ?? '-',
        PrescriptionColumn.destructionDate => item.destructionDate?.formattedDateTime ?? '-',
        _ => '',
      };

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final status = item.status;
    final bool isSelectable = interactive && (item.status?.isSelectable ?? false);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: isSelected ? colorScheme.primary.withValues(alpha: 0.06) : Colors.transparent,
      ),
      child: InkWell(
        onTap: () {
          if (isSelectable) {
            onTap();
          }
        },
        child: Padding(
          padding: EdgeInsets.only(
            left: interactive ? 8 : 13,
            right: 16,
            top: 10,
            bottom: 10,
          ),
          child: Row(
            children: [
              if (interactive)
                SizedBox(
                  width: 36,
                  child: Checkbox(
                    value: isSelected,
                    onChanged: isSelectable ? (_) => onTap() : null,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ...visibleColumns.map((col) {
                // İlaç kolonu özel widget
                if (col == PrescriptionColumn.medicine) {
                  return Expanded(
                    flex: col.flex,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.medicine?.name ?? 'İsimsiz',
                          style: context.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isSelected ? colorScheme.primary : null,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (item.medicine?.barcode != null)
                          Text(
                            item.medicine!.barcode!,
                            style: context.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              letterSpacing: 0.5,
                            ),
                          ),
                      ],
                    ),
                  );
                }

                // Durum kolonu özel widget
                if (col == PrescriptionColumn.status) {
                  return Expanded(
                    flex: col.flex,
                    child: status != null ? _StatusBadge(status: status) : const SizedBox.shrink(),
                  );
                }

                // Diğer tüm kolonlar
                return Expanded(
                  flex: col.flex,
                  child: Text(
                    _valueFor(col),
                    style: context.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

// ───

class _StatusBadge extends StatelessWidget {
  final PrescriptionStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: status.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 14, color: status.color),
          SizedBox(width: 4),
          Flexible(
            child: Text(
              status.label,
              style: context.textTheme.labelMedium?.copyWith(
                color: status.color,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  final int selectedCount;
  final bool approvedAll;
  final bool rejectedAll;
  final bool cancelledAll;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onCancel;

  const _ActionBar({
    required this.selectedCount,
    required this.approvedAll,
    required this.rejectedAll,
    required this.cancelledAll,
    this.onApprove,
    this.onReject,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest,
          border: Border(
            top: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
        ),
        child: Row(
          children: [
            const Spacer(),

            // Onayla
            if (onApprove != null && !approvedAll)
              _ActionButton(
                label: 'Onayla',
                icon: PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
                color: Colors.green,
                onTap: onApprove!,
              ),
            if (onApprove != null && (onReject != null || onCancel != null)) const SizedBox(width: 8),

            // Reddet
            if (onReject != null && !rejectedAll)
              _ActionButton(
                label: 'Reddet',
                icon: PhosphorIcons.xCircle(PhosphorIconsStyle.fill),
                color: Colors.red,
                onTap: onReject!,
              ),
            if (onReject != null && onCancel != null) const SizedBox(width: 8),

            // İptal
            if (onCancel != null && !cancelledAll)
              _ActionButton(
                label: 'İptal',
                icon: PhosphorIcons.prohibit(PhosphorIconsStyle.fill),
                color: Colors.amber,
                onTap: onCancel!,
              ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 5),
            Text(
              label,
              style: context.textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
