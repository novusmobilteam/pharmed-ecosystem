import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_hardware/pharmed_hardware.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../core/cabin_session.dart';
import '../../core/peripherals.dart';
import '../../core/providers.dart';
import '../../core/report.dart';
import '../../core/scenarios.dart';
import '../../widgets/common.dart';
import '../../widgets/fingerprint_image_view.dart';

/// Çevre birimleri: fiş yazıcı (deneme fişi), parmak izi okuyucu (bağlantı,
/// okuma, kalite), IP kamera (görüntü ve deneme kaydı). Sonuçlar rapora ve
/// Testler'deki "Çevre birimleri" senaryolarına yazılır.
class PeripheralsPage extends ConsumerWidget {
  const PeripheralsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(MedSpacing.xl2),
      children: const [_PrinterCard(), _FingerprintCard(), _CameraCard()],
    );
  }
}

void _scenario(WidgetRef ref, String id, TestStatus status, String detail) =>
    ref.read(scenarioResultsProvider.notifier).set(id, status, detail: detail);

/// "Düzgün / Sorunlu" teknisyen onayı.
class _Confirm extends StatelessWidget {
  const _Confirm({required this.question, required this.yes, required this.no, required this.onAnswer});

  final String question;
  final String yes;
  final String no;
  final void Function(bool ok) onAnswer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: MedSpacing.lg),
      child: Wrap(
        spacing: MedSpacing.lg,
        runSpacing: MedSpacing.md,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(question, style: MedTextStyles.bodyLg()),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: TestStatus.passed.color),
            onPressed: () => onAnswer(true),
            icon: Icon(TestStatus.passed.icon),
            label: Text(yes),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: TestStatus.failed.color),
            onPressed: () => onAnswer(false),
            icon: Icon(TestStatus.failed.icon),
            label: Text(no),
          ),
        ],
      ),
    );
  }
}

// ── Fiş yazıcı ───────────────────────────────────────────────────────────

class _PrinterCard extends ConsumerStatefulWidget {
  const _PrinterCard();

  @override
  ConsumerState<_PrinterCard> createState() => _PrinterCardState();
}

class _PrinterCardState extends ConsumerState<_PrinterCard> {
  static const _bauds = [9600, 19200, 38400, 57600, 115200];

  PrinterConnectionType _type = PrinterConnectionType.serial;
  String? _target;
  int _baud = PrinterConfig.defaultBaudRate;
  List<String> _targets = const [];
  bool _busy = false;
  bool _awaiting = false;
  String? _result;
  TestStatus? _status;
  bool _prefilled = false;

  @override
  void initState() {
    super.initState();
    _loadTargets();
  }

  /// Client'ın yazıcı ayarıyla bir kez doldurur (build içinden; setState yok).
  void _prefill(PrinterConfig? config) {
    if (_prefilled || config == null) return;
    _prefilled = true;
    _type = config.connectionType;
    _baud = config.baudRate;
    _target = config.target;
    _loadTargets();
  }

  void _loadTargets() {
    final targets = _type == PrinterConnectionType.serial
        ? SerialPrinterTransport.availablePorts()
        : WindowsSpoolerPrinterTransport.installedPrinters();
    _targets = targets;
    if (_target != null && !targets.contains(_target)) _target = null;
    _target ??= targets.isNotEmpty ? targets.first : null;
  }

  void _refreshTargets() => setState(_loadTargets);

  PrinterConfig? get _config =>
      _target == null ? null : PrinterConfig(connectionType: _type, target: _target!, baudRate: _baud);

