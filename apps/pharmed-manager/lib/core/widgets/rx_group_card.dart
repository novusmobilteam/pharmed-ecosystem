import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../core.dart';

// [SWREQ-MGR-RX-006] [IEC 62304 §5.5]
// Reçete grup kartı — C varyantı tasarım, accordion detay + RFID altyapısı.
// [interactive] = true  → checkbox seçim + toplu onay/iptal/red
// [interactive] = false → salt görüntüleme
// Sınıf: Class B

class RxGroupCard extends StatefulWidget {
  final int prescriptionId;
  final List<PrescriptionItem> items;
  final bool interactive;

  final Future<void> Function(List<PrescriptionItem>)? onApprove;
  final Future<void> Function(List<PrescriptionItem>)? onReject;
  final Future<void> Function(List<PrescriptionItem>)? onCancel;

  /// RFID etiket atama/değiştirme callback'i.
  /// Akış netleşince implement edilecek — şimdilik placeholder.
  final Future<void> Function(PrescriptionItem item)? onRfidTap;
  final Future<void> Function(PrescriptionItem item)? onRfidDelete;

  const RxGroupCard({
    super.key,
    required this.prescriptionId,
    required this.items,
    this.interactive = false,
    this.onApprove,
    this.onReject,
    this.onCancel,
    this.onRfidTap,
    this.onRfidDelete,
  });

  @override
  State<RxGroupCard> createState() => _RxGroupCardState();
}

class _RxGroupCardState extends State<RxGroupCard> {
  final Set<int> _selectedIds = {};
  bool _isExpanded = true;

  List<PrescriptionItem> get _selectableItems => widget.items.where((i) => i.status?.isSelectable ?? false).toList();
  List<PrescriptionItem> get _selectedItems => _selectableItems.where((i) => _selectedIds.contains(i.id)).toList();

  bool get _hasSelection => _selectedIds.isNotEmpty;
  bool get _approvedAll =>
      _selectableItems.isNotEmpty && _selectableItems.every((i) => i.status == PrescriptionStatus.purchasePending);
  bool get _rejectedAll =>
      _selectableItems.isNotEmpty && _selectableItems.every((i) => i.status == PrescriptionStatus.rejected);
  bool get _cancelledAll =>
      _selectableItems.isNotEmpty && _selectableItems.every((i) => i.status == PrescriptionStatus.cancelled);

  void _toggleItem(int id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final firstItem = widget.items.first;
    final prescriptionDate = firstItem.prescription?.prescriptionDate?.formattedDate ?? '-';
    final doctorName = firstItem.doctor?.fullName ?? 'Bilinmiyor';

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
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 220),
              crossFadeState: _isExpanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
              firstChild: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // İlaç blokları
                  ...widget.items.map(
                    (item) => _RxDrugBlock(
                      item: item,
                      isSelected: _selectedIds.contains(item.id),
                      interactive: widget.interactive,
                      onCheckTap: () => _toggleItem(item.id!),
                      onRfidTap: widget.onRfidTap != null ? () => widget.onRfidTap!(item) : null,
                      onRfidDelete: widget.onRfidDelete != null ? () => widget.onRfidDelete!(item) : null,
                    ),
                  ),
                  // Action bar — seçim varsa görünür
                  if (widget.interactive && _hasSelection)
                    _RxActionBar(
                      selectedCount: _selectedIds.length,
                      approvedAll: _approvedAll,
                      rejectedAll: _rejectedAll,
                      cancelledAll: _cancelledAll,
                      onApprove: widget.onApprove != null && !_approvedAll
                          ? () async {
                              await widget.onApprove!(_selectedItems);
                              setState(() => _selectedIds.clear());
                            }
                          : null,
                      onReject: widget.onReject != null && !_rejectedAll
                          ? () async {
                              await widget.onReject!(_selectedItems);
                              setState(() => _selectedIds.clear());
                            }
                          : null,
                      onCancel: widget.onCancel != null && !_cancelledAll
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

class _RxHeader extends StatelessWidget {
  final int prescriptionId;
  final String prescriptionDate;
  final String doctorName;
  final int itemCount;
  final bool isExpanded;
  final VoidCallback onTap;

  const _RxHeader({
    required this.prescriptionId,
    required this.prescriptionDate,
    required this.doctorName,
    required this.itemCount,
    required this.isExpanded,
    required this.onTap,
  });

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
            // İkon
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(color: MedColors.blueLight, borderRadius: MedRadius.mdAll),
              child: Icon(PhosphorIcons.notepad(PhosphorIconsStyle.duotone), size: 16, color: MedColors.blue),
            ),
            const SizedBox(width: 10),

            // Reçete no + doktor/tarih
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reçete #$prescriptionId',
                    style: MedTextStyles.monoMd(color: MedColors.text, weight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text('$doctorName · $prescriptionDate', style: MedTextStyles.monoSm()),
                ],
              ),
            ),

            // Kalem sayısı chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: MedColors.surface3,
                borderRadius: MedRadius.xlAll,
                border: Border.all(color: MedColors.border),
              ),
              child: Text('$itemCount kalem', style: MedTextStyles.monoXs()),
            ),
            const SizedBox(width: 8),

            // Chevron
            AnimatedRotation(
              turns: isExpanded ? 0 : -0.25,
              duration: const Duration(milliseconds: 200),
              child: Icon(PhosphorIcons.caretDown(PhosphorIconsStyle.bold), size: 13, color: MedColors.text4),
            ),
          ],
        ),
      ),
    );
  }
}

