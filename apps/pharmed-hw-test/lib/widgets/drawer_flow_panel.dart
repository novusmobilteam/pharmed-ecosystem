import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../core/drawer_flow.dart';
import '../core/test_status.dart';
import 'status.dart';

/// Çalışan çekmece akışının adımları, anlık sensör durumu ve teknisyenin
/// karar düğmeleri ("… olmadı" / "Oldu, sensör görmedi" / "Durdur").
class DrawerFlowPanel extends StatelessWidget {
  const DrawerFlowPanel({super.key, required this.flow});

  final DrawerFlow flow;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: flow,
      builder: (context, _) {
        final waiting = flow.waiting;
        final rows = <Widget>[];
        String? group;
        for (final s in flow.steps) {
          if (s.group != group) {
            group = s.group;
            if (group != null) {
              rows.add(
                Padding(
                  padding: const EdgeInsets.only(top: MedSpacing.md, bottom: MedSpacing.xs),
                  child: Text(group, style: MedTextStyles.titleSm()),
                ),
              );
            }
          }
          rows.add(_StepRow(step: s, waiting: identical(s, waiting)));
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...rows,
            if (waiting != null) ...[
              const SizedBox(height: MedSpacing.lg),
              Wrap(
                spacing: MedSpacing.lg,
                runSpacing: MedSpacing.md,
                children: [
                  if (waiting.failLabel != null)
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: TestStatus.failed.color,
                        minimumSize: const Size(190, 48),
                      ),
                      onPressed: flow.reportFailed,
                      icon: Icon(TestStatus.failed.icon),
                      label: Text(waiting.failLabel!),
                    ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(minimumSize: const Size(190, 48)),
                    onPressed: flow.reportDoneWithoutSensor,
                    icon: Icon(TestStatus.warning.icon, color: TestStatus.warning.color),
                    label: const Text('Oldu, sensör görmedi'),
                  ),
                  TextButton.icon(
                    onPressed: flow.cancelled ? null : flow.cancel,
                    icon: const Icon(Icons.stop),
                    label: const Text('Durdur'),
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.step, required this.waiting});

  final FlowStep step;
  final bool waiting;

  @override
  Widget build(BuildContext context) {
    final text = waiting ? (step.live == null ? 'Sensör okunuyor…' : 'Şu an: ${step.live}') : step.detail;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: const EdgeInsets.only(top: 1), child: StatusIcon(status: step.status, size: 16)),
          const SizedBox(width: MedSpacing.md),
          SizedBox(
            width: 320,
            child: Text(
              step.label,
              style: waiting ? MedTextStyles.bodyMd(color: MedColors.text, weight: FontWeight.w600) : null,
            ),
          ),
          Expanded(
            child: Text(
              text ?? '',
              style: TextStyle(fontSize: 12.5, color: waiting ? TestStatus.running.color : step.status.color),
            ),
          ),
        ],
      ),
    );
  }
}
