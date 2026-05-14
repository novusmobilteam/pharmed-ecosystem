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
        MedDropdownInputField<HospitalService>(
          label: context.l10n.assignment_serviceSelectorHint,
          initialValue: state.selectedService,
          options: state.services,
          labelBuilder: (s) => s?.name ?? '—',
          onChanged: onServiceSelected,
        ),
        const SizedBox(height: 6),

        // Oda dropdown — servis seçilince aktif
        MedDropdownInputField<Room>(
          label: context.l10n.assignment_roomSelectorHint,
          initialValue: state.selectedRoom,
          options: state.rooms,
          labelBuilder: (r) => r?.name ?? '—',
          enabled: state.selectedService != null && state.rooms.isNotEmpty,
          onChanged: onRoomSelected,
        ),
        const SizedBox(height: 6),

        // Yatak dropdown — oda seçilince aktif
        MedDropdownInputField<Bed>(
          label: context.l10n.assignment_bedSelectorHint,
          initialValue: state.selectedBed,
          options: state.beds,
          labelBuilder: (b) => b?.name ?? '—',
          enabled: state.selectedRoom != null && state.beds.isNotEmpty,
          onChanged: onBedSelected,
        ),

        const SizedBox(height: 12),
      ],
    );
  }
}