class _RxDrugBlock extends StatefulWidget {
  final PrescriptionItem item;
  final bool isSelected;
  final bool interactive;
  final VoidCallback onCheckTap;
  final Future<void> Function()? onRfidTap;
  final Future<void> Function()? onRfidDelete;

  const _RxDrugBlock({
    required this.item,
    required this.isSelected,
    required this.interactive,
    required this.onCheckTap,
    this.onRfidTap,
    this.onRfidDelete,
  });

  @override
  State<_RxDrugBlock> createState() => _RxDrugBlockState();
}

class _RxDrugBlockState extends State<_RxDrugBlock> {
  bool _isAccordionOpen = false;
  bool _isRfidLoading = false;

  bool get _isSelectable => widget.interactive && (widget.item.status?.isSelectable ?? false);

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
            onCheckTap: widget.onCheckTap,
            onRowTap: () => setState(() => _isAccordionOpen = !_isAccordionOpen),
          ),
          _DrugAccordion(
            item: widget.item,
            isOpen: _isAccordionOpen,
            isRfidLoading: _isRfidLoading,
            onRfidTap: widget.onRfidTap != null ? _handleRfidTap : null,
            onRfidDelete: widget.onRfidDelete != null ? _handleRfidDelete : null,
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

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      color: bgColor,
      child: Row(
        children: [
          // Checkbox bölgesi — sadece burası seçimi toggle eder
          if (interactive)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: isSelectable ? onCheckTap : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: _Checkbox(isSelected: isSelected, isSelectable: isSelectable),
              ),
            )
          else
            const SizedBox(width: 14),

          // Satırın geri kalanı — accordion toggle
          Expanded(
            child: InkWell(
              onTap: onRowTap,
              child: Padding(
                padding: EdgeInsets.only(left: interactive ? 0 : 0, right: 14, top: 10, bottom: 10),
                child: Row(
                  children: [
                    // İlaç adı + barkod + saat
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  item.medicine?.name ?? 'İsimsiz',
                                  style: MedTextStyles.bodyMd(
                                    color: isSelected ? MedColors.blue : MedColors.text,
                                    weight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),

                          if (item.medicine?.barcode != null)
                            Text(item.medicine!.barcode!, style: MedTextStyles.monoXs()),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),

                    if (item.time != null) ...[_TimeChip(time: item.time!), const SizedBox(width: 6)],

                    // Doz chip
                    _DoseChip(item: item),
                    const SizedBox(width: 8),

                    // Durum chip
                    if (item.status != null) _StatusChip(status: item.status!),
                    const SizedBox(width: 8),

                    // Expand ikonu
                    AnimatedRotation(
                      turns: isAccordionOpen ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        PhosphorIcons.caretDown(PhosphorIconsStyle.bold),
                        size: 12,
                        color: isAccordionOpen ? MedColors.blue : MedColors.text4,
                      ),
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
    required this.isOpen,
    required this.isRfidLoading,
    this.onRfidTap,
    this.onRfidDelete,
  });

  final PrescriptionItem item;
  final bool isOpen;
  final bool isRfidLoading;
  final VoidCallback? onRfidTap;
  final VoidCallback? onRfidDelete;

  bool get _needRfid {
    if (item.medicine == null) return false;
    if (!item.medicine!.isDrug) return false;
    return (item.medicine as Drug).isRfidEnable;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 240),
      crossFadeState: isOpen ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      firstChild: Container(
        decoration: BoxDecoration(
          //color: MedColors.surface3,
          border: Border(top: BorderSide(color: MedColors.border2)),
        ),
        padding: const EdgeInsets.fromLTRB(50, 12, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // RFID bölümü
            if (_needRfid) ...[
              _RfidSection(item: item, onTap: onRfidTap, isLoading: isRfidLoading, onDelete: onRfidDelete),
              const SizedBox(height: 12),
            ],

            // Detay alanları
            _DetailGrid(item: item),
          ],
        ),
      ),
      secondChild: const SizedBox.shrink(),
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
  String get _tagDisplay => item.rfidTag ?? '—';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _hasTag ? MedColors.greenLight : MedColors.surface,
        borderRadius: MedRadius.mdAll,
        border: Border.all(
          color: _hasTag ? MedColors.green : MedColors.border,
          width: _hasTag ? 1.5 : 1,
          style: _hasTag ? BorderStyle.solid : BorderStyle.solid,
        ),
      ),
      child: Row(
        children: [
          // İkon
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: _hasTag ? MedColors.green.withValues(alpha: 0.15) : MedColors.surface3,
              borderRadius: MedRadius.smAll,
            ),
            child: Icon(
              PhosphorIcons.tag(PhosphorIconsStyle.duotone),
              size: 15,
              color: _hasTag ? MedColors.green : MedColors.text3,
            ),
          ),
          const SizedBox(width: 10),

          // Etiket bilgisi
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('RFID ETİKETİ', style: MedTextStyles.monoXs(color: MedColors.text3)),
                const SizedBox(height: 2),
                if (isLoading)
                  Text('Etiket bekleniyor...', style: MedTextStyles.monoMd(color: MedColors.text4))
                else
                  Text(
                    _hasTag ? _tagDisplay : 'Henüz etiket atanmadı',
                    style: MedTextStyles.monoMd(color: _hasTag ? MedColors.green : MedColors.text4),
                  ),
              ],
            ),
          ),

          // Aksiyon — loading ise spinner, değilse buton
          if (isLoading)
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: _hasTag ? MedColors.green : MedColors.blue),
            )
          else ...[
            // Etiket varsa: Değiştir + Sil
            // Etiket yoksa: Etiket Ata
            if (_hasTag && onDelete != null) ...[
              _SmallButton(label: 'Sil', color: MedColors.red, bgColor: MedColors.redLight, onTap: onDelete!),
              const SizedBox(width: 6),
            ],
            if (onTap != null)
              _SmallButton(
                label: _hasTag ? 'Değiştir' : 'Etiket Ata',
                color: _hasTag ? MedColors.green : MedColors.blue,
                bgColor: _hasTag ? MedColors.greenLight : MedColors.blueLight,
                onTap: onTap!,
              ),
          ],
        ],
      ),
    );
  }
}

