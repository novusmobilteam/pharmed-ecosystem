part of 'service_form_panel.dart';

class RoomField extends StatelessWidget {
  const RoomField({super.key});

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<ServiceFormNotifier>();
    final entries = notifier.roomEntries;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppDimensions.registrationDialogSpacing,
      children: [
        // ── Section header
        Row(
          children: [
            Text(
              'Odalar & Yataklar',
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: MedColors.text2, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            if (entries.isNotEmpty) _SummaryChip(label: '${entries.length} oda · ${notifier.totalBedCount} yatak'),
          ],
        ),

        // ── Room tiles
        if (entries.isNotEmpty)
          Column(
            spacing: 6,
            children: entries.map((e) => _RoomTile(localId: e.localId, room: e.room)).toList(),
          ),

        // ── Add room button
        MedButton(
          label: 'Oda Ekle',
          variant: MedButtonVariant.secondary,
          size: MedButtonSize.sm,
          fullWidth: true,
          onPressed: context.read<ServiceFormNotifier>().addRoom,
        ),
      ],
    );
  }
}

class _RoomTile extends StatefulWidget {
  final String localId;
  final Room room;

  const _RoomTile({required this.localId, required this.room});

  @override
  State<_RoomTile> createState() => _RoomTileState();
}

class _RoomTileState extends State<_RoomTile> {
  bool _expanded = true;
  late final TextEditingController _nameCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.room.name);
  }

  @override
  void didUpdateWidget(_RoomTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.room.name != widget.room.name && _nameCtrl.text != widget.room.name) {
      _nameCtrl.text = widget.room.name ?? '';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.read<ServiceFormNotifier>();
    final bedEntries = notifier.bedEntries(widget.localId);
    final room = widget.room;

    return Container(
      decoration: BoxDecoration(
        color: MedColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: MedColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: _expanded ? const BorderRadius.vertical(top: Radius.circular(10)) : BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              child: Row(
                spacing: 8,
                children: [
                  // Caret
                  Icon(
                    _expanded ? PhosphorIcons.caretDown() : PhosphorIcons.caretRight(),
                    size: 13,
                    color: MedColors.text3,
                  ),
                  Expanded(
                    child: TextInputField(
                      controller: _nameCtrl,
                      onChanged: (v) => notifier.updateRoomName(widget.localId, v ?? '-'),
                    ),
                  ),

                  // Yatak sayısı
                  _SummaryChip(label: '${room.bedCount} yatak'),

                  // Sil
                  GestureDetector(
                    onTap: () => notifier.removeRoom(widget.localId),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(PhosphorIcons.trash(), size: 14, color: MedColors.red.withValues(alpha: 0.6)),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Expanded body
          if (_expanded) ...[
            Divider(height: 1, thickness: 0.5, color: MedColors.border),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  // Bed chip'leri veya boş placeholder
                  if (bedEntries.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: bedEntries
                          .map((e) => _BedChip(localId: e.localId, bed: e.bed, roomLocalId: widget.localId))
                          .toList(),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        'Henüz yatak eklenmedi',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: MedColors.text3),
                      ),
                    ),

                  // Yatak ekle
                  MedButton(
                    label: 'Yatak Ekle',
                    variant: MedButtonVariant.ghost,
                    size: MedButtonSize.sm,
                    onPressed: () => notifier.addBed(widget.localId),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BedChip extends StatefulWidget {
  final String localId;
  final String roomLocalId;
  final Bed bed;

  const _BedChip({required this.localId, required this.roomLocalId, required this.bed});

  @override
  State<_BedChip> createState() => _BedChipState();
}

class _BedChipState extends State<_BedChip> {
  late final TextEditingController _ctrl;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.bed.name);
  }

  @override
  void didUpdateWidget(_BedChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bed.name != widget.bed.name && _ctrl.text != widget.bed.name) {
      _ctrl.text = widget.bed.name ?? '';
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.read<ServiceFormNotifier>();

    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: _editing ? MedColors.blueLight : MedColors.surface2,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _editing ? MedColors.blue.withValues(alpha: 0.5) : MedColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 5,
        children: [
          IntrinsicWidth(
            child: TextField(
              controller: _ctrl,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _editing ? MedColors.blue : MedColors.text,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                fillColor: Colors.transparent,
              ),
              onTap: () => setState(() => _editing = true),
              onChanged: (v) => notifier.updateBedName(widget.roomLocalId, widget.localId, v),
              onEditingComplete: () => setState(() => _editing = false),
              onTapOutside: (_) => setState(() => _editing = false),
            ),
          ),
          GestureDetector(
            onTap: () => notifier.removeBed(widget.roomLocalId, widget.localId),
            child: Icon(PhosphorIcons.x(), size: 10, color: MedColors.text3),
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  const _SummaryChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: MedColors.surface2,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: MedColors.border),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: MedColors.text2),
      ),
    );
  }
}