  Future<void> _print() async {
    final config = _config;
    if (config == null) return;
    final cabinPort = ref.read(sessionProvider).port;
    if (config.connectionType == PrinterConnectionType.serial && config.target == cabinPort) {
      return showMessage(context, '${config.target} kabin bağlantısında kullanılıyor; yazıcının portunu seçin.', error: true);
    }
    setState(() {
      _busy = true;
      _awaiting = false;
      _result = null;
      _status = TestStatus.running;
    });
    final printer = EscPosReceiptPrinter(loadConfig: () async => config);
    final result = await printer.printReceipt(buildTestReceipt(config));
    await printer.close();
    final error = result.when(ok: (_) => null, error: (e) => e.message);
    final where = config.connectionType == PrinterConnectionType.serial
        ? '${config.target} · ${config.baudRate}'
        : config.target;
    ref
        .read(testReportProvider)
        .add('Fiş yazıcı deneme fişi ($where)', error == null ? StepResult.info : StepResult.fail, detail: error);
    if (error != null) _scenario(ref, ScenarioIds.printer, TestStatus.failed, 'Yazdırılamadı: $error');
    if (!mounted) return;
    setState(() {
      _busy = false;
      _awaiting = error == null;
      _result = error == null ? 'Fiş gönderildi ($where)' : 'Yazdırılamadı: $error';
      _status = error == null ? TestStatus.running : TestStatus.failed;
    });
  }

  void _answer(bool ok) {
    final detail = ok
        ? 'Deneme fişi düzgün basıldı (Türkçe karakterler, barkodlar)'
        : 'Deneme fişi sorunlu (teknisyen gözlemi)';
    ref.read(testReportProvider).add('Gözlem: $detail', ok ? StepResult.ok : StepResult.fail);
    _scenario(ref, ScenarioIds.printer, ok ? TestStatus.passed : TestStatus.failed, detail);
    setState(() {
      _awaiting = false;
      _status = ok ? TestStatus.passed : TestStatus.failed;
      _result = detail;
    });
  }

  @override
  Widget build(BuildContext context) {
    _prefill(ref.watch(cabinSessionProvider.select((s) => s.cache?.printer)));
    final status = _status ?? TestStatus.pending;
    return SectionCard(
      title: 'Fiş yazıcı',
      trailing: StatusBadge(status: status),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: MedSpacing.lg,
            runSpacing: MedSpacing.md,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SegmentedButton<PrinterConnectionType>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: PrinterConnectionType.serial, label: Text('Seri port')),
                  ButtonSegment(value: PrinterConnectionType.windowsSpooler, label: Text('Windows yazıcısı')),
                ],
                selected: {_type},
                onSelectionChanged: _busy
                    ? null
                    : (v) {
                        _type = v.first;
                        _target = null;
                        _refreshTargets();
                      },
              ),
              DropdownButton<String>(
                value: _target,
                hint: Text(_type == PrinterConnectionType.serial ? 'Port yok' : 'Yazıcı yok'),
                items: [for (final t in _targets) DropdownMenuItem(value: t, child: Text(t))],
                onChanged: _busy ? null : (v) => setState(() => _target = v),
              ),
              if (_type == PrinterConnectionType.serial)
                DropdownButton<int>(
                  value: _baud,
                  items: [for (final b in _bauds) DropdownMenuItem(value: b, child: Text('$b baud'))],
                  onChanged: _busy ? null : (v) => setState(() => _baud = v ?? _baud),
                ),
              IconButton(tooltip: 'Listeyi yenile', onPressed: _busy ? null : _refreshTargets, icon: const Icon(Icons.refresh)),
              BusyButton(label: 'Deneme fişi bas', icon: Icons.print, busy: _busy, onPressed: _config == null ? null : _print),
            ],
          ),
          const SizedBox(height: MedSpacing.sm),
          Text(
            'Client ile aynı yazıcı sürücüsü kullanılır. Fişte Türkçe karakterler, ayraçlar, Code128 ve EAN-13 barkod vardır.',
            style: hintStyle(fontSize: 12),
          ),
          if (_result != null) ...[
            const SizedBox(height: MedSpacing.md),
            Text(_result!, style: TextStyle(color: status.color)),
          ],
          if (_awaiting)
            _Confirm(
              question: 'Fiş düzgün basıldı mı?',
              yes: 'Düzgün',
              no: 'Sorunlu',
              onAnswer: _answer,
            ),
        ],
      ),
    );
  }
}

// ── Parmak izi okuyucu ───────────────────────────────────────────────────

