import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../core/cabin_session.dart';
import '../../core/cabin_type.dart';
import '../../core/providers.dart';
import '../../core/report.dart';
import '../../core/scenarios.dart';
import '../../core/serum_definition.dart';
import '../../core/serum_hardware.dart';
import '../../widgets/common.dart';

/// Kabin tanımından üretilen test senaryoları. Her senaryonun sonucu ayrı
/// görünür; "Sıradaki testi çalıştır" sonucu olmayan ilk senaryoyu başlatır.
class TestsPage extends ConsumerStatefulWidget {
  const TestsPage({super.key});

  @override
  ConsumerState<TestsPage> createState() => _TestsPageState();
}

class _TestsPageState extends ConsumerState<TestsPage> {
  /// Çalışan senaryo.
  String? _busy;

  /// Komut gönderildi, teknisyenin fiziksel onayı bekleniyor.
  String? _awaiting;

  /// Akış testinin anlık adımı.
  String? _liveStep;
  bool _cancel = false;

  /// Rehberli tur: senaryolar sırayla, kendiliğinden çalıştırılır.
  bool _tour = false;

  ScenarioResultsNotifier get _results => ref.read(scenarioResultsProvider.notifier);

  TestReport get _report => ref.read(testReportProvider);

  SerumHardware get _hw => SerumHardware(serial: ref.read(serialServiceProvider), ops: ref.read(cabinOpsProvider));

  @override
  void dispose() {
    _cancel = true;
    _tour = false;
    super.dispose();
  }

  List<TestScenario> _scenarios() => buildScenarios(
    snapshot: ref.read(cabinSessionProvider).active,
    serum: ref.read(serumDefinitionsProvider),
    cabinType: ref.read(sessionProvider).cabinType,
  );

  TestScenario? _nextScenario() {
    final results = ref.read(scenarioResultsProvider);
    return _scenarios().where((s) => results[s.id] == null).firstOrNull;
  }

  // ── Rehberli tur ────────────────────────────────────────────────────

  void _startTour() {
    _report.add('Rehberli test turu başladı', StepResult.info);
    setState(() => _tour = true);
    _continueTour();
  }

  void _stopTour({String reason = 'durduruldu'}) {
    if (!_tour) return;
    _report.add('Rehberli test turu $reason', StepResult.info);
    setState(() {
      _tour = false;
      _cancel = true;
    });
  }

  /// Sıradaki senaryoyu başlatır. Onay bekleyen senaryoda durur; onay
  /// gelince ([_observe] / [_skip]) kaldığı yerden devam eder.
  Future<void> _continueTour() async {
    if (!_tour || !mounted || _busy != null || _awaiting != null) return;
    final next = _nextScenario();
    if (next == null) {
      _stopTour(reason: 'tamamlandı');
      if (mounted) showMessage(context, 'Tüm testler tamamlandı.');
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!_tour || !mounted) return;
    await _run(next);
    if (_awaiting == null) await _continueTour();
  }

