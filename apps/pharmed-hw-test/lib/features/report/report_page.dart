import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/report.dart';
import '../../core/traffic_log.dart';
import '../../widgets/common.dart';

class ReportPage extends ConsumerStatefulWidget {
  const ReportPage({super.key});

  @override
  ConsumerState<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends ConsumerState<ReportPage> {
  String? _lastPath;
  bool _busy = false;

  Future<void> _export() async {
    setState(() => _busy = true);
    final session = ref.read(sessionProvider);
    try {
      final path = await ref
          .read(testReportProvider)
          .export(
            user: session.user?.fullName,
            port: session.port,
            cabinType: session.cabinType?.label,
            traffic: ref.read(trafficLogProvider).entries,
          );
      setState(() => _lastPath = path);
      if (mounted) showMessage(context, 'Rapor kaydedildi: $path');
    } catch (e) {
      if (mounted) showMessage(context, 'Rapor kaydedilemedi: $e', error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final report = ref.watch(testReportProvider);
    final steps = report.steps.reversed.toList();
    final failed = report.steps.where((s) => s.result == StepResult.fail).length;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        SectionCard(
          title: 'Test raporu',
          trailing: TextButton(onPressed: steps.isEmpty ? null : report.clear, child: const Text('Temizle')),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${report.steps.length} adım · $failed hatalı'),
              const SizedBox(height: 12),
              BusyButton(label: 'Raporu dosyaya kaydet', icon: Icons.save_alt, busy: _busy, onPressed: _export),
              const SizedBox(height: 6),
              Text(
                _lastPath ?? 'Rapor Belgeler\\PharMed-HwTest klasörüne kaydedilir; seri hat trafiği de rapora eklenir.',
                style: hintStyle(),
              ),
            ],
          ),
        ),
        for (final s in steps)
          Card(
            child: ListTile(
              leading: ResultBadge(result: s.result, label: s.resultLabel),
              title: Text(s.title),
              subtitle: s.detail == null || s.detail!.isEmpty
                  ? null
                  : Text(s.detail!, style: monoStyle(fontSize: 12.5)),
              trailing: Text(formatTime(s.time)),
            ),
          ),
      ],
    );
  }
}
