import 'dart:async' show StreamSubscription, Timer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_hardware/pharmed_hardware.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../core/cabin_model.dart';
import '../../core/cabin_session.dart';
import '../../core/providers.dart';
import '../../core/report.dart';
import '../../core/scenarios.dart';
import '../../widgets/common.dart';

/// Bir antenin okuduğu tek etiketin istatistiği.
class _TagStat {
  _TagStat(this.epc);

  final String epc;
  int count = 0;
  int lastRssi = 0;
  int minRssi = 0;
  int maxRssi = -200;
  int _sum = 0;
  DateTime lastSeen = DateTime.now();

  double get avgRssi => count == 0 ? 0 : _sum / count;

  void add(int rssi) {
    if (count == 0) minRssi = rssi;
    count++;
    lastRssi = rssi;
    if (rssi < minRssi) minRssi = rssi;
    if (rssi > maxRssi) maxRssi = rssi;
    _sum += rssi;
    lastSeen = DateTime.now();
  }
}

/// RFID testi (UHFEx10, TCP) — client ile aynı `RfidService`:
///   1. Okuyucu bağlantısı ve bilgisi
///   2. Antenler: hangi portta anten bağlı (okuyucunun anten kontrolü)
///   3. Etiket okuma: anten bazında etiketler, okuma sayısı, RSSI (dBm)
class RfidPage extends ConsumerStatefulWidget {
  const RfidPage({super.key});

  @override
  ConsumerState<RfidPage> createState() => _RfidPageState();
}

class _RfidPageState extends ConsumerState<RfidPage> {
  final _ip = TextEditingController(text: '192.168.1.190');
  final _port = TextEditingController(text: '6000');
  final _power = TextEditingController(text: '30');

  /// Test edilen kabin (client tanımındaki RFID'li kabin); null → elle.
  int? _cabin;

  bool _busy = false;
  bool _connected = false;
  RfidReaderInfo? _info;
  List<int>? _antennas;
  String? _error;

  // Okuma
  StreamSubscription<RfidTag>? _sub;
  DateTime? _started;
  Timer? _timer;
  int _durationSec = 10;
  int _elapsed = 0;

  /// anten → epc → istatistik
  final Map<int, Map<String, _TagStat>> _byAntenna = {};

  /// dispose'ta ref kullanılamadığı için baştan tutulur.
  late final RfidService _rfid = ref.read(rfidServiceProvider);

  TestReport get _report => ref.read(testReportProvider);

  @override
  void initState() {
    super.initState();
    _rfid; // erken oluştur
    Future.microtask(() {
      final first = _rfidCabins().firstOrNull;
      if (first != null) _selectCabin(first.addressIndex);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _sub?.cancel();
    if (_rfid.isConnected) _rfid.disconnect();
    for (final c in [_ip, _port, _power]) {
      c.dispose();
    }
    super.dispose();
  }

  List<CabinInfo> _rfidCabins() =>
      (ref.read(cabinSessionProvider).active?.cabins ?? const <CabinInfo>[]).where((c) => c.rfidEnabled).toList();

  void _selectCabin(int? address) {
    setState(() => _cabin = address);
    if (address == null) return;
    final c = _rfidCabins().where((x) => x.addressIndex == address).firstOrNull;
    if (c?.rfidHost != null) _ip.text = c!.rfidHost!;
    if (c?.rfidPort != null) _port.text = '${c!.rfidPort}';
  }

  void _scenario(String Function(int address) id, TestStatus status, String detail) {
    final cabin = _cabin;
    if (cabin == null) return;
    ref.read(scenarioResultsProvider.notifier).set(id(cabin), status, detail: detail);
  }

  int? get _portNo => int.tryParse(_port.text.trim());

  String get _target => '${_ip.text.trim()}:${_port.text.trim()}';

  // ── 1. Bağlantı ────────────────────────────────────────────────────

  Future<void> _connect() async {
    final port = _portNo;
    if (port == null) return setState(() => _error = 'Port geçersiz');
    setState(() {
      _busy = true;
      _error = null;
      _info = null;
      _antennas = null;
    });

    // Önce bağlantı testi (ayrı soket): okuyucu bilgisi.
    final test = await _rfid.testConnection(ip: _ip.text.trim(), port: port);
    final info = test.when(ok: (i) => i, error: (_) => null);
    final testError = test.when(ok: (_) => null, error: (e) => e.message);

    final result = await _rfid.connect(_ip.text.trim(), port);
    final connectError = result.when(ok: (_) => null, error: (e) => e.message);
    final ok = connectError == null;
    final antennas = ok ? _rfid.connectedAntennas : const <int>[];

    final infoText = info == null
        ? 'okuyucu bilgisi alınamadı${testError != null ? ' ($testError)' : ''}'
        : 'firmware ${info.firmwareVersion} · tip ${info.readerType} · güç ${info.currentPower}/${info.maxPower} dBm';
    _report.add('RFID bağlantısı ($_target)', ok ? StepResult.ok : StepResult.fail, detail: connectError ?? infoText);
    _scenario(ScenarioIds.rfidReader, ok ? TestStatus.passed : TestStatus.failed, connectError ?? infoText);
    if (ok) _recordAntennas(antennas);

    if (!mounted) return;
    setState(() {
      _busy = false;
      _connected = ok;
      _info = info;
      _antennas = ok ? antennas : null;
      _error = connectError;
      if (info != null) _power.text = '${info.currentPower}';
    });
  }

  void _recordAntennas(List<int> antennas) {
    final missing = [for (var a = 1; a <= 4; a++) if (!antennas.contains(a)) a];
    final detail = antennas.isEmpty
        ? 'Hiçbir portta anten yok'
        : 'Bağlı: ${antennas.join(', ')}${missing.isEmpty ? '' : ' · Bağlı değil: ${missing.join(', ')}'}';
    _report.add(
      'RFID antenleri: ${antennas.length} bağlı',
      antennas.isEmpty ? StepResult.fail : StepResult.ok,
      detail: detail,
    );
    _scenario(ScenarioIds.rfidAntennas, antennas.isEmpty ? TestStatus.failed : TestStatus.passed, detail);
  }

  Future<void> _disconnect() async {
    setState(() => _busy = true);
    await _stop(record: false);
    await _rfid.disconnect();
    _report.add('RFID bağlantısı kesildi', StepResult.info);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _connected = false;
      _antennas = null;
    });
  }