  Future<void> _run(TestScenario s) async {
    setState(() {
      _busy = s.id;
      _awaiting = null;
      _liveStep = null;
      _cancel = false;
    });
    _results.set(s.id, TestStatus.running);
    final title = '[${s.group}] ${s.title}';
    try {
      switch (s.kind) {
        case ScenarioKind.cubicMainLock:
          final address = DrawerAddress.cubicMaster(s.row);
          await ref
              .read(cabinOpsProvider)
              .openMasterDrawer(
                manager: ManagementCard(addressIndex: s.addressIndex),
                row: address.row,
                port: address.port,
                drawer: address.index,
              );
          await _hw.release(s.addressIndex);
          _awaitObservation(s, 'Açma komutu kabul edildi');
        case ScenarioKind.mobileDrawer:
          await ref
              .read(cabinOpsProvider)
              .openMobileDrawer(manager: ManagementCard(addressIndex: s.addressIndex), port: s.port!);
          await _hw.release(s.addressIndex);
          _awaitObservation(s, 'Açma komutu kabul edildi');
        case ScenarioKind.serumLid:
          String? error;
          try {
            await _hw.openLid(s.addressIndex, s.row, s.lidPort!);
          } catch (e) {
            error = '$e';
          }
          String? status;
          for (var i = 0; i < 3; i++) {
            await Future<void>.delayed(const Duration(milliseconds: 500));
            status = await _hw.lidStatus(s.addressIndex, s.row, s.lidPort!);
            if (SerumHardware.lidIsOpen(status)) break;
          }
          await _hw.release(s.addressIndex);
          if (error != null && !SerumHardware.lidIsOpen(status)) {
            _finish(s, title, TestStatus.failed, 'Açılamadı: $error');
          } else {
            _awaitObservation(s, 'Kart: ${SerumHardware.lidStatusText(status)}');
          }
        case ScenarioKind.lockCard:
          final present = await _hw.trayCardPresent(s.lockCardId!);
          _finish(
            s,
            title,
            present ? TestStatus.passed : TestStatus.failed,
            present ? 'Kilit kartı cevap verdi' : 'Kilit kartı cevap vermedi',
          );
        case ScenarioKind.trayFlow:
          final steps = <String>[];
          final ok = await _hw.runTrayFlow(
            address: s.addressIndex,
            row: s.row,
            lidPort: s.lidPort!,
            deviceId: s.lockCardId!,
            trayPort: s.trayPort!,
            isCancelled: () => _cancel || !mounted,
            onStep: (step, status, detail) {
              if (status == TestStatus.running) {
                if (mounted) setState(() => _liveStep = step.label);
              } else {
                steps.add('${status == TestStatus.passed ? 'OK  ' : 'HATA'} ${step.label}: $detail');
              }
            },
          );
          final failedStep = steps.where((l) => l.startsWith('HATA')).firstOrNull;
          _finish(
            s,
            title,
            ok ? TestStatus.passed : TestStatus.failed,
            ok ? 'Avadanlık çekildi, yerine itildi; kapak kapandı' : (failedStep ?? 'Durduruldu'),
            reportDetail: steps.join('\n'),
          );
      }
    } catch (e) {
      await _hw.release(s.addressIndex);
      _finish(s, title, TestStatus.failed, 'HATA: $e');
    }
    if (mounted) {
      setState(() {
        _busy = null;
        _liveStep = null;
      });
    }
  }

  void _awaitObservation(TestScenario s, String note) {
    _results.set(s.id, TestStatus.running, detail: '$note — fiziksel olarak açıldı mı?');
    if (mounted) setState(() => _awaiting = s.id);
  }

  void _observe(TestScenario s, bool opened) {
    _finish(
      s,
      '[${s.group}] ${s.title}',
      opened ? TestStatus.passed : TestStatus.failed,
      opened ? 'Açıldı (teknisyen onayı)' : 'Açılmadı (teknisyen gözlemi)',
    );
    setState(() => _awaiting = null);
    if (_tour) _continueTour();
  }

  void _skip(TestScenario s) {
    _finish(s, '[${s.group}] ${s.title}', TestStatus.skipped, 'Teknisyen atladı');
    setState(() {
      if (_awaiting == s.id) _awaiting = null;
    });
    if (_tour) _continueTour();
  }

