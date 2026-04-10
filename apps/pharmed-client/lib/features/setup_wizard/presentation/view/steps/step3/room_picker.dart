// [SWREQ-SETUP-UI-013]
// Mobil kabin Adım 3 — Oda & Yatak seçim bileşeni.
// Servisler grup başlığı altında accordion şeklinde listelenir.
// Sınıf: Class A
part of 'step3_station_scope.dart';

class _RoomBedSection extends StatelessWidget {
  const _RoomBedSection({
    required this.servicesLoadState,
    required this.services,
    required this.selectedRooms,
    required this.selectedBeds,
    required this.onChanged,
  });

  final ServicesLoadState servicesLoadState;
  final List<HospitalService> services;
  final List<Room> selectedRooms;
  final List<Bed> selectedBeds;
  final void Function(List<Room> rooms, List<Bed> beds) onChanged;

  @override
  Widget build(BuildContext context) {
    return switch (servicesLoadState) {
      ServicesLoadState.idle => const SizedBox.shrink(),
      ServicesLoadState.loading => const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: CircularProgressIndicator.adaptive(),
      ),
      ServicesLoadState.error => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'Servis detayları yüklenemedi.',
          style: TextStyle(fontFamily: MedFonts.sans, fontSize: 12, color: MedColors.red),
        ),
      ),
      ServicesLoadState.loaded => RoomBedPicker(
        services: services,
        selectedRooms: selectedRooms,
        selectedBeds: selectedBeds,
        onChanged: onChanged,
      ),
    };
  }
}

class RoomBedPicker extends StatefulWidget {
  const RoomBedPicker({
    super.key,
    required this.services,
    required this.selectedRooms,
    required this.selectedBeds,
    required this.onChanged,
  });

  final List<HospitalService> services;
  final List<Room> selectedRooms;
  final List<Bed> selectedBeds;
  final void Function(List<Room> rooms, List<Bed> beds) onChanged;

  @override
  State<RoomBedPicker> createState() => _RoomBedPickerState();
}

class _RoomBedPickerState extends State<RoomBedPicker> {
  final Set<int> _expandedRoomIds = {};

  @override
  void initState() {
    super.initState();
    for (final room in widget.selectedRooms) {
      if (room.id != null) _expandedRoomIds.add(room.id!);
    }
  }

  bool _isRoomSelected(Room room) => widget.selectedRooms.any((r) => r.id == room.id);

  bool _isBedSelected(Bed bed) => widget.selectedBeds.any((b) => b.id == bed.id);

  bool _isRoomPartial(Room room) {
    if (!_isRoomSelected(room)) return false;
    final selected = room.beds.where(_isBedSelected).length;
    return selected > 0 && selected < room.beds.length;
  }

  void _toggleRoom(Room room) {
    final rooms = [...widget.selectedRooms];
    final beds = [...widget.selectedBeds];

    if (_isRoomSelected(room)) {
      rooms.removeWhere((r) => r.id == room.id);
      beds.removeWhere((b) => room.beds.any((rb) => rb.id == b.id));
    } else {
      rooms.add(room);
      for (final bed in room.beds) {
        if (!beds.any((b) => b.id == bed.id)) beds.add(bed);
      }
      if (room.id != null) setState(() => _expandedRoomIds.add(room.id!));
    }

    widget.onChanged(rooms, beds);
  }

  void _toggleBed(Room room, Bed bed) {
    final rooms = [...widget.selectedRooms];
    final beds = [...widget.selectedBeds];

    if (_isBedSelected(bed)) {
      beds.removeWhere((b) => b.id == bed.id);
      final remaining = room.beds.where((rb) => beds.any((sb) => sb.id == rb.id));
      if (remaining.isEmpty) rooms.removeWhere((r) => r.id == room.id);
    } else {
      beds.add(bed);
      if (!rooms.any((r) => r.id == room.id)) rooms.add(room);
    }

    widget.onChanged(rooms, beds);
  }