  // ── 2. Antenler ────────────────────────────────────────────────────

  Future<void> _redetect() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await _rfid.detectAntennas();
    final antennas = _rfid.connectedAntennas;
    _recordAntennas(antennas);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _antennas = antennas;
      _error = result.when(ok: (_) => null, error: (e) => e.message);
    });
  }

  Future<void> _setPower() async {
    final dbm = int.tryParse(_power.text.trim());
    if (dbm == null || dbm < 0 || dbm > 33) return setState(() => _error = 'Güç 0–33 dBm arasında olmalı');
    setState(() => _busy = true);
    final result = await _rfid.setPower(dbm);
    final error = result.when(ok: (_) => null, error: (e) => e.message);
    _report.add('RFID güç: $dbm dBm', error == null ? StepResult.ok : StepResult.fail, detail: error);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = error;
    });
  }

  // ── 3. Etiket okuma ────────────────────────────────────────────────

  void _start() {
    setState(() {
      _byAntenna.clear();
      _started = DateTime.now();
      _elapsed = 0;
      _error = null;
    });
    try {
      _sub = _rfid.startInventory().listen(
        (tag) {
          _byAntenna.putIfAbsent(tag.antenna, () => {}).putIfAbsent(tag.epc, () => _TagStat(tag.epc)).add(tag.rssi);
          if (mounted) setState(() {});
        },
        onError: (Object e) {
          if (mounted) setState(() => _error = e.toString());
        },
      );
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted) return;
        setState(() => _elapsed++);
        if (_durationSec > 0 && _elapsed >= _durationSec) _stop();
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _started = null;
      });
    }
  }

  Future<void> _stop({bool record = true}) async {
    _timer?.cancel();
    _timer = null;
    if (_sub == null) return;
    await _sub?.cancel();
    _sub = null;
    await _rfid.stopInventory();
    final started = _started;
    if (record && started != null) _recordRead(DateTime.now().difference(started).inSeconds);
    if (mounted) setState(() => _started = null);
  }

  void _recordRead(int secs) {
    final connected = _antennas ?? const <int>[];
    final antennas = {...connected, ..._byAntenna.keys}.toList()..sort();
    final total = {for (final m in _byAntenna.values) ...m.keys}.length;
    final silent = [for (final a in connected) if ((_byAntenna[a] ?? const {}).isEmpty) a];

    String rssiRange(Map<String, _TagStat> tags) {
      if (tags.isEmpty) return '';
      final min = tags.values.map((t) => t.minRssi).reduce((a, b) => a < b ? a : b);
      final max = tags.values.map((t) => t.maxRssi).reduce((a, b) => a > b ? a : b);
      return ' ($max … $min dBm)';
    }

    final summary = [
      for (final a in antennas) 'Anten $a: ${(_byAntenna[a] ?? const {}).length} etiket${rssiRange(_byAntenna[a] ?? const {})}',
    ].join('; ');
    final detail = [
      for (final a in antennas) ...[
        'Anten $a${connected.contains(a) ? '' : ' (bağlı görünmüyordu)'}: ${(_byAntenna[a] ?? const {}).length} etiket',
        for (final t in ((_byAntenna[a] ?? const <String, _TagStat>{}).values.toList()..sort((x, y) => y.avgRssi.compareTo(x.avgRssi))))
          '  ${t.epc}  okuma ${t.count}  RSSI son ${t.lastRssi} · min ${t.minRssi} · ort ${t.avgRssi.toStringAsFixed(1)} · maks ${t.maxRssi} dBm',
      ],
    ].join('\n');

    final status = total == 0 ? TestStatus.failed : (silent.isNotEmpty ? TestStatus.warning : TestStatus.passed);
    _report.add(
      'RFID etiket okuma: $total etiket ($secs sn)',
      total == 0 ? StepResult.fail : StepResult.ok,
      detail: detail.isEmpty ? 'Etiket okunmadı' : detail,
    );
    _scenario(
      ScenarioIds.rfidTags,
      status,
      total == 0
          ? 'Hiç etiket okunmadı'
          : '$summary${silent.isNotEmpty ? ' — etiket okumayan anten: ${silent.join(', ')}' : ''}',
    );
  }

  // ── UI ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final running = _sub != null;
    ref.watch(cabinSessionProvider.select((s) => s.active));
    final cabins = _rfidCabins();
    return ListView(
      padding: const EdgeInsets.all(MedSpacing.xl2),
      children: [
        if (_error != null)
          Padding(padding: const EdgeInsets.only(bottom: MedSpacing.lg), child: ErrorText(_error!)),
        _connectionCard(cabins, running),
        _antennaCard(running),
        _readCard(running),
      ],
    );
  }

  Widget _connectionCard(List<CabinInfo> cabins, bool running) {
    final info = _info;
    return SectionCard(
      title: '1. Okuyucu bağlantısı',
      trailing: StatusBadge(
        status: _connected ? TestStatus.passed : TestStatus.pending,
        label: _connected ? 'Bağlı' : 'Bağlı değil',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: MedSpacing.lg,
            runSpacing: MedSpacing.lg,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (cabins.isNotEmpty)
                DropdownButton<int?>(
                  value: _cabin,
                  items: [
                    for (final c in cabins)
                      DropdownMenuItem<int?>(value: c.addressIndex, child: Text('${c.title} — RFID')),
                    const DropdownMenuItem<int?>(value: null, child: Text('Elle gir')),
                  ],
                  onChanged: _connected ? null : _selectCabin,
                ),
              SizedBox(
                width: 170,
                child: TextField(
                  controller: _ip,
                  enabled: !_connected,
                  decoration: const InputDecoration(labelText: 'IP', isDense: true, border: OutlineInputBorder()),
                ),
              ),
              NumberField(label: 'Port', controller: _port),
              if (!_connected)
                BusyButton(label: 'Bağlan ve kontrol et', icon: Icons.link, busy: _busy, onPressed: _connect)
              else
                OutlinedButton.icon(
                  onPressed: _busy ? null : _disconnect,
                  icon: const Icon(Icons.link_off),
                  label: const Text('Bağlantıyı kes'),
                ),
            ],
          ),
          if (cabins.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: MedSpacing.sm),
              child: Text(
                'Kabin tanımında RFID okuyucu yok ya da tanım yüklenmedi; IP/port elle girilir, sonuç yalnız rapora yazılır.',
                style: hintStyle(fontSize: 12),
              ),
            ),
          if (info != null) ...[
            const SizedBox(height: MedSpacing.md),
            Text(
              'Firmware ${info.firmwareVersion} · tip ${info.readerType} · güç ${info.currentPower} / ${info.maxPower} dBm',
              style: monoStyle(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _antennaCard(bool running) {
    final antennas = _antennas;
    return SectionCard(
      title: '2. Antenler',
      trailing: OutlinedButton.icon(
        onPressed: _connected && !_busy && !running ? _redetect : null,
        icon: const Icon(Icons.refresh),
        label: const Text('Yeniden kontrol et'),
      ),
      child: antennas == null
          ? Text('Bağlanınca okuyucu her portu dener; anteni olmayan portu reddeder.', style: hintStyle())
          : Row(
              children: [
                for (var a = 1; a <= 4; a++)
                  Expanded(child: _AntennaTile(antenna: a, connected: antennas.contains(a), tags: _byAntenna[a])),
              ],
            ),
    );
  }

  Widget _readCard(bool running) {
    final antennas = {...?_antennas, ..._byAntenna.keys}.toList()..sort();
    return SectionCard(
      title: '3. Etiket okuma (anten bazında)',
      trailing: running
          ? Text(_durationSec > 0 ? '$_elapsed / $_durationSec sn' : '$_elapsed sn', style: monoStyle())
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: MedSpacing.lg,
            runSpacing: MedSpacing.md,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              NumberField(label: 'Güç (dBm)', controller: _power),
              OutlinedButton(
                onPressed: _connected && !_busy && !running ? _setPower : null,
                child: const Text('Gücü ayarla'),
              ),
              const SizedBox(width: MedSpacing.lg),
              Text('Süre:', style: hintStyle()),
              for (final (secs, label) in const [(10, '10 sn'), (30, '30 sn'), (0, 'Sürekli')])
                ChoiceChip(
                  label: Text(label),
                  selected: _durationSec == secs,
                  onSelected: running ? null : (_) => setState(() => _durationSec = secs),
                ),
              if (!running)
                FilledButton.icon(
                  onPressed: _connected && !_busy ? _start : null,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Okumayı başlat'),
                )
              else
                OutlinedButton.icon(onPressed: _stop, icon: const Icon(Icons.stop), label: const Text('Durdur')),
            ],
          ),
          const SizedBox(height: MedSpacing.md),
          Text(
            'Etiketleri antenlerin önüne yerleştirin. Her antenin okuduğu etiketler ve sinyal güçleri ayrı listelenir; '
            'bitince sonuç rapora yazılır.',
            style: hintStyle(fontSize: 12),
          ),
          for (final a in antennas) _antennaTable(a),
        ],
      ),
    );
  }

  Widget _antennaTable(int antenna) {
    final tags = (_byAntenna[antenna] ?? const <String, _TagStat>{}).values.toList()
      ..sort((a, b) => b.avgRssi.compareTo(a.avgRssi));
    final header = MedTextStyles.bodySm(color: MedColors.text3, weight: FontWeight.w600);
    Widget cell(String text, {int flex = 2, TextStyle? style}) =>
        Expanded(flex: flex, child: Text(text, style: style ?? monoStyle(), overflow: TextOverflow.ellipsis));
    return Padding(
      padding: const EdgeInsets.only(top: MedSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Anten $antenna · ${tags.length} etiket', style: MedTextStyles.titleSm()),
          const SizedBox(height: MedSpacing.xs),
          if (tags.isEmpty)
            Text(_sub != null ? 'Henüz etiket okunmadı…' : 'Etiket okunmadı', style: hintStyle())
          else ...[
            Row(
              children: [
                cell('EPC', flex: 6, style: header),
                cell('Okuma', style: header),
                cell('Son dBm', style: header),
                cell('Min', style: header),
                cell('Ort', style: header),
                cell('Maks', style: header),
              ],
            ),
            const Divider(height: MedSpacing.md),
            for (final t in tags)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    cell(t.epc, flex: 6),
                    cell('${t.count}'),
                    cell('${t.lastRssi}', style: monoStyle(color: _rssiColor(t.lastRssi))),
                    cell('${t.minRssi}'),
                    cell(t.avgRssi.toStringAsFixed(1)),
                    cell('${t.maxRssi}'),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }

  /// Güçlü (−50 üstü) yeşil, orta gri, zayıf (−70 altı) amber.
  static Color _rssiColor(int rssi) => rssi >= -50
      ? TestStatus.passed.color
      : (rssi <= -70 ? TestStatus.warning.color : MedColors.text2);
}

class _AntennaTile extends StatelessWidget {
  const _AntennaTile({required this.antenna, required this.connected, required this.tags});

  final int antenna;
  final bool connected;
  final Map<String, _TagStat>? tags;

  @override
  Widget build(BuildContext context) {
    final count = tags?.length ?? 0;
    String range = '';
    if (count > 0) {
      final min = tags!.values.map((t) => t.minRssi).reduce((a, b) => a < b ? a : b);
      final max = tags!.values.map((t) => t.maxRssi).reduce((a, b) => a > b ? a : b);
      range = '$max … $min dBm';
    }
    final status = connected ? TestStatus.passed : TestStatus.pending;
    final colors = status.colors;
    return Container(
      margin: const EdgeInsets.only(right: MedSpacing.md),
      padding: const EdgeInsets.all(MedSpacing.lg),
      decoration: BoxDecoration(
        color: connected ? colors.background : MedColors.surface2,
        border: Border.all(color: connected ? colors.border(alpha: 0.5) : MedColors.border),
        borderRadius: MedRadius.mdAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.settings_input_antenna, size: 18, color: status.color),
              const SizedBox(width: MedSpacing.sm),
              Text('Anten $antenna', style: MedTextStyles.titleSm()),
            ],
          ),
          const SizedBox(height: MedSpacing.xs),
          Text(connected ? 'Bağlı' : 'Bağlı değil', style: TextStyle(color: status.color, fontWeight: FontWeight.w600)),
          if (connected || count > 0) Text('$count etiket${range.isEmpty ? '' : ' · $range'}', style: hintStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