class _DetailGrid extends StatelessWidget {
  const _DetailGrid({required this.item});

  final PrescriptionItem item;

  String _doseText() => '${item.dosePiece?.formatFractional ?? '-'} ${item.medicine?.operationUnit ?? 'Adet'}';

  bool get _hasReturn => item.returnUser != null || item.returnQuantity != null || item.returnDate != null;
  bool get _hasApproved => item.approvalUser != null || item.approvalDate != null;
  bool get _hasCancel => item.cancelUser != null || item.cancelDate != null;
  bool get _hasReject => item.rejectUser != null || item.rejectDate != null;

  bool get _hasWastageOrDestruction =>
      item.wastageUser != null ||
      item.wastageDate != null ||
      item.destructionUser != null ||
      item.destructionDate != null;

  String _returnQtyText() => item.returnQuantity != null
      ? '${item.returnQuantity!.formatFractional} ${item.medicine?.operationUnit ?? 'Adet'}'
      : '-';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Uygulama grubu — her zaman gösterilir
        _DetailGroupTitle(label: 'Uygulama'),
        const SizedBox(height: 6),
        _DetailRow(
          fields: [
            _Field('Uygulayan', item.applicationUser?.fullName),
            _Field('Uygulama Tarihi', item.applicationDate?.formattedDateTime),
            _Field('Miktar', _doseText()),
          ],
        ),

