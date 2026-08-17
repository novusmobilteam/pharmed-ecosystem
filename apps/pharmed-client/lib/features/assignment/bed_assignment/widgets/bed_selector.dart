part of '../view/bed_assignment_panel.dart';

class _BedSelector extends StatelessWidget {
  const _BedSelector({required this.notifier});

  final BedAssignmentNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Servis dropdown
        MedDropdownInputField<HospitalService>(
          label: context.l10n.assignment_serviceSelectorHint,
          initialValue: notifier.selectedService,
          options: notifier.services,
          labelBuilder: (s) => s?.name,
          onChanged: notifier.onServiceSelected,
        ),
        const SizedBox(height: 6),

        // Oda dropdown — servis seçilince aktif
        MedDropdownInputField<Room>(
          label: context.l10n.assignment_roomSelectorHint,
          initialValue: notifier.selectedRoom,
          options: notifier.rooms,
          labelBuilder: (r) => r?.name,
          enabled: notifier.selectedService != null && notifier.rooms.isNotEmpty,
          onChanged: notifier.onRoomSelected,
        ),
        const SizedBox(height: 6),

        // Yatak dropdown — oda seçilince aktif
        MedDropdownInputField<Bed>(
          label: context.l10n.assignment_bedSelectorHint,
          initialValue: notifier.selectedBed,
          options: notifier.beds,
          labelBuilder: (b) => b?.name,
          enabled: notifier.selectedRoom != null && notifier.beds.isNotEmpty,
          onChanged: notifier.onBedSelected,
        ),

        const SizedBox(height: 12),
      ],
    );
  }
}
