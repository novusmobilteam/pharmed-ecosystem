import 'dart:async' show Timer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../core/providers.dart';
import '../../core/report.dart';
import '../../widgets/address_picker.dart';
import '../../widgets/common.dart';

/// Mobil kabinde serum kartı satır 26'da slave moda alınır; çekmeceler
/// port 1–8 + `drawer 00` ile sürülür (docs/hardware/rs485-protokol.md).
const _serumSlaveRow = 26;

class _PortState {
  String? raw;
  String? note;
  bool busy = false;
}

String _interpret(String? raw) {
  if (raw == null) return 'cevap yok';
  if (raw.contains('h3')) return 'Açık (h3)';
  if (raw.contains('h6')) return 'Açık (h6)';
  if (raw.contains('h0')) return 'Kilitli (h0)';
  if (raw.contains('h4')) return 'Kapatıldı (h4)';
  if (raw.contains('h5')) return 'Kapalı (h5)';
  if (raw.contains('h1')) return 'Kilit açık, çekilmedi (h1)';
  if (raw.contains('no')) return 'Geçersiz komut / solenoid yok (no)';
  return raw.trim();
}

/// Mobil kabin çekmece testi: port bazında aç + durum, canlı izleme ve
/// tüm portları sırayla deneme. Komutlar client ile aynı servis metodlarıyla gider.
class MobileCabinPage extends ConsumerStatefulWidget {
  const MobileCabinPage({super.key});

  @override
  ConsumerState<MobileCabinPage> createState() => _MobileCabinPageState();
}

class _MobileCabinPageState extends ConsumerState<MobileCabinPage> {
  int _address = 1;
  final Map<int, _PortState> _ports = {for (var p = 1; p <= 8; p++) p: _PortState()};
  bool _sequenceRunning = false;
  int? _watchPort;
  Timer? _watchTimer;
  bool _polling = false;
  String? _lastAction;

  ManagementCard get _manager => ManagementCard(addressIndex: _address);

  @override
  void dispose() {
    _watchTimer?.cancel();
    super.dispose();
  }

  Future<String?> _readStatus(int port) {
    return ref
        .read(cabinOpsProvider)
        .sendRawCommand(
          manager: _manager,
          targetRow: _serumSlaveRow,
          commandPayload: CommandBuilder.buildDrawerCommand(action: DeviceAction.status, port: port, drawer: 0),
        );
  }

  Future<void> _open(int port, {bool record = true}) async {
    final st = _ports[port]!;
    setState(() => st.busy = true);
    final title = 'Mobil çekmece aç (${addressLabel(_address)}, port $port)';
    try {
      await ref.read(cabinOpsProvider).openMobileDrawer(manager: _manager, port: port);
      st.note = 'Açma komutu kabul edildi';
      if (record) ref.read(testReportProvider).add(title, StepResult.ok);
    } catch (e) {
      st.note = 'HATA: $e';
      if (record) ref.read(testReportProvider).add(title, StepResult.fail, detail: e.toString());
    } finally {
      _lastAction = title;
      if (mounted) setState(() => st.busy = false);
    }
  }

  Future<void> _status(int port, {bool record = true}) async {
    final st = _ports[port]!;
    setState(() => st.busy = true);
    try {
      st.raw = await _readStatus(port);
      if (record) {
        ref
            .read(testReportProvider)
            .add(
              'Mobil çekmece durumu (${addressLabel(_address)}, port $port)',
              st.raw == null ? StepResult.fail : StepResult.info,
              detail: '${st.raw?.trim() ?? '-'} → ${_interpret(st.raw)}',
            );
      }
    } catch (e) {
      st.raw = null;
      st.note = 'HATA: $e';
    } finally {
      if (mounted) setState(() => st.busy = false);
    }
  }

  /// Her portu sırayla açar, 1,5 sn sonra durumunu okur.
  Future<void> _runSequence() async {
    setState(() => _sequenceRunning = true);
    final lines = <String>[];
    var failed = 0;
    for (var port = 1; port <= 8; port++) {
      if (!mounted) return;
      await _open(port, record: false);
      await Future<void>.delayed(const Duration(milliseconds: 1500));
      await _status(port, record: false);
      final st = _ports[port]!;
      final ok = st.note != null && !st.note!.startsWith('HATA');
      if (!ok) failed++;
      lines.add('port $port: ${st.note ?? '-'} · durum ${_interpret(st.raw)}');
    }
    await _release();
    ref
        .read(testReportProvider)
        .add(
          'Mobil kabin tüm portlar (${addressLabel(_address)})',
          failed == 0 ? StepResult.ok : StepResult.fail,
          detail: lines.join('\n'),
        );
    _lastAction = 'Mobil kabin tüm portlar (${addressLabel(_address)})';
    if (mounted) setState(() => _sequenceRunning = false);
  }