        // Onay grubu — en az bir alan doluysa gösterilir
        if (_hasApproved) ...[
          const SizedBox(height: 10),
          _DetailGroupTitle(label: 'ONAY'),
          const SizedBox(height: 6),
          _DetailRow(
            fields: [
              _Field('Onaylayan', item.approvalUser?.fullName),
              _Field('Onay Tarihi', item.approvalDate?.formattedDateTime),
            ],
          ),
        ],

        // İptal grubu — en az bir alan doluysa gösterilir
        if (_hasCancel) ...[
          const SizedBox(height: 10),
          _DetailGroupTitle(label: 'İptal'),
          const SizedBox(height: 6),
          _DetailRow(
            fields: [
              _Field('İptal Eden', item.cancelUser?.fullName),
              _Field('İptal Tarihi', item.cancelDate?.formattedDateTime),
            ],
          ),
        ],

        // Red grubu — en az bir alan doluysa gösterilir
        if (_hasReject) ...[
          const SizedBox(height: 10),
          _DetailGroupTitle(label: 'RED'),
          const SizedBox(height: 6),
          _DetailRow(
            fields: [
              _Field('Reddeden', item.rejectUser?.fullName),
              _Field('Red Tarihi', item.rejectDate?.formattedDateTime),
            ],
          ),
        ],

        // İade grubu — en az bir alan doluysa gösterilir
        if (_hasReturn) ...[
          const SizedBox(height: 10),
          _DetailGroupTitle(label: 'İade'),
          const SizedBox(height: 6),
          _DetailRow(
            fields: [
              _Field('İade Eden', item.returnUser?.fullName),
              _Field('İade Miktarı', _returnQtyText()),
              _Field('İade Tarihi', item.returnDate?.formattedDateTime),
            ],
          ),
        ],

        // Fire / İmha grubu — en az bir alan doluysa gösterilir
        if (_hasWastageOrDestruction) ...[
          const SizedBox(height: 10),
          _DetailGroupTitle(label: 'Fire / İmha'),
          const SizedBox(height: 6),
          _DetailRow(
            fields: [
              _Field('Fire Kaydeden', item.wastageUser?.fullName),
              _Field('Fire Tarihi', item.wastageDate?.formattedDateTime),
              _Field('İmha Eden', item.destructionUser?.fullName),
              _Field('İmha Tarihi', item.destructionDate?.formattedDateTime),
            ],
          ),
        ],
      ],
    );
  }
}

class _Field {
  const _Field(this.label, this.value);

  final String label;
  final String? value;
}

class _DetailGroupTitle extends StatelessWidget {
  const _DetailGroupTitle({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Text(label.toUpperCase(), style: MedTextStyles.monoSm(color: MedColors.text4)),
        ),
        Expanded(child: Divider(color: MedColors.border2, height: 1)),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.fields});

  final List<_Field> fields;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 6,
      alignment: WrapAlignment.spaceAround,
      children: fields.map((f) => _DetailCell(field: f)).toList(),
    );
  }
}

class _DetailCell extends StatelessWidget {
  const _DetailCell({required this.field});

  final _Field field;