class _Attempt {
  _Attempt({required this.elapsed, this.capture, this.error});

  final Duration elapsed;
  final FingerprintCapture? capture;
  final String? error;
}

class _FingerprintCard extends ConsumerStatefulWidget {
  const _FingerprintCard();

  @override
  ConsumerState<_FingerprintCard> createState() => _FingerprintCardState();
}

class _FingerprintCardState extends ConsumerState<_FingerprintCard> {
  static const _minQuality = 30;

  IFingerprintScanner? _scanner;
  FingerprintScannerInfo? _info;
  bool _busy = false;
  bool _capturing = false;
  String? _error;
  bool? _fingerOn;
  final List<_Attempt> _attempts = [];

  TestReport get _report => ref.read(testReportProvider);

  @override
  void dispose() {
    final s = _scanner;
    if (s != null) {
      s.cancelCapture();
      s.close();
    }
    super.dispose();
  }

  Future<void> _open() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final scanner = _scanner ??= createFingerprintScanner();
    final result = await scanner.open();
    final info = result.when(ok: (i) => i, error: (_) => null);
    final error = result.when(ok: (_) => null, error: fingerprintErrorText);
    final infoText = info == null
        ? null
        : '${info.vendor} ${info.model}${info.serial != null ? ' · seri ${info.serial}' : ''}'
              '${info.sdkVersion != null ? ' · SDK ${info.sdkVersion}' : ''} · canlılık ${info.livenessActive ? 'etkin' : 'KAPALI'}';
    _report.add(
      'Parmak izi okuyucu bağlantısı',
      info != null ? StepResult.ok : StepResult.fail,
      detail: infoText ?? error,
    );
    if (info == null) _scenario(ref, ScenarioIds.fingerprint, TestStatus.failed, error ?? 'Bağlanılamadı');
    if (!mounted) return;
    setState(() {
      _busy = false;
      _info = info;
      _error = error;
    });
  }

  Future<void> _close() async {
    await _scanner?.close();
    _report.add('Parmak izi okuyucu kapatıldı', StepResult.info);
    if (mounted) setState(() => _info = null);
  }

  Future<void> _capture() async {
    final scanner = _scanner;
    if (scanner == null) return;
    setState(() {
      _capturing = true;
      _error = null;
    });
    final watch = Stopwatch()..start();
    final result = await scanner.capture(
      timeout: const Duration(seconds: 10),
      minQuality: _minQuality,
      includeImage: true,
    );
    watch.stop();
    final attempt = result.when(
      ok: (c) => _Attempt(elapsed: watch.elapsed, capture: c),
      error: (e) => _Attempt(elapsed: watch.elapsed, error: fingerprintErrorText(e)),
    );
    final c = attempt.capture;
    final detail = c != null
        ? 'kalite ${c.quality}${c.lfdScore != null ? ' · canlılık puanı ${c.lfdScore}' : ''} · şablon ${c.templateSize} bayt'
              '${c.image != null ? ' · görüntü ${c.image!.width}×${c.image!.height} @ ${c.image!.resolutionDpi} dpi' : ''}'
              ' · ${attempt.elapsed.inMilliseconds} ms'
        : attempt.error!;
    _report.add('Parmak izi okuma', c != null ? StepResult.ok : StepResult.fail, detail: detail);
    final info = _info;
    if (c != null) {
      _scenario(
        ref,
        ScenarioIds.fingerprint,
        TestStatus.passed,
        '${info != null ? '${info.vendor} ${info.model} · ' : ''}$detail',
      );
    } else if (ref.read(scenarioResultsProvider)[ScenarioIds.fingerprint]?.status != TestStatus.passed) {
      _scenario(ref, ScenarioIds.fingerprint, TestStatus.failed, detail);
    }
    if (!mounted) return;
    setState(() {
      _capturing = false;
      _attempts.insert(0, attempt);
      if (_attempts.length > 5) _attempts.removeLast();
    });
  }

  Future<void> _checkFinger() async {
    final scanner = _scanner;
    if (scanner == null) return;
    final result = await scanner.isFingerOn();
    if (!mounted) return;
    setState(() {
      _fingerOn = result.data;
      _error = result.when(ok: (_) => null, error: fingerprintErrorText);
    });
  }

  @override
  Widget build(BuildContext context) {
    final info = _info;
    final open = info != null;
    final last = _attempts.firstOrNull;
    final status = ref.watch(scenarioResultsProvider.select((r) => r[ScenarioIds.fingerprint]?.status)) ??
        (open ? TestStatus.running : TestStatus.pending);
    return SectionCard(
      title: 'Parmak izi okuyucu',
      trailing: StatusBadge(status: status),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: MedSpacing.lg,
                  runSpacing: MedSpacing.md,
                  children: [
                    if (!open)
                      BusyButton(label: 'Okuyucuya bağlan', icon: Icons.usb, busy: _busy, onPressed: _open)
                    else ...[
                      BusyButton(
                        label: 'Parmak oku',
                        icon: Icons.fingerprint,
                        busy: _capturing,
                        onPressed: _busy ? null : _capture,
                      ),
                      if (_capturing)
                        OutlinedButton(onPressed: () => _scanner?.cancelCapture(), child: const Text('İptal'))
                      else ...[
                        OutlinedButton(onPressed: _checkFinger, child: const Text('Parmak sensörde mi?')),
                        TextButton(onPressed: _close, child: const Text('Kapat')),
                      ],
                    ],
                  ],
                ),
                if (_error != null) ...[const SizedBox(height: MedSpacing.md), ErrorText(_error!)],
                if (info != null) ...[
                  const SizedBox(height: MedSpacing.md),
                  _kv('Okuyucu', '${info.vendor} · ${info.model} (tip ${info.scannerType})'),
                  if (info.serial != null) _kv('Seri no', info.serial!),
                  if (info.sdkVersion != null) _kv('SDK', info.sdkVersion!),
                  _kv('Canlılık kontrolü', info.livenessActive ? 'Etkin' : 'Kapalı — sahte parmak algılanmaz'),
                  if (_fingerOn != null) _kv('Sensörde parmak', _fingerOn! ? 'Var' : 'Yok'),
                ],
                if (_capturing) ...[
                  const SizedBox(height: MedSpacing.md),
                  Text('Parmağınızı okuyucuya koyun (10 sn)…', style: MedTextStyles.bodyLg()),
                ],
                if (last?.capture case final c?) ...[
                  const SizedBox(height: MedSpacing.lg),
                  Text('Son okuma', style: MedTextStyles.titleSm()),
                  _kv('Kalite', '${c.quality} / 100 (en az $_minQuality)'),
                  if (c.lfdScore != null) _kv('Canlılık puanı', '${c.lfdScore}'),
                  _kv('Şablon', '${c.templateSize} bayt · ${c.format.name}'),
                  if (c.image != null)
                    _kv('Görüntü', '${c.image!.width}×${c.image!.height} · ${c.image!.resolutionDpi} dpi'),
                  _kv('Süre', '${last!.elapsed.inMilliseconds} ms'),
                ],
                if (_attempts.isNotEmpty) ...[
                  const SizedBox(height: MedSpacing.lg),
                  Text('Son denemeler', style: MedTextStyles.titleSm()),
                  for (final a in _attempts)
                    Row(
                      children: [
                        StatusIcon(status: a.capture != null ? TestStatus.passed : TestStatus.failed, size: 16),
                        const SizedBox(width: MedSpacing.md),
                        Expanded(
                          child: Text(
                            a.capture != null ? 'kalite ${a.capture!.quality}' : a.error!,
                            style: hintStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                ],
              ],
            ),
          ),
          const SizedBox(width: MedSpacing.xl),
          SizedBox(
            width: 180,
            height: 220,
            child: FingerprintImageView(image: last?.capture?.image, placeholder: 'Okunan parmak izi burada görünür'),
          ),
        ],
      ),
    );
  }

  Widget _kv(String k, String v) => Padding(
    padding: const EdgeInsets.only(bottom: 2),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 140, child: Text(k, style: hintStyle())),
        Expanded(child: Text(v)),
      ],
    ),
  );
}

