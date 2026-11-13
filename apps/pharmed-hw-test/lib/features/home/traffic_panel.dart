import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../core/providers.dart';
import '../../core/traffic_log.dart';
import '../../widgets/common.dart';

/// Seri hattaki son komutlar (TX) ve cevaplar (RX).
class TrafficPanel extends ConsumerWidget {
  const TrafficPanel({super.key, this.showHeader = true});

  final bool showHeader;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final log = ref.watch(trafficLogProvider);
    final entries = log.entries.reversed.toList();
    final mono = monoStyle(fontSize: 12.5);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: MedColors.surface2,
        border: const Border(top: BorderSide(color: MedColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showHeader)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 4, 0),
              child: Row(
                children: [
                  Text('Seri hat trafiği (${entries.length})', style: Theme.of(context).textTheme.labelLarge),
                  const Spacer(),
                  TextButton(onPressed: log.clear, child: const Text('Temizle')),
                ],
              ),
            ),
          Expanded(
            child: entries.isEmpty
                ? const Center(child: Text('Henüz komut gönderilmedi.'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    itemCount: entries.length,
                    itemBuilder: (_, i) => _TrafficRow(entry: entries[i], style: mono),
                  ),
          ),
        ],
      ),
    );
  }
}

class _TrafficRow extends StatelessWidget {
  const _TrafficRow({required this.entry, required this.style});

  final TrafficEntry entry;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final failed = entry.error != null || entry.response == null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(formatTime(entry.time), style: style.copyWith(color: MedColors.text3))),
          SizedBox(width: 130, child: Text('TX ${entry.command}', style: style)),
          Expanded(
            child: Text(
              'RX ${entry.responseText}',
              style: style.copyWith(color: failed ? TestStatus.failed.color : TestStatus.passed.color),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text('${entry.elapsed.inMilliseconds} ms', style: style.copyWith(color: MedColors.text3)),
        ],
      ),
    );
  }
}
