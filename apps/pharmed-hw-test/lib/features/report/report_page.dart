import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../core/cabin_session.dart';
import '../../core/providers.dart';
import '../../core/report.dart';
import '../../core/scenarios.dart';
import '../../core/serum_definition.dart';
import '../../core/traffic_log.dart';
import '../../widgets/common.dart';

/// Rapor: önce test senaryolarının sonuçları (kabin bazında), sonra zaman
/// sıralı tüm adımlar. Dosyaya kabin tanımı, serum tanımı ve hat trafiği de
/// yazılır; hatalı adımların altına o adımın ham trafiği eklenir.
class ReportPage extends ConsumerStatefulWidget {
  const ReportPage({super.key});

  @override
  ConsumerState<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends ConsumerState<ReportPage> {
  String? _lastPath;
  bool _busy = false;

  List<ReportScenario> _scenarios() {
    final session = ref.read(sessionProvider);
    final results = ref.read(scenarioResultsProvider);
    final list = buildScenarios(
      snapshot: ref.read(cabinSessionProvider).active,
      serum: ref.read(serumDefinitionsProvider),
      cabinType: session.cabinType,
    );
    return [
      for (final s in list)
        ReportScenario(
          group: s.group,
          title: s.title,
          location: s.location,
          status: results[s.id]?.status ?? TestStatus.pending,
          detail: results[s.id]?.detail,
          time: results[s.id]?.time,
        ),
    ];
  }

  Future<void> _export() async {
    setState(() => _busy = true);
    final session = ref.read(sessionProvider);
    final active = ref.read(cabinSessionProvider).active;
    final serum = ref.read(serumDefinitionsProvider).values.toList()
      ..sort((a, b) => a.addressIndex.compareTo(b.addressIndex));
    try {
      final path = await ref
          .read(testReportProvider)
          .export(
            user: session.user?.fullName,
            port: session.port,
            cabinType: session.cabinType?.label,
            traffic: ref.read(trafficLogProvider).entries,
            cabinLines: active == null ? const [] : ['Kaynak: ${active.source.label}', ...active.describe()],
            serumLines: [for (final t in serum) ...t.describe()],
            scenarios: _scenarios(),
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
    // Senaryo özetinin güncel kalması için.
    ref.watch(scenarioResultsProvider);
    ref.watch(serumDefinitionsProvider);
    ref.watch(cabinSessionProvider);
    final scenarios = _scenarios();
    final steps = report.steps.reversed.toList();
    final failedSteps = report.steps.where((s) => s.result == StepResult.fail).length;

    int count(TestStatus st) => scenarios.where((s) => s.status == st).length;
    final waiting = scenarios.where((s) => !s.status.isFinished).length;

    final groups = <String, List<ReportScenario>>{};
    for (final s in scenarios) {
      groups.putIfAbsent(s.group, () => []).add(s);
    }

    return ListView(
      padding: const EdgeInsets.all(MedSpacing.xl2),
      children: [
        SectionCard(
          title: 'Test raporu',
          trailing: TextButton(onPressed: steps.isEmpty ? null : report.clear, child: const Text('Adımları temizle')),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: MedSpacing.md,
                runSpacing: MedSpacing.sm,
                children: [
                  StatusBadge(status: TestStatus.passed, label: '${count(TestStatus.passed)} başarılı'),
                  StatusBadge(status: TestStatus.failed, label: '${count(TestStatus.failed)} başarısız'),
                  StatusBadge(status: TestStatus.skipped, label: '${count(TestStatus.skipped)} atlandı'),
                  StatusBadge(status: TestStatus.pending, label: '$waiting yapılmadı'),
                  StatusBadge(status: TestStatus.info, label: '${report.steps.length} adım · $failedSteps hatalı'),
                ],
              ),
              const SizedBox(height: MedSpacing.lg),
              BusyButton(label: 'Raporu dosyaya kaydet', icon: Icons.save_alt, busy: _busy, onPressed: _export),
              const SizedBox(height: MedSpacing.sm),
              Text(
                _lastPath ??
                    'Rapor Belgeler\\PharMed-HwTest klasörüne kaydedilir: kabin ve serum tanımı, senaryo sonuçları, '
                        'zaman sıralı adımlar ve hat trafiği. Hatalı adımların altına o adımın ham trafiği eklenir.',
                style: hintStyle(),
              ),
            ],
          ),
        ),
        if (scenarios.isNotEmpty)
          SectionCard(
            title: 'Test senaryoları',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final entry in groups.entries) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: MedSpacing.md, bottom: MedSpacing.xs),
                    child: Text(entry.key, style: MedTextStyles.titleSm()),
                  ),
                  for (final s in entry.value)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: MedSpacing.xs),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          StatusIcon(status: s.status, size: 16),
                          const SizedBox(width: MedSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(s.title),
                                Text(
                                  [s.location, if (s.detail != null) s.detail!].join(' · '),
                                  style: hintStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          StatusBadge(status: s.status, label: s.status.isFinished ? null : 'Yapılmadı'),
                        ],
                      ),
                    ),
                ],
              ],
            ),
          ),
        if (steps.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: MedSpacing.md),
            child: Text('Test adımları (en yeni üstte)', style: MedTextStyles.titleSm()),
          ),
        for (final s in steps)
          Card(
            child: ListTile(
              leading: ResultBadge(result: s.result, label: s.resultLabel),
              title: Text(s.title),
              subtitle: s.detail == null || s.detail!.isEmpty ? null : Text(s.detail!, style: monoStyle(fontSize: 12.5)),
              trailing: Text(formatTime(s.time)),
            ),
          ),
      ],
    );
  }
}
