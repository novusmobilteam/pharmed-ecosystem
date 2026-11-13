import 'dart:async' show StreamSubscription;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../core/providers.dart';
import '../../core/report.dart';
import '../../core/traffic_log.dart';
import '../../widgets/common.dart';

class _TagStat {
  _TagStat(this.epc, this.firstSeen);

  final String epc;
  final DateTime firstSeen;
  DateTime lastSeen = DateTime.now();
  int count = 0;
  int lastRssi = 0;
  final Set<int> antennas = {};
}

/// UHFEx10 RFID okuyucu testi (TCP): bağlantı, güç, envanter ve canlı etiket listesi.
/// Client ile aynı `RfidService` kullanılır.
class RfidPage extends ConsumerStatefulWidget {
  const RfidPage({super.key});

  @override
  ConsumerState<RfidPage> createState() => _RfidPageState();
}

class _RfidPageState extends ConsumerState<RfidPage> {
  final _ip = TextEditingController(text: '192.168.1.190');
  final _port = TextEditingController(text: '6000');
  final _power = TextEditingController(text: '30');

  bool _busy = false;
  bool _connected = false;
  RfidReaderInfo? _info;
  String? _error;

  StreamSubscription<RfidTag>? _sub;
  DateTime? _inventoryStarted;
  final Map<String, _TagStat> _tags = {};

  /// dispose'ta ref kullanılamadığı için baştan tutulur.
  late final IRfidService _rfid = ref.read(rfidServiceProvider);

  @override
  void initState() {
    super.initState();
    _rfid; // erken oluştur
  }

  @override
  void dispose() {
    _sub?.cancel();
    if (_rfid.isConnected) _rfid.disconnect();
    for (final c in [_ip, _port, _power]) {
      c.dispose();
    }
    super.dispose();
  }

  int? get _portNo => int.tryParse(_port.text.trim());