  @override
  Widget build(BuildContext context) {
    final isEmpty = field.value == null || field.value == '-';
    return SizedBox(
      width: 160,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(field.label, style: MedTextStyles.monoXs()),
          const SizedBox(height: 2),
          Text(
            isEmpty ? '—' : field.value!,
            style: MedTextStyles.bodySm(color: isEmpty ? MedColors.text4 : MedColors.text2, weight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _Checkbox extends StatelessWidget {
  const _Checkbox({required this.isSelected, required this.isSelectable});

  final bool isSelected;
  final bool isSelectable;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: isSelected ? MedColors.blue : Colors.transparent,
        borderRadius: MedRadius.smAll,
        border: Border.all(
          color: isSelected
              ? MedColors.blue
              : isSelectable
              ? MedColors.text3
              : MedColors.border,
          width: 1.5,
        ),
      ),
      child: isSelected ? const Icon(Icons.check, size: 11, color: Colors.white) : null,
    );
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({required this.time});

  final DateTime time;

  String get _label {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final timeDay = DateTime(time.year, time.month, time.day);

    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    final timeStr = '$h:$m';

    if (timeDay == today) return 'Bugün $timeStr';
    if (timeDay == tomorrow) return 'Yarın $timeStr';

    const days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    return '${days[time.weekday - 1]} $timeStr';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: MedColors.amberLight,
        borderRadius: MedRadius.smAll,
        border: Border.all(color: MedColors.amber.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Text(_label, style: MedTextStyles.monoXs(color: MedColors.amber))],
      ),
    );
  }
}

class _DoseChip extends StatelessWidget {
  const _DoseChip({required this.item});

  final PrescriptionItem item;

  @override
  Widget build(BuildContext context) {
    final text = '${item.dosePiece?.formatFractional ?? '-'} ${item.medicine?.operationUnit ?? 'Adet'}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: MedColors.surface3,
        borderRadius: MedRadius.smAll,
        border: Border.all(color: MedColors.border),
      ),
      child: Text(text, style: MedTextStyles.monoSm()),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final PrescriptionStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: status.borderColor.withValues(alpha: 0.1),
        borderRadius: MedRadius.smAll,
        border: Border.all(color: status.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 11, color: status.color),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: MedTextStyles.monoSm(color: status.color, weight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _SmallButton extends StatelessWidget {
  const _SmallButton({required this.label, required this.color, required this.bgColor, required this.onTap});

  final String label;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: MedRadius.mdAll,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: MedRadius.mdAll,
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Text(
          label,
          style: MedTextStyles.bodySm(color: color, weight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _RxActionBar extends StatelessWidget {
  const _RxActionBar({
    required this.selectedCount,
    required this.approvedAll,
    required this.rejectedAll,
    required this.cancelledAll,
    this.onApprove,
    this.onReject,
    this.onCancel,
  });

  final int selectedCount;
  final bool approvedAll;
  final bool rejectedAll;
  final bool cancelledAll;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: MedColors.surface2,
          border: Border(top: BorderSide(color: MedColors.border)),
        ),
        child: Row(
          children: [
            Text('$selectedCount kalem seçildi', style: MedTextStyles.monoSm()),
            const Spacer(),
            if (onApprove != null) ...[
              _ActionChip(
                label: 'Onayla',
                icon: PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
                color: MedColors.green,
                bgColor: MedColors.greenLight,
                onTap: onApprove!,
              ),
              const SizedBox(width: 8),
            ],
            if (onReject != null) ...[
              _ActionChip(
                label: 'Reddet',
                icon: PhosphorIcons.xCircle(PhosphorIconsStyle.fill),
                color: MedColors.red,
                bgColor: MedColors.redLight,
                onTap: onReject!,
              ),
              const SizedBox(width: 8),
            ],
            if (onCancel != null)
              _ActionChip(
                label: 'İptal',
                icon: PhosphorIcons.prohibit(PhosphorIconsStyle.fill),
                color: MedColors.amber,
                bgColor: MedColors.amberLight,
                onTap: onCancel!,
              ),
          ],
        ),
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
