part of '../view/bed_assignment_panel.dart';

class _BedSelector extends StatelessWidget {
  const _BedSelector({
    required this.state,
    required this.onServiceSelected,
    required this.onRoomSelected,
    required this.onBedSelected,
  });

  final BedAssignmentCellSelected state;
  final ValueChanged<HospitalService> onServiceSelected;
  final ValueChanged<Room> onRoomSelected;
  final ValueChanged<Bed> onBedSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Servis dropdown
        MedDropdown<HospitalService>(
          hint: context.l10n.assignment_serviceSelectorHint,
          selected: state.selectedService,
          options: state.services,
          labelBuilder: (s) => s.name ?? '—',
          onSelected: onServiceSelected,
        ),
        const SizedBox(height: 6),

        // Oda dropdown — servis seçilince aktif
        MedDropdown<Room>(
          hint: context.l10n.assignment_roomSelectorHint,
          selected: state.selectedRoom,
          options: state.rooms,
          labelBuilder: (r) => r.name ?? '—',
          enabled: state.selectedService != null && state.rooms.isNotEmpty,
          onSelected: onRoomSelected,
        ),
        const SizedBox(height: 6),

        // Yatak dropdown — oda seçilince aktif
        MedDropdown<Bed>(
          hint: context.l10n.assignment_bedSelectorHint,
          selected: state.selectedBed,
          options: state.beds,
          labelBuilder: (b) => b.name ?? '—',
          enabled: state.selectedRoom != null && state.beds.isNotEmpty,
          onSelected: onBedSelected,
        ),

        const SizedBox(height: 12),
      ],
    );
  }
}