  void _finish(TestScenario s, String title, TestStatus status, String detail, {String? reportDetail}) {
    _results.set(s.id, status, detail: detail);
    _report.add(
      title,
      switch (status) {
        TestStatus.passed => StepResult.ok,
        TestStatus.failed => StepResult.fail,
        _ => StepResult.info,
      },
      detail: [s.location, detail, if (reportDetail != null && reportDetail.isNotEmpty) reportDetail].join('\n'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final active = ref.watch(cabinSessionProvider.select((s) => s.active));
    final cabinType = ref.watch(sessionProvider.select((s) => s.cabinType));
    final connected = ref.watch(sessionProvider.select((s) => s.port != null));
    final serum = ref.watch(serumDefinitionsProvider);
    final results = ref.watch(scenarioResultsProvider);
    final scenarios = buildScenarios(snapshot: active, serum: serum, cabinType: cabinType);

    if (active == null) {
      return ListView(
        padding: const EdgeInsets.all(MedSpacing.xl2),
        children: const [
          SectionCard(
            title: 'Testler',
            child: Text('Önce Kabin sayfasında client tanımıyla devam edin ya da kabini tarayın.'),
          ),
        ],
      );
    }

    final finished = scenarios.where((s) => results[s.id]?.status.isFinished ?? false).length;
    final passed = scenarios.where((s) => results[s.id]?.status == TestStatus.passed).length;
    final failed = scenarios.where((s) => results[s.id]?.status == TestStatus.failed).length;
    final next = scenarios.where((s) => results[s.id] == null).firstOrNull;
    final idle = connected && _busy == null && _awaiting == null && !_tour;

    final groups = <String, List<TestScenario>>{};
    for (final s in scenarios) {
      groups.putIfAbsent(s.group, () => []).add(s);
    }

    return ListView(
      padding: const EdgeInsets.all(MedSpacing.xl2),
      children: [
        SectionCard(
          title: 'Testler',
          trailing: Wrap(
            spacing: MedSpacing.md,
            children: [
              StatusBadge(status: TestStatus.passed, label: '$passed başarılı'),
              StatusBadge(status: TestStatus.failed, label: '$failed başarısız'),
              StatusBadge(status: TestStatus.pending, label: '${scenarios.length - finished} bekliyor'),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (scenarios.isEmpty)
                Text(
                  cabinType == HwCabinType.patientBased
                      ? 'Tanımda mobil çekmece yok. Çekmeceleri Mobil kabin sayfasından port bazlı test edin.'
                      : 'Tanımda otomatik test edilebilir birim yok (kübik çekmece, serum kapağı ya da kilitli raf).',
                )
              else ...[
                ClipRRect(
                  borderRadius: MedRadius.smAll,
                  child: LinearProgressIndicator(
                    value: finished / scenarios.length,
                    minHeight: 8,
                    backgroundColor: MedColors.surface3,
                    color: failed > 0 ? TestStatus.failed.color : TestStatus.passed.color,
                  ),
                ),
                const SizedBox(height: MedSpacing.md),
                Text('$finished / ${scenarios.length} test tamamlandı', style: MedTextStyles.bodyMd()),
                const SizedBox(height: MedSpacing.lg),
                Wrap(
                  spacing: MedSpacing.lg,
                  runSpacing: MedSpacing.md,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (_tour)
                      OutlinedButton.icon(
                        onPressed: () => _stopTour(),
                        icon: const Icon(Icons.stop),
                        label: const Text('Turu durdur'),
                      )
                    else ...[
                      FilledButton.icon(
                        onPressed: idle && next != null ? _startTour : null,
                        icon: const Icon(Icons.playlist_play),
                        label: const Text('Rehberli turu başlat'),
                      ),
                      OutlinedButton.icon(
                        onPressed: idle && next != null ? () => _run(next) : null,
                        icon: const Icon(Icons.play_arrow),
                        label: Text(next == null ? 'Tüm testler tamamlandı' : 'Yalnız sıradakini çalıştır'),
                      ),
                    ],
                    if (!connected) const NotConnectedHint(),
                  ],
                ),
                if (_tour || _busy != null || _awaiting != null) ...[
                  const SizedBox(height: MedSpacing.lg),
                  _CurrentPanel(
                    scenario: scenarios.where((s) => s.id == (_awaiting ?? _busy)).firstOrNull ?? next,
                    running: _busy != null,
                    liveStep: _liveStep,
                    awaiting: _awaiting != null,
                    tour: _tour,
                    onObserve: (opened) {
                      final current = scenarios.where((s) => s.id == _awaiting).firstOrNull;
                      if (current != null) _observe(current, opened);
                    },
                  ),
                ] else if (next != null) ...[
                  const SizedBox(height: MedSpacing.sm),
                  Text('Sıradaki: ${next.title}', style: hintStyle()),
                ],
              ],
              const SizedBox(height: MedSpacing.lg),
              Text(
                cabinType == HwCabinType.patientBased
                    ? 'Mobil çekmeceler client tanımından gelir. Taramada çekmece sayısı okunamaz.'
                    : 'Birim doz gözleri ve kübik kapaklar Master çekmece sayfasından test edilir. Serum raflarını '
                          'Serum sayfasında tanımladıkça kilit testleri buraya eklenir.',
                style: hintStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        for (final entry in groups.entries)
          SectionCard(
            title: entry.key,
            child: Column(
              children: [
                for (final s in entry.value)
                  _ScenarioRow(
                    scenario: s,
                    result: results[s.id],
                    running: _busy == s.id,
                    liveStep: _busy == s.id ? _liveStep : null,
                    awaiting: _awaiting == s.id,
                    canRun: idle,
                    onRun: () => _run(s),
                    onObserve: (opened) => _observe(s, opened),
                    onSkip: _busy == null && (!_tour || _awaiting == s.id) ? () => _skip(s) : null,
                    onStop: s.kind == ScenarioKind.trayFlow && _busy == s.id ? () => setState(() => _cancel = true) : null,
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ScenarioRow extends StatelessWidget {
  const _ScenarioRow({
    required this.scenario,
    required this.result,
    required this.running,
    required this.liveStep,
    required this.awaiting,
    required this.canRun,
    required this.onRun,
    required this.onObserve,
    required this.onSkip,
    required this.onStop,
  });

  final TestScenario scenario;
  final ScenarioResult? result;
  final bool running;
  final String? liveStep;
  final bool awaiting;
  final bool canRun;
  final VoidCallback onRun;
  final void Function(bool opened) onObserve;
  final VoidCallback? onSkip;
  final VoidCallback? onStop;

  @override
  Widget build(BuildContext context) {
    final status = running ? TestStatus.running : (result?.status ?? TestStatus.pending);
    final detail = running && liveStep != null ? liveStep : result?.detail;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: MedSpacing.md),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: MedColors.border2))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: const EdgeInsets.only(top: 2), child: StatusIcon(status: status)),
          const SizedBox(width: MedSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(scenario.title, style: MedTextStyles.bodyMd(color: MedColors.text, weight: FontWeight.w600)),
                Text(scenario.location, style: monoStyle(fontSize: 11, color: MedColors.text3)),
                if (detail != null) Text(detail, style: TextStyle(color: status.color, fontSize: 12.5)),
                if (awaiting) ...[
                  const SizedBox(height: MedSpacing.sm),
                  Wrap(
                    spacing: MedSpacing.md,
                    children: [
                      ActionChip(
                        avatar: Icon(TestStatus.passed.icon, color: TestStatus.passed.color, size: 18),
                        label: const Text('Açıldı'),
                        onPressed: () => onObserve(true),
                      ),
                      ActionChip(
                        avatar: Icon(TestStatus.failed.icon, color: TestStatus.failed.color, size: 18),
                        label: const Text('Açılmadı'),
                        onPressed: () => onObserve(false),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: MedSpacing.lg),
          StatusBadge(status: status),
          const SizedBox(width: MedSpacing.md),
          if (onStop != null)
            TextButton.icon(onPressed: onStop, icon: const Icon(Icons.stop), label: const Text('Durdur'))
          else
            OutlinedButton(
              onPressed: canRun ? onRun : null,
              child: Text(result == null ? 'Çalıştır' : 'Tekrar'),
            ),
          IconButton(
            tooltip: 'Atla',
            onPressed: onSkip,
            icon: const Icon(Icons.skip_next),
          ),
        ],
      ),
    );
  }
}

/// Turda / çalışırken o anki senaryo: ne yapıldığı ve büyük onay düğmeleri.
class _CurrentPanel extends StatelessWidget {
  const _CurrentPanel({
    required this.scenario,
    required this.running,
    required this.liveStep,
    required this.awaiting,
    required this.tour,
    required this.onObserve,
  });

  final TestScenario? scenario;
  final bool running;
  final String? liveStep;
  final bool awaiting;
  final bool tour;
  final void Function(bool opened) onObserve;

  @override
  Widget build(BuildContext context) {
    final s = scenario;
    if (s == null) return const SizedBox.shrink();
    final colors = TestStatus.running.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(MedSpacing.xl),
      decoration: BoxDecoration(
        color: colors.background,
        border: Border.all(color: colors.border(alpha: 0.5)),
        borderRadius: MedRadius.lgAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tour ? 'Rehberli tur — şu anki test' : 'Şu anki test', style: hintStyle(fontSize: 12)),
          const SizedBox(height: MedSpacing.xs),
          Text(s.title, style: MedTextStyles.titleLg()),
          Text('${s.group} · ${s.location}', style: monoStyle(fontSize: 11, color: MedColors.text3)),
          const SizedBox(height: MedSpacing.md),
          if (awaiting) ...[
            Text('Kapı / kapak fiziksel olarak açıldı mı?', style: MedTextStyles.bodyLg()),
            const SizedBox(height: MedSpacing.md),
            Row(
              children: [
                FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: TestStatus.passed.color, minimumSize: const Size(180, 52)),
                  onPressed: () => onObserve(true),
                  icon: Icon(TestStatus.passed.icon),
                  label: const Text('Açıldı'),
                ),
                const SizedBox(width: MedSpacing.lg),
                FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: TestStatus.failed.color, minimumSize: const Size(180, 52)),
                  onPressed: () => onObserve(false),
                  icon: Icon(TestStatus.failed.icon),
                  label: const Text('Açılmadı'),
                ),
              ],
            ),
          ] else if (running)
            Row(
              children: [
                const StatusIcon(status: TestStatus.running),
                const SizedBox(width: MedSpacing.md),
                Text(liveStep ?? 'Komut gönderiliyor…'),
              ],
            )
          else
            Text('Sıradaki teste geçiliyor…', style: hintStyle()),
        ],
      ),
    );
  }
}
