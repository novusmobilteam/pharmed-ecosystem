import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../notifier/master_intake_execution_notifier.dart';

class IntakeQueueSequencePanel extends StatelessWidget {
  const IntakeQueueSequencePanel({super.key, required this.notifier});

  final MasterIntakeExecutionNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final entries = <_SequenceEntry>[];
    for (var ji = 0; ji < notifier.jobs.length; ji++) {
      final job = notifier.jobs[ji];
      for (var ti = 0; ti < job.targets.length; ti++) {
        final isPast = ji < notifier.currentIndex || (ji == notifier.currentIndex && ti < notifier.currentTargetIndex);
        final isCurrent = ji == notifier.currentIndex && ti == notifier.currentTargetIndex;
        entries.add(
          _SequenceEntry(
            medicineName: job.targets[ti].medicine?.name ?? '',
            locationLabel: job.representativeAssignment.drawerUnit?.drawerSlot?.address ?? '',
            isCompleted: isPast,
            isCurrent: isCurrent,
          ),
        );
      }
    }

    return Container(
      padding: MedSpacing.insetLg,
      decoration: MedDecoration.panelDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('context.l10n.intake_sequence_panelTitle', style: MedTextStyles.titleSm()),
          const SizedBox(height: 10),
          for (var i = 0; i < entries.length; i++) ...[
            _SequenceRow(index: i + 1, entry: entries[i]),
            if (i < entries.length - 1) const SizedBox(height: 6),
          ],
        ],
      ),
    );
  }
}

class _SequenceEntry {
  const _SequenceEntry({
    required this.medicineName,
    required this.locationLabel,
    required this.isCompleted,
    required this.isCurrent,
  });
  final String medicineName;
  final String locationLabel;
  final bool isCompleted;
  final bool isCurrent;
}

class _SequenceRow extends StatelessWidget {
  const _SequenceRow({required this.index, required this.entry});
  final int index;
  final _SequenceEntry entry;

  @override
  Widget build(BuildContext context) {
    final (Color border, Color bg) = entry.isCompleted
        ? (MedColors.green, MedColors.greenLight)
        : entry.isCurrent
        ? (MedColors.blue, MedColors.blueLight)
        : (MedColors.border, MedColors.surface2);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border),
        borderRadius: MedRadius.mdAll,
      ),
      child: Row(
        children: [
          entry.isCompleted
              ? Icon(PhosphorIcons.checkCircle(PhosphorIconsStyle.fill), size: 18, color: MedColors.green)
              : CircleAvatar(
                  radius: 9,
                  backgroundColor: entry.isCurrent ? MedColors.blue : MedColors.border2,
                  child: Text('$index', style: MedTextStyles.monoXs(color: Colors.white)),
                ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.medicineName, style: MedTextStyles.bodyMd(color: entry.isCurrent ? MedColors.blue : null)),
                Text(entry.locationLabel, style: MedTextStyles.monoXs(color: MedColors.text3)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