// ── Kamera ───────────────────────────────────────────────────────────────

class _CameraCard extends ConsumerStatefulWidget {
  const _CameraCard();

  @override
  ConsumerState<_CameraCard> createState() => _CameraCardState();
}

class _CameraCardState extends ConsumerState<_CameraCard> {
  final _host = TextEditingController();
  final _user = TextEditingController(text: 'admin');
  final _password = TextEditingController();
  final _port = TextEditingController(text: '554');
  int _channel = 101;

  /// Client tanımından seçilen kamera (null → elle).
  String? _cameraId;
  bool _busy = false;
  bool _awaiting = false;
  CameraTestResult? _result;
  String? _error;

  final _tester = CameraTester();

  @override
  void dispose() {
    for (final c in [_host, _user, _password, _port]) {
      c.dispose();
    }
    super.dispose();
  }

  void _select(List<CameraDevice> cameras, String? id) {
    setState(() {
      _cameraId = id;
      _result = null;
      _awaiting = false;
      _error = null;
    });
    final c = cameras.where((x) => x.id == id).firstOrNull;
    if (c == null) return;
    _host.text = c.host;
    _user.text = c.username;
    _port.text = '${c.rtspPort}';
    _channel = c.channel;
    _password.clear();
  }

  CameraTarget? get _target {
    final port = int.tryParse(_port.text.trim());
    if (_host.text.trim().isEmpty || port == null) return null;
    return CameraTarget(
      host: _host.text.trim(),
      username: _user.text.trim(),
      password: _password.text,
      rtspPort: port,
      channel: _channel,
    );
  }