  Future<void> _guard(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _test() => _guard(() async {
    final port = _portNo;
    if (port == null) throw Exception('Port geçersiz');
    final result = await _rfid.testConnection(ip: _ip.text.trim(), port: port);
    result.when(
      ok: (info) {
        setState(() => _info = info);
        ref
            .read(testReportProvider)
            .add(
              'RFID bağlantı testi (${_ip.text.trim()}:$port)',
              StepResult.ok,
              detail: 'firmware ${info.firmwareVersion} · tip ${info.readerType} · güç ${info.currentPower}/${info.maxPower} dBm',
            );
      },
      error: (e) {
        ref.read(testReportProvider).add('RFID bağlantı testi (${_ip.text.trim()}:$port)', StepResult.fail, detail: e.message);
        throw Exception(e.message);
      },
    );
  });

  Future<void> _connect() => _guard(() async {
    final port = _portNo;
    if (port == null) throw Exception('Port geçersiz');
    final result = await _rfid.connect(_ip.text.trim(), port);
    result.when(
      ok: (_) {
        setState(() => _connected = true);
        ref.read(testReportProvider).add('RFID bağlandı (${_ip.text.trim()}:$port)', StepResult.ok);
      },
      error: (e) {
        ref.read(testReportProvider).add('RFID bağlanamadı (${_ip.text.trim()}:$port)', StepResult.fail, detail: e.message);
        throw Exception(e.message);
      },
    );
  });

  Future<void> _disconnect() => _guard(() async {
    await _stop(record: false);
    await _rfid.disconnect();
    setState(() => _connected = false);
    ref.read(testReportProvider).add('RFID bağlantısı kesildi', StepResult.info);
  });

  Future<void> _setPower() => _guard(() async {
    final dbm = int.tryParse(_power.text.trim());
    if (dbm == null || dbm < 0 || dbm > 33) throw Exception('Güç 0–33 dBm arasında olmalı');
    final result = await _rfid.setPower(dbm);
    result.when(
      ok: (_) => ref.read(testReportProvider).add('RFID güç: $dbm dBm', StepResult.ok),
      error: (e) {
        ref.read(testReportProvider).add('RFID güç ayarlanamadı ($dbm dBm)', StepResult.fail, detail: e.message);
        throw Exception(e.message);
      },
    );
  });

  void _start() {
    setState(() {
      _tags.clear();
      _inventoryStarted = DateTime.now();
      _error = null;
    });
    try {
      _sub = ref
          .read(rfidServiceProvider)
          .startInventory()
          .listen(
            (tag) {
              final stat = _tags.putIfAbsent(tag.epc, () => _TagStat(tag.epc, DateTime.now()));
              stat
                ..count += 1
                ..lastRssi = tag.rssi
                ..lastSeen = DateTime.now()
                ..antennas.add(tag.antenna);
              if (mounted) setState(() {});
            },
            onError: (Object e) {
              if (mounted) setState(() => _error = e.toString());
            },
          );
    } catch (e) {
      setState(() {
        _error = e.toString();
        _inventoryStarted = null;
      });
    }
  }

  Future<void> _stop({bool record = true}) async {
    if (_sub == null) return;
    await _sub?.cancel();
    _sub = null;
    await _rfid.stopInventory();
    final started = _inventoryStarted;
    if (record && started != null) {
      final secs = DateTime.now().difference(started).inSeconds;
      final sorted = _tags.values.toList()..sort((a, b) => a.epc.compareTo(b.epc));
      ref
          .read(testReportProvider)
          .add(
            'RFID envanter: ${_tags.length} etiket ($secs sn)',
            _tags.isEmpty ? StepResult.fail : StepResult.ok,
            detail: sorted
                .map((t) => '${t.epc}  okuma ${t.count}  rssi ${t.lastRssi}  anten ${(t.antennas.toList()..sort()).join(',')}')
                .join('\n'),
          );
    }
    if (mounted) setState(() => _inventoryStarted = null);
  }

  @override
  Widget build(BuildContext context) {
    final running = _sub != null;
    final tags = _tags.values.toList()..sort((a, b) => b.lastSeen.compareTo(a.lastSeen));
    final mono = monoStyle();
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        SectionCard(
          title: 'RFID okuyucu (UHFEx10, TCP)',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SizedBox(
                    width: 180,
                    child: TextField(
                      controller: _ip,
                      enabled: !_connected,
                      decoration: const InputDecoration(labelText: 'IP adresi', isDense: true, border: OutlineInputBorder()),
                    ),
                  ),
                  NumberField(label: 'Port', controller: _port),
                  OutlinedButton(onPressed: _busy || _connected ? null : _test, child: const Text('Bağlantı testi')),
                  if (!_connected)
                    BusyButton(label: 'Bağlan', icon: Icons.link, busy: _busy, onPressed: _connect)
                  else
                    OutlinedButton.icon(
                      onPressed: _busy ? null : _disconnect,
                      icon: const Icon(Icons.link_off),
                      label: const Text('Bağlantıyı kes'),
                    ),
                  Text(
                    _connected ? 'Bağlı' : 'Bağlı değil',
                    style: TextStyle(
                      color: _connected ? TestStatus.passed.color : TestStatus.failed.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (_info != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Firmware ${_info!.firmwareVersion} · okuyucu tipi ${_info!.readerType} · '
                  'güç ${_info!.currentPower} / ${_info!.maxPower} dBm',
                  style: mono,
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 8),
                ErrorText(_error!),
              ],
            ],
          ),
        ),
        SectionCard(
          title: 'Envanter',
          trailing: running ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  NumberField(label: 'Güç (dBm)', controller: _power),
                  OutlinedButton(onPressed: _connected && !_busy && !running ? _setPower : null, child: const Text('Gücü ayarla')),
                  if (!running)
                    FilledButton.icon(
                      onPressed: _connected && !_busy ? _start : null,
                      icon: const Icon(Icons.sensors),
                      label: const Text('Okumayı başlat'),
                    )
                  else
                    FilledButton.icon(
                      onPressed: () => _stop(),
                      icon: const Icon(Icons.stop),
                      label: const Text('Durdur ve rapora ekle'),
                    ),
                  Text('${tags.length} farklı etiket', style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 12),
              if (tags.isEmpty)
                Text(running ? 'Etiket bekleniyor…' : 'Okuma başlatılmadı.')
              else
                DataTable(
                  headingRowHeight: 36,
                  dataRowMinHeight: 30,
                  dataRowMaxHeight: 36,
                  columns: const [
                    DataColumn(label: Text('EPC')),
                    DataColumn(label: Text('Okuma'), numeric: true),
                    DataColumn(label: Text('RSSI'), numeric: true),
                    DataColumn(label: Text('Anten')),
                    DataColumn(label: Text('Son görülme')),
                  ],
                  rows: [
                    for (final t in tags)
                      DataRow(
                        cells: [
                          DataCell(Text(t.epc, style: mono)),
                          DataCell(Text('${t.count}')),
                          DataCell(Text('${t.lastRssi}')),
                          DataCell(Text((t.antennas.toList()..sort()).join(', '))),
                          DataCell(Text(formatTime(t.lastSeen))),
                        ],
                      ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}