  void _toggleExpand(Room room) {
    if (room.id == null) return;
    setState(() {
      if (_expandedRoomIds.contains(room.id)) {
        _expandedRoomIds.remove(room.id);
      } else {
        _expandedRoomIds.add(room.id!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final allRooms = widget.services.expand((s) => s.rooms).toList();

    if (allRooms.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'Bu istasyona bağlı oda tanımlı değil.',
          style: TextStyle(fontFamily: MedFonts.sans, fontSize: 12, color: MedColors.text3),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Özet chip'leri
        if (widget.selectedRooms.isNotEmpty) ...[
          Row(
            children: [
              MedBadge(label: '${widget.selectedRooms.length} oda', variant: MedBadgeVariant.blue),
              const SizedBox(width: 8),
              MedBadge(label: '${widget.selectedBeds.length} yatak', variant: MedBadgeVariant.green),
            ],
          ),
          const SizedBox(height: 12),
        ],

        // Servis grupları
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: MedColors.border, width: 0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (int si = 0; si < widget.services.length; si++) ...[
                if (si > 0) const Divider(height: 1, thickness: 0.5, color: MedColors.border),
                _ServiceGroup(
                  service: widget.services[si],
                  expandedRoomIds: _expandedRoomIds,
                  selectedRooms: widget.selectedRooms,
                  selectedBeds: widget.selectedBeds,
                  isRoomSelected: _isRoomSelected,
                  isRoomPartial: _isRoomPartial,
                  isBedSelected: _isBedSelected,
                  onRoomToggle: _toggleRoom,
                  onBedToggle: _toggleBed,
                  onExpandToggle: _toggleExpand,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ── Servis grubu ─────────────────────────────────────────────────
class _ServiceGroup extends StatelessWidget {
  const _ServiceGroup({
    required this.service,
    required this.expandedRoomIds,
    required this.selectedRooms,
    required this.selectedBeds,
    required this.isRoomSelected,
    required this.isRoomPartial,
    required this.isBedSelected,
    required this.onRoomToggle,
    required this.onBedToggle,
    required this.onExpandToggle,
  });

  final HospitalService service;
  final Set<int> expandedRoomIds;
  final List<Room> selectedRooms;
  final List<Bed> selectedBeds;
  final bool Function(Room) isRoomSelected;
  final bool Function(Room) isRoomPartial;
  final bool Function(Bed) isBedSelected;
  final ValueChanged<Room> onRoomToggle;
  final void Function(Room, Bed) onBedToggle;
  final ValueChanged<Room> onExpandToggle;

  @override
  Widget build(BuildContext context) {
    final rooms = service.rooms;
    final selCount = rooms.where((r) => isRoomSelected(r)).length;

    return Column(
      children: [
        // Servis başlığı
        Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          color: MedColors.surface2,
          child: Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(color: MedColors.blue, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  service.name ?? '—',
                  style: const TextStyle(
                    fontFamily: MedFonts.sans,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: MedColors.text2,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              // Seçim badge'i
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(color: MedColors.blueLight, borderRadius: BorderRadius.circular(10)),
                child: Text(
                  selCount > 0 ? '$selCount/${rooms.length}' : '${rooms.length} oda',
                  style: const TextStyle(fontFamily: MedFonts.mono, fontSize: 10, color: MedColors.blue),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 0.5, color: MedColors.border),

        // Oda satırları
        for (int i = 0; i < rooms.length; i++) ...[
          if (i > 0) const Divider(height: 1, thickness: 0.5, color: MedColors.border2, indent: 46),
          _RoomRow(
            room: rooms[i],
            isSelected: isRoomSelected(rooms[i]),
            isPartial: isRoomPartial(rooms[i]),
            isExpanded: expandedRoomIds.contains(rooms[i].id),
            isBedSelected: isBedSelected,
            onRoomToggle: () => onRoomToggle(rooms[i]),
            onExpandToggle: () => onExpandToggle(rooms[i]),
            onBedToggle: (bed) => onBedToggle(rooms[i], bed),
          ),
        ],
      ],
    );
  }
}

// ── Oda satırı ───────────────────────────────────────────────────
class _RoomRow extends StatelessWidget {
  const _RoomRow({
    required this.room,
    required this.isSelected,
    required this.isPartial,
    required this.isExpanded,
    required this.isBedSelected,
    required this.onRoomToggle,
    required this.onExpandToggle,
    required this.onBedToggle,
  });

  final Room room;
  final bool isSelected;
  final bool isPartial;
  final bool isExpanded;
  final bool Function(Bed) isBedSelected;
  final VoidCallback onRoomToggle;
  final VoidCallback onExpandToggle;
  final ValueChanged<Bed> onBedToggle;

  @override
  Widget build(BuildContext context) {
    final hasBeds = room.beds.isNotEmpty;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      color: isSelected ? MedColors.blueLight : MedColors.surface,
      child: Column(
        children: [
          SizedBox(
            height: 50,
            child: Row(
              children: [
                GestureDetector(
                  onTap: onRoomToggle,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: MedCheckbox(value: isSelected, partial: isPartial, onChanged: (_) => onRoomToggle()),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: onRoomToggle,
                    child: Text(
                      room.name ?? '—',
                      style: TextStyle(
                        fontFamily: MedFonts.sans,
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                        color: isSelected ? MedColors.blue : MedColors.text,
                      ),
                    ),
                  ),
                ),
                if (hasBeds) ...[
                  Text(
                    '${room.beds.length} yatak',
                    style: const TextStyle(fontFamily: MedFonts.mono, fontSize: 10, color: MedColors.text3),
                  ),
                  GestureDetector(
                    onTap: onExpandToggle,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 180),
                        child: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: MedColors.text3),
                      ),
                    ),
                  ),
                ] else
                  const SizedBox(width: 14),
              ],
            ),
          ),
          if (isExpanded && hasBeds)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: MedColors.surface2,
                border: Border(top: BorderSide(color: MedColors.border2, width: 0.5)),
              ),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                alignment: WrapAlignment.start,
                children: room.beds.map((bed) {
                  final sel = isBedSelected(bed);
                  return _BedChip(bed: bed, isSelected: sel, onTap: () => onBedToggle(bed));
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Yatak chip ───────────────────────────────────────────────────
class _BedChip extends StatelessWidget {
  const _BedChip({required this.bed, required this.isSelected, required this.onTap});

  final Bed bed;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
        constraints: const BoxConstraints(minHeight: 32),
        decoration: BoxDecoration(
          color: isSelected ? MedColors.blue : MedColors.surface,
          border: Border.all(color: isSelected ? MedColors.blue : MedColors.border, width: isSelected ? 1.5 : 0.5),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              const Icon(Icons.check_rounded, size: 11, color: Colors.white),
              const SizedBox(width: 4),
            ],
            Text(
              bed.name ?? '—',
              style: TextStyle(
                fontFamily: MedFonts.sans,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : MedColors.text2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