  String get _name {
    final cameras = ref.read(cabinSessionProvider).cache?.cameras ?? const <CameraDevice>[];
    return cameras.where((c) => c.id == _cameraId).firstOrNull?.name ?? _host.text.trim();
  }

  Future<void> _test() async {
    final target = _target;
    if (target == null) return showMessage(context, 'Adres ve port girin.', error: true);
    setState(() {
      _busy = true;
      _error = null;
      _result = null;
      _awaiting = false;
    });
    try {
      final r = await _tester.test(target);
      final detail =
          'bağlanma ${r.connectTime.inMilliseconds} ms · ${r.bitrateKbps.round()} kbps · ~${r.mbPerMinute.toStringAsFixed(1)} MB/dk';
      ref.read(testReportProvider).add('Kamera $_name (${target.maskedUrl})', StepResult.info, detail: detail);
      if (!mounted) return;
      setState(() {
        _result = r;
        _awaiting = true;
      });
    } on CameraTestException catch (e) {
      ref
          .read(testReportProvider)
          .add('Kamera $_name (${target.maskedUrl})', StepResult.fail, detail: e.toString());
      if (_cameraId != null) _scenario(ref, ScenarioIds.camera(_cameraId!), TestStatus.failed, e.message);
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _refreshSnapshot() async {
    final target = _target;
    if (target == null || _result == null) return;
    setState(() => _busy = true);
    try {
      final (bytes, connect) = await _tester.takeSnapshot(target);
      if (!mounted) return;
      final r = _result!;
      setState(
        () => _result = CameraTestResult(
          snapshot: bytes,
          connectTime: connect,
          sampleDuration: r.sampleDuration,
          sampleBytes: r.sampleBytes,
        ),
      );
    } on CameraTestException catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _answer(bool ok) {
    final r = _result;
    final detail = [
      ok ? 'Görüntü doğru alanı gösteriyor' : 'Görüntü yanlış alanı gösteriyor ya da net değil (teknisyen gözlemi)',
      if (r != null) '${r.bitrateKbps.round()} kbps · ~${r.mbPerMinute.toStringAsFixed(1)} MB/dk',
    ].join(' · ');
    ref.read(testReportProvider).add('Gözlem: kamera $_name — $detail', ok ? StepResult.ok : StepResult.fail);
    if (_cameraId != null) {
      _scenario(ref, ScenarioIds.camera(_cameraId!), ok ? TestStatus.passed : TestStatus.failed, detail);
    }
    setState(() => _awaiting = false);
  }

  @override
  Widget build(BuildContext context) {
    final cameras = ref.watch(cabinSessionProvider.select((s) => s.cache?.cameras)) ?? const <CameraDevice>[];
    final status = _cameraId == null
        ? (_error != null ? TestStatus.failed : (_result != null ? TestStatus.info : TestStatus.pending))
        : (ref.watch(scenarioResultsProvider.select((r) => r[ScenarioIds.camera(_cameraId!)]?.status)) ??
              TestStatus.pending);
    final r = _result;
    return SectionCard(
      title: 'Kamera',
      trailing: StatusBadge(status: status),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: MedSpacing.lg,
            runSpacing: MedSpacing.lg,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (cameras.isNotEmpty)
                DropdownButton<String?>(
                  value: _cameraId,
                  items: [
                    for (final c in cameras) DropdownMenuItem<String?>(value: c.id, child: Text(c.name)),
                    const DropdownMenuItem<String?>(value: null, child: Text('Elle gir')),
                  ],
                  onChanged: _busy ? null : (v) => _select(cameras, v),
                ),
              SizedBox(
                width: 160,
                child: TextField(
                  controller: _host,
                  decoration: const InputDecoration(labelText: 'IP adresi', isDense: true, border: OutlineInputBorder()),
                ),
              ),
              NumberField(label: 'RTSP port', controller: _port, width: 100),
              DropdownButton<int>(
                value: _channel,
                items: const [
                  DropdownMenuItem(value: 101, child: Text('101 · ana akış')),
                  DropdownMenuItem(value: 102, child: Text('102 · alt akış')),
                ],
                onChanged: _busy ? null : (v) => setState(() => _channel = v ?? _channel),
              ),
              SizedBox(
                width: 130,
                child: TextField(
                  controller: _user,
                  decoration: const InputDecoration(labelText: 'Kullanıcı', isDense: true, border: OutlineInputBorder()),
                ),
              ),
              SizedBox(
                width: 150,
                child: TextField(
                  controller: _password,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Şifre', isDense: true, border: OutlineInputBorder()),
                ),
              ),
              BusyButton(label: 'Görüntü al ve test kaydı yap', icon: Icons.videocam, busy: _busy, onPressed: _test),
            ],
          ),
          const SizedBox(height: MedSpacing.sm),
          Text(
            'Client ile aynı yol: RTSP akışından tek kare ve 3 sn deneme kaydı (ffmpeg: ${_tester.ffmpegPath}). '
            'Kamera şifresi client\'ın güvenli deposunda tutulduğu için burada girilir; kaydedilmez.',
            style: hintStyle(fontSize: 12),
          ),
          if (_error != null) ...[const SizedBox(height: MedSpacing.md), ErrorText(_error!)],
          if (r != null) ...[
            const SizedBox(height: MedSpacing.lg),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: MedRadius.mdAll,
                  child: SizedBox(
                    width: 360,
                    height: 203,
                    child: Image.memory(r.snapshot, fit: BoxFit.contain, gaplessPlayback: true),
                  ),
                ),
                const SizedBox(width: MedSpacing.xl),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Bağlanma: ${r.connectTime.inMilliseconds} ms'),
                      Text('Deneme kaydı: ${r.sampleDuration.inSeconds} sn · ${(r.sampleBytes / 1024).round()} KB'),
                      Text('Bitrate: ${r.bitrateKbps.round()} kbps'),
                      Text('Disk: dakikada ~${r.mbPerMinute.toStringAsFixed(1)} MB'),
                      const SizedBox(height: MedSpacing.md),
                      OutlinedButton.icon(
                        onPressed: _busy ? null : _refreshSnapshot,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Görüntüyü yenile'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_awaiting)
              _Confirm(
                question: 'Kamera işlem alanını doğru görüyor mu?',
                yes: 'Evet',
                no: 'Hayır',
                onAnswer: _answer,
              ),
          ],
        ],
      ),
    );
  }
}
