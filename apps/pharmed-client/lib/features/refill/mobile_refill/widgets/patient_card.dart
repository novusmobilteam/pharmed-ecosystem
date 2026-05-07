part of '../view/mobile_refill_panel.dart';

class _PatientCard extends StatelessWidget {
  const _PatientCard({required this.patient, required this.bed, required this.room, required this.onChange});

  final Patient patient;
  final Bed? bed;
  final Room? room;
  final VoidCallback? onChange;

  String get _initials {
    final parts = patient.fullName.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MedColors.surface,
        borderRadius: MedRadius.mdAll,
        border: Border.all(color: MedColors.border),
        boxShadow: MedShadows.sm,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 8, 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: MedColors.blueLight, shape: BoxShape.circle),
              child: Center(
                child: Text(
                  _initials,
                  style: MedTextStyles.bodyMd(color: MedColors.blue, weight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patient.fullName,
                    style: MedTextStyles.bodyMd(color: MedColors.text, weight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (room?.name != null || bed?.name != null)
                    Text(
                      [if (room?.name != null) room!.name!, if (bed?.name != null) bed!.name!].join(' · '),
                      style: MedTextStyles.monoXs(),
                    ),
                ],
              ),
            ),
            // Başka hasta seç (sadece süreç aktif değilse)
            if (onChange != null)
              IconButton(
                icon: Icon(PhosphorIcons.userSwitch(), size: 18, color: MedColors.text2),
                tooltip: 'Başka hasta seç',
                onPressed: onChange,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
          ],
        ),
      ),
    );
  }
}
