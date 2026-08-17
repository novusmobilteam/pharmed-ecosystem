part of '../view/bed_assignment_panel.dart';

class _BedCard extends StatelessWidget {
  const _BedCard({required this.notifier});

  final BedAssignmentNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final bed = notifier.selectedBed!;
    final room = notifier.selectedRoom;
    final service = notifier.selectedService;

    // Mevcut atamada yatış bilgisi varsa göster
    final hospitalization = notifier.existingAssignment?.hospitalization;
    final patientName = hospitalization?.patient?.fullName;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: MedColors.blueLight,
        border: Border.all(color: MedColors.blue.withAlpha(50), width: 1.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: MedColors.blue, borderRadius: BorderRadius.circular(8)),
                alignment: Alignment.center,
                child: const Icon(Icons.bed_rounded, size: 18, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bed.name ?? '—',
                      style: TextStyle(
                        fontFamily: MedFonts.sans,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: MedColors.text,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (room != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        room.name ?? '—',
                        style: TextStyle(
                          fontFamily: MedFonts.mono,
                          fontSize: 10,
                          color: MedColors.text3,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (service != null || patientName != null) ...[
            const SizedBox(height: 10),
            const Divider(height: 1, color: Color(0x1A1A6FD8)),
            const SizedBox(height: 10),
            if (service != null) _InfoRow(label: context.l10n.assignment_serviceLabel, value: service.name ?? '—'),
            if (patientName != null) ...[
              const SizedBox(height: 4),
              _InfoRow(label: context.l10n.assignment_patientLabel, value: patientName),
            ],
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: TextStyle(fontFamily: MedFonts.mono, fontSize: 9, color: MedColors.text3, letterSpacing: 0.4),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontFamily: MedFonts.sans,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: MedColors.text,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