  void _toggleWatch(int port) {
    _watchTimer?.cancel();
    if (_watchPort == port) {
      setState(() => _watchPort = null);
      _release();
      return;
    }
    setState(() => _watchPort = port);
    _watchTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (_polling || !mounted) return;
      _polling = true;
      try {
        final raw = await _readStatus(port);
        if (mounted) setState(() => _ports[port]!.raw = raw);
      } catch (_) {
      } finally {
        _polling = false;
      }
    });
  }

  Future<void> _release() async {
    try {
      await ref
          .read(serialServiceProvider)
          .sendAndReceive(
            CommandBuilder.buildManagementCommand(addressIndex: _address, row: 0),
            timeout: const Duration(milliseconds: 300),
          );
    } catch (_) {}
  }

  void _observe(bool onlyTarget) {
    ref
        .read(testReportProvider)
        .add(
          onlyTarget ? 'Gözlem: yalnız hedef çekmece açıldı' : 'Gözlem: BAŞKA çekmece/kabin de açıldı',
          onlyTarget ? StepResult.ok : StepResult.fail,
          detail: _lastAction,
        );
    showMessage(context, 'Gözlem rapora eklendi.');
  }

  @override
  Widget build(BuildContext context) {
    final connected = ref.watch(sessionProvider.select((s) => s.port != null));
    final enabled = connected && !_sequenceRunning;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        SectionCard(
          title: 'Mobil kabin çekmeceleri',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Yönetim kartında satır 26 (serum kartı slave modu) seçilir, çekmeceler port 1–8 ile açılır. '
                'Durum: h3 açık, h0/h4 kilitli. RFID okuyucu için "RFID" ekranını kullanın.',
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text('Yönetim kartı:'),
                  AddressPicker(
                    value: _address,
                    onChanged: (v) {
                      _watchTimer?.cancel();
                      setState(() {
                        _address = v;
                        _watchPort = null;
                      });
                    },
                  ),
                  BusyButton(
                    label: 'Tüm portları sırayla test et',
                    icon: Icons.playlist_play,
                    busy: _sequenceRunning,
                    onPressed: enabled ? _runSequence : null,
                  ),
                  if (!connected) const NotConnectedHint(),
                ],
              ),
            ],
          ),
        ),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (var port = 1; port <= 8; port++)
              _PortTile(
                port: port,
                state: _ports[port]!,
                watching: _watchPort == port,
                enabled: enabled,
                onOpen: () => _open(port),
                onStatus: () => _status(port),
                onWatch: () => _toggleWatch(port),
              ),
          ],
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'Gözlem',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton.tonalIcon(
                onPressed: _lastAction == null ? null : () => _observe(true),
                icon: Icon(TestStatus.passed.icon, color: TestStatus.passed.color),
                label: const Text('Yalnız hedef çekmece açıldı'),
              ),
              FilledButton.tonalIcon(
                onPressed: _lastAction == null ? null : () => _observe(false),
                icon: Icon(TestStatus.failed.icon, color: TestStatus.failed.color),
                label: const Text('Başka çekmece/kabin de açıldı'),
              ),
              OutlinedButton.icon(
                onPressed: connected ? _release : null,
                icon: const Icon(Icons.cleaning_services),
                label: const Text('Satır seçimini bırak'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PortTile extends StatelessWidget {
  const _PortTile({
    required this.port,
    required this.state,
    required this.watching,
    required this.enabled,
    required this.onOpen,
    required this.onStatus,
    required this.onWatch,
  });

  final int port;
  final _PortState state;
  final bool watching;
  final bool enabled;
  final VoidCallback onOpen;
  final VoidCallback onStatus;
  final VoidCallback onWatch;

  @override
  Widget build(BuildContext context) {
    final raw = state.raw;
    final open = raw != null && (raw.contains('h3') || raw.contains('h6'));
    final locked = raw != null && (raw.contains('h0') || raw.contains('h4') || raw.contains('h5'));
    final color = open ? TestStatus.warning.color : (locked ? TestStatus.passed.color : TestStatus.pending.color);
    return SizedBox(
      width: 250,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Port $port', style: Theme.of(context).textTheme.titleMedium),
                  const Spacer(),
                  if (state.busy) const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                  if (watching) const Icon(Icons.visibility, size: 18),
                ],
              ),
              const SizedBox(height: 6),
              Text(_interpret(raw), style: TextStyle(color: color, fontWeight: FontWeight.w600)),
              Text('ham: ${raw?.trim() ?? '-'}', style: monoStyle()),
              if (state.note != null)
                Text(state.note!, style: const TextStyle(fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 8),
              Row(
                children: [
                  FilledButton(onPressed: enabled && !state.busy ? onOpen : null, child: const Text('Aç')),
                  const SizedBox(width: 6),
                  OutlinedButton(onPressed: enabled && !state.busy ? onStatus : null, child: const Text('Durum')),
                  const SizedBox(width: 6),
                  IconButton(
                    tooltip: watching ? 'İzlemeyi durdur' : 'Canlı izle (1 sn)',
                    onPressed: enabled ? onWatch : null,
                    icon: Icon(watching ? Icons.visibility_off : Icons.visibility),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
